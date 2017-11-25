//
//  MockURLResponderAcceptanceTests.swift
//  MockURLResponderKitTests
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest
import MockURLResponder
import MockURLResponderTestAPI

internal class MockURLResponderAcceptanceTests: XCTestCase {

    let body = "Hello World!"

    override func tearDown() {
        MockURLResponder.tearDown()
    }

    func testSingleCall() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: body)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        XCTAssertEqual(get("https://www.w3.org/path?q=query#fragment"), body)
    }

    func testPOSTWithoutConflictOnGet() {
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

    func testMocksStatusCode() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: body)
            .with(status: 400)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(getStatus("https://www.w3.org/path?q=query#fragment"), 400)
    }

    func testDefaultsTo200() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: body)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(getStatus("https://www.w3.org/path?q=query#fragment"), 200)
    }

    func testMocksMultipleHostsAtOnce() {
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

    func testMocksMultiplePathsAtOnce() {
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

    func testMocksMultipleResponsesSerially() {
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

    func testRepeatsResponses() {
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

    func testRepeatsResponsesForever() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: "one")
            .always()

        MockURLResponder.setUp(with: configurator.arguments)

        for _ in 0..<100 {
            XCTAssertEqual(get("https://www.w3.org/path"), "one")
        }
    }

    func testDropsConnections() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .withDroppedRequest()
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        XCTAssertNotNil(getError("https://www.w3.org/path"))
    }

    func testAddsDelay() {
        let delay: TimeInterval = 0.2
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(delay: delay)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        let startTime = Date()
        XCTAssertNotNil(get("https://www.w3.org/path"))
        let endTime = Date()

        XCTAssertGreaterThan(endTime.timeIntervalSince(startTime), delay)
    }

    func testIsCompatibleWithExtraArguments() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(body: "response")
            .once()

        MockURLResponder.setUp(with: configurator.arguments + ["-FIRDebugEnabled"])

        XCTAssertEqual(get("https://www.w3.org/path"), "response")
    }

    func testSupportsFileAsBodyResponse() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .with(resource: "test", ofType: "json", bundle: Bundle(for: MockURLResponderAcceptanceTests.self))
            .once()

        MockURLResponder.setUp(with: configurator.arguments + ["-FIRDebugEnabled"])

        XCTAssertEqual(get("https://www.w3.org/path"), "{ \"test\": \"passed\" }\n")
    }
}
