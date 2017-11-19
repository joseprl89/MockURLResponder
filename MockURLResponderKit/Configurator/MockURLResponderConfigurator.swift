//
//  MockURLResponderConfigurator.swift
//  MockURLResponderConfiguratorKit
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

public class MockURLResponderConfigurator {

    private let scheme: String
    private let host: String
    internal var responses: [MockURLResponse] = []

    public var arguments: [String] {
        let stringJSONArgument = String(data: try! JSONSerialization.data(withJSONObject: jsonArguments), encoding: .ascii)!
        return [
            "--mock-url-response=\(stringJSONArgument)"
        ]
    }

    private var jsonArguments: [String: Any] {
        return [
            "scheme": scheme,
            "host": host,
            "responses": responses.map { $0.jsonArguments }
        ]
    }

    public init(scheme: String, host: String) {
        self.scheme = scheme
        self.host = host
    }

    public func respond(to path: String, method: String = HTTPMethod.GET.rawValue) -> MockURLResponseBuilder {
        return MockURLResponseBuilder(configurator: self, path: path, method: method)
    }
}
