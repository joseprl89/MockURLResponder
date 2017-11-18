//
//  MockURLResponderConfigurator.swift
//  MockURLResponderConfiguratorKit
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case HEAD
}

struct MockURLHostResponse {
    let scheme: String
    let host: String
    let responses: [MockURLResponse]

    static func from(argument: [String: Any]) -> MockURLHostResponse {
        guard let scheme = argument["scheme"] as? String,
            let host = argument["host"] as? String,
            let responses = argument["responses"] as? [[String: Any]] else {
                fatalError("Unexpected nil values in MockURLHostResponse. Argument: \(argument)")
        }

        return MockURLHostResponse(
            scheme: scheme,
            host: host,
            responses: responses.map { MockURLResponse.from(argument: $0) }
        )
    }

}

struct MockURLResponse {

    let path: String
    let method: String
    let body: String

    var jsonArguments: [String: Any] {
        return [
            "path": path,
            "method": method,
            "body": body
        ]
    }

    static func from(argument: [String: Any]) -> MockURLResponse {
        guard let path = argument["path"] as? String,
            let method = argument["method"] as? String,
            let body = argument["body"] as? String else {
                fatalError("Unexpected nil values in MockURLResponse. Argument: \(argument)")
        }

        return MockURLResponse(path: path, method: method, body: body)
    }
}

public class MockURLResponseBuilder {

    private let configurator: MockURLResponderConfigurator
    private let path: String
    private let method: String
    private var body: String = ""

    init(configurator: MockURLResponderConfigurator, path: String, method: String) {
        self.configurator = configurator
        self.path = path
        self.method = method
    }


    public func with(_ body: String) -> MockURLResponseBuilder {
        self.body = body
        return self
    }

    public func once() {
        self.configurator.responses += [buildResponse()]
    }

    private func buildResponse() -> MockURLResponse {
        return MockURLResponse(path: path, method: method, body: body)
    }
}

public class MockURLResponderConfigurator {

    private let scheme: String
    private let host: String
    fileprivate var responses: [MockURLResponse] = []

    public var arguments: [String] {
        return [String(data: try! JSONSerialization.data(withJSONObject: jsonArguments), encoding: .ascii)!]
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

    /// TODO Better API
    public func respond(to path: String, method: String = HTTPMethod.GET.rawValue) -> MockURLResponseBuilder {
        return MockURLResponseBuilder(configurator: self, path: path, method: method)
    }
}
