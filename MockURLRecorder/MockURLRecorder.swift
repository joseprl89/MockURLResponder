//
//  MockURLRecorder.swift
//  MockURLRecorder
//
//  Created by Josep Rodríguez López on 23/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import UIKit

public class MockURLRecorder: NSObject {

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

    class func record(_ response: HTTPURLResponse, for request: URLRequest, data bodyData: Data?) {
        // Naively assume utf8
        var body: String? = nil
        if let data = bodyData {
            body = String(data: data, encoding: .utf8)
        }

        replayCode += "let configurator = MockURLResponderConfigurator(scheme: \"\(request.url!.scheme!)\", " +
            "host: \"\(request.url!.host!)\")\n\n" +
            "configurator.respond(to: \"\(request.url!.path)\", method: \"\(request.httpMethod!)\")\n" +
            "    .with(body: \"\(body ?? "")\")\n" +
            "    .once()\n"
    }

    public private(set) static var replayCode: String = ""
}
