//
//  RecordedInteraction.swift
//  MockURLRecorder
//
//  Created by Josep Rodríguez López on 25/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

internal class RecordedInteraction: Equatable {

    // Remember to update equatable when adding fields!
    private let body: String
    private let path: String
    private let method: String

    private var count: Int

    var replayCode: String {
        return "configurator.respond(to: \"\(path)\", method: \"\(method)\")\n" +
            "    .with(body: \"\(body)\")\n" +
            "    .\(repetitionMethod())\n"
    }

    init(response: HTTPURLResponse, request: URLRequest, body: Data?) {
        guard let url = request.url, let method = request.httpMethod else {
            fatalError("Request with no URL or HTTP Method: \(request)")
        }

        self.path = url.path
        self.method = method
        if let data = body {
            // Naively assume utf8
            self.body = String(data: data, encoding: .utf8) ?? ""
        } else {
            self.body = ""
        }

        self.count = 1
    }

    func wasRepeated() {
        count += 1
    }

    private func repetitionMethod() -> String {
        return count == 1 ? "once()" : "times(\(count))"
    }

    public static func == (lhs: RecordedInteraction, rhs: RecordedInteraction) -> Bool {
        return lhs.body == rhs.body && lhs.path == rhs.path && lhs.method == rhs.method
    }
}
