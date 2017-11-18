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
            .set(body: body)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        XCTAssertEqual(get("https://www.w3.org/path?q=query#fragment"), body)
    }

    func test_mocksPOSTWithoutConflictOnGet() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .set(body: body)
            .once()

        configurator.respond(to: "/path", method: "POST")
            .set(body: "Received from POST")
            .once()

        MockURLResponder.setUp(with: configurator.arguments)

        let bodyReceived =  post("https://www.w3.org/path?q=query#fragment")
        XCTAssertEqual(bodyReceived, "Received from POST")
        XCTAssertNotEqual(bodyReceived, body)
    }

    func test_mocksServerCanMockStatusCode() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")
        
        configurator.respond(to: "/path", method: "GET")
            .set(body: body)
            .set(status: 400)
            .once()
        
        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(getStatus("https://www.w3.org/path?q=query#fragment"), 400)
    }

    func test_mocksServerDefaultsTo200() {
        let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

        configurator.respond(to: "/path", method: "GET")
            .set(body: body)
            .once()

        MockURLResponder.setUp(with: configurator.arguments)
        XCTAssertEqual(getStatus("https://www.w3.org/path?q=query#fragment"), 200)
    }
    
}
