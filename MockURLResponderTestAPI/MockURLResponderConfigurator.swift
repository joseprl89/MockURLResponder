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
		guard let dataJSONArgument = try? JSONSerialization.data(withJSONObject: jsonArguments) else {
			fatalError("Couldn't serialise arguments: \(jsonArguments)")
		}

        let stringJSONArgument = String(data: dataJSONArgument, encoding: .utf8)!
        return [
            "--mock-url-response=\(stringJSONArgument)"
        ]
    }

    public var jsonArguments: [String: Any] {
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

    public func respond(to path: String, method: HTTPMethod = .GET) -> MockURLResponseBuilder {
        return MockURLResponseBuilder(configurator: self, path: path, method: method.rawValue)
    }

    public func respond(to path: String, method: String) -> MockURLResponseBuilder {
        return MockURLResponseBuilder(configurator: self, path: path, method: method)
    }
}
