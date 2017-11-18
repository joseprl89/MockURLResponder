//
//  MockURLResponderAcceptanceTests.swift
//  MockURLResponderKitTests
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest
import MockURLResponderKit

class MockURLResponderAcceptanceTests: XCTestCase {

    let body = "Hello World!"

    override func tearDown() {
        MockURLResponder.tearDown()
    }

    func test_mocksSingleCall() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: body)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        XCTAssertEqual(get("https://www.w3.org/path?q=query#fragment"), body)
    }

    func test_mocksPOSTWithoutConflictOnGet() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: body)
            .once()

        configurator.respond(to: "/path", method: "POST")
            .with(body: "Received from POST")
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        let bodyReceived =  post("https://www.w3.org/path?q=query#fragment")
        XCTAssertEqual(bodyReceived, "Received from POST")
        XCTAssertNotEqual(bodyReceived, body)
    }

    func test_mocksServerCanMockStatusCode() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")
        
        configurator.respond(to: "/path", method: "GET")
            .with(body: body)
            .with(status: 400)
            .once()
        
        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(getStatus("https://www.w3.org/path?q=query#fragment"), 400)
    }

    func test_mocksServerDefaultsTo200() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: body)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(getStatus("https://www.w3.org/path?q=query#fragment"), 200)
    }

    func test_mocksServerCanMockMultipleHostsAtOnce() {
        let w3OrgConfigurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        w3OrgConfigurator.respond(to: "/path", method: "GET")
            .with(body: "w3")
            .once()

        let googleConfigurator = MockURLResponderConfigurator(scheme: "https", host: "www.google.com")

        googleConfigurator.respond(to: "/path", method: "GET")
            .with(body: "google")
            .once()

        MockURLResponder.setUp(with: w3OrgConfigurator.arguments + googleConfigurator.arguments)
        XCTAssertEqual(get("https://www.google.com/path"), "google")
        XCTAssertEqual(get("https://www.w3.org/path"), "w3")
    }

    func test_mocksServerCanMockMultiplePathsAtOnce() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path/one", method: "GET")
            .with(body: "one")
            .once()

        configurator.respond(to: "/path/two", method: "GET")
            .with(body: "two")
            .once()

        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(get("https://www.w3.org/path/one"), "one")
        XCTAssertEqual(get("https://www.w3.org/path/two"), "two")
    }

    func test_mocksServerCanMockMultipleResponsesSerially() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: "one")
            .once()

        configurator.respond(to: "/path", method: "GET")
            .with(body: "two")
            .once()

        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(get("https://www.w3.org/path"), "one")
        XCTAssertEqual(get("https://www.w3.org/path"), "two")
    }

    func test_mocksServerCanRepeatResponses() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: "one")
            .times(2)

        configurator.respond(to: "/path", method: "GET")
            .with(body: "three")
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        XCTAssertEqual(get("https://www.w3.org/path"), "one")
        XCTAssertEqual(get("https://www.w3.org/path"), "one")
        XCTAssertEqual(get("https://www.w3.org/path"), "three")
    }

    func test_mocksServerCanRepeatResponsesForever() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: "one")
            .always()

        MockURLResponder.setUp(with: configurator.arguments)

        for _ in 0..<100 {
            XCTAssertEqual(get("https://www.w3.org/path"), "one")
        }
    }

    func test_canDropConnections() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .withDroppedRequest()
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        XCTAssertNotNil(getError("https://www.w3.org/path"))
    }
}
