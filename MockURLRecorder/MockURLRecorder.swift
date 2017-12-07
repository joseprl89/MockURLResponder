//
//  MockURLRecorder.swift
//  MockURLRecorder
//
//  Created by Josep Rodríguez López on 23/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

public class MockURLRecorder: NSObject {

    private static var recordedCalls: [RecordedInteractionsOnHost] = []

    public static var replayCode: String {
        return recordedCalls.map { $0.replayCode }.joined(separator: "\n")
    }

    /// Registers MockURLRecorderProtocol in the URLProtocol shared configuration.
    /// NOTE If you are using custom URLSessions, please register manually MockURLRecorderProtocol
    /// As one of your URLProtocols.
    /// e.g.:
    ///
    /// ```
    /// let config = URLSessionConfiguration()
    /// config.protocolClasses = [MockURLRecorderProtocol.self]
    /// URLSession(configuration: config)
    /// ```
    public class func register() {
        URLProtocol.registerClass(MockURLRecorderProtocol.self)
    }

    public class func clearSession() {
        recordedCalls = []
    }

    class func record(_ response: HTTPURLResponse, for request: URLRequest, data: Data?) {
        if let recordedCallHost = recordedCalls.first(where: { $0.sameHost(as: request) }) {
            recordedCallHost.record(response, for: request, body: data)
        } else {
            guard let url = request.url else {
                fatalError("Can't obtain url from request: \(request)")
            }

            let recordedCallHost = RecordedInteractionsOnHost(url: url)
            recordedCallHost.record(response, for: request, body: data)
            recordedCalls += [recordedCallHost]
        }
    }
}
