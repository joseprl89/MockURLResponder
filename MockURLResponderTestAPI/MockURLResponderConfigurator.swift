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

        guard let stringJSONArgument = String(data: dataJSONArgument, encoding: .utf8) else {
            fatalError("Couldn\t convert Data to String using utf8.")
        }

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

    public func respond(to path: String) -> MockURLResponseBuilder {
        return MockURLResponseBuilder(configurator: self, path: path)
    }
}
