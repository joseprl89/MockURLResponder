//
//  RecordedInteractionsOnHost.swift
//  MockURLRecorder
//
//  Created by Josep Rodríguez López on 25/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import UIKit

internal class RecordedInteractionsOnHost {

    private let host: String
    private let scheme: String
    private var interactions: [RecordedInteraction] = []

    var replayCode: String {
        return configurator() + interactionsReplayCode
    }

    private var interactionsReplayCode: String {
        return interactions.map { $0.replayCode }.joined(separator: "\n")
    }

    init(url: URL) {
        guard let host = url.host, let scheme = url.scheme else {
            fatalError("URL doesn't contain a host or scheme: \(url)")
        }

        self.host = host
        self.scheme = scheme
    }

    func sameHost(as request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }

        return url.host == host && url.scheme == scheme
    }

    func record(_ response: HTTPURLResponse, for request: URLRequest, body bodyData: Data?) {
        let interaction = RecordedInteraction(response: response, request: request, body: bodyData)

        if let lastRecordedInteraction = interactions.last, lastRecordedInteraction == interaction {
            lastRecordedInteraction.wasRepeated()
        } else {
            interactions += [interaction]
        }
    }

    private func configurator() -> String {
        return "let configurator = MockURLResponderConfigurator(scheme: \"\(scheme)\", " +
        "host: \"\(host)\")\n\n"
    }
}
