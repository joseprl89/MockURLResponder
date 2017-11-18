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

class MockURLHostResponse {
    let scheme: String
    let host: String
    let responses: [MockURLResponse]

    init(scheme: String, host: String, responses: [MockURLResponse]) {
        self.scheme = scheme
        self.host = host
        self.responses = responses
    }

    static func from(argument: String) -> MockURLHostResponse? {
        guard argument.starts(with: "--mock-url-response=") else {
            return nil
        }

        let argumentData = argument.replacingOccurrences(of: "--mock-url-response=", with: "").data(using: .ascii)!
        let jsonArgument = try! JSONSerialization.jsonObject(with: argumentData) as! [String: Any]

        return from(jsonArgument: jsonArgument)
    }

    static func from(jsonArgument argument: [String: Any]) -> MockURLHostResponse {
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

class MockURLResponse {

    let path: String
    let method: String
    let dropConnection: Bool
    let status: Int
    let headerFields: [String: String]
    let body: String
    let delay: TimeInterval
    private(set) var repetitionsLeft: Int

    init(path: String, method: String, dropConnection: Bool, status: Int, headerFields: [String: String], body: String, repetitionsLeft: Int, delay: TimeInterval) {
        self.path = path
        self.dropConnection = dropConnection
        self.method = method
        self.status = status
        self.headerFields = headerFields
        self.body = body
        self.repetitionsLeft = repetitionsLeft
        self.delay = delay
    }

    var jsonArguments: [String: Any] {
        return [
            "path": path,
            "method": method,
            "dropConnection": dropConnection ? "true" : "false",
            "status": status,
            "headerFields": headerFields,
            "body": body,
            "repetitions": repetitionsLeft,
            "delay": delay
        ]
    }

    static func from(argument: [String: Any]) -> MockURLResponse {
        guard let path = argument["path"] as? String,
            let method = argument["method"] as? String,
            let status = argument["status"] as? Int,
            let headerFields = argument["headerFields"] as? [String: String],
            let repetitionsLeft = argument["repetitions"] as? Int,
            let delay = argument["delay"] as? TimeInterval,
            let body = argument["body"] as? String else {
                fatalError("Unexpected nil values in MockURLResponse. Argument: \(argument)")
        }

        let dropConnection = argument["dropConnection"] as? String == "true"

        return MockURLResponse(
            path: path,
            method: method,
            dropConnection: dropConnection,
            status: status,
            headerFields: headerFields,
            body: body,
            repetitionsLeft: repetitionsLeft,
            delay: delay
        )
    }

    func consume() {
        repetitionsLeft -= 1
    }
}

public class MockURLResponseBuilder {

    private let configurator: MockURLResponderConfigurator
    private let path: String
    private let method: String
    private var status = 200
    private var body: String = ""
    private var headerFields: [String: String] = [:]
    private var delay: TimeInterval = 0
    private var dropConnection = false

    init(configurator: MockURLResponderConfigurator, path: String, method: String) {
        self.configurator = configurator
        self.path = path
        self.method = method
    }

    public func with(body: String) -> MockURLResponseBuilder {
        self.body = body
        return self
    }

    public func with(status: Int) -> MockURLResponseBuilder {
        self.status = status
        return self
    }

    public func with(value: String, forHeaderField key: String) -> MockURLResponseBuilder {
        headerFields[key] = value
        return self
    }

    public func withDroppedRequest() -> MockURLResponseBuilder {
        dropConnection = true
        return self
    }

    public func with(delay: TimeInterval) -> MockURLResponseBuilder {
        self.delay = delay
        return self
    }

    public func once() {
        self.configurator.responses += [buildResponse(repetitions: 1)]
    }

    public func times(_ repetitions: Int) {
        self.configurator.responses += [buildResponse(repetitions: repetitions)]
    }

    public func always() {
        self.configurator.responses += [buildResponse(repetitions: Int.max)]
    }

    private func buildResponse(repetitions: Int) -> MockURLResponse {
        return MockURLResponse(path: path, method: method, dropConnection: dropConnection, status:status, headerFields: headerFields, body: body, repetitionsLeft: repetitions, delay: delay)
    }
}

public class MockURLResponderConfigurator {

    private let scheme: String
    private let host: String
    fileprivate var responses: [MockURLResponse] = []

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
