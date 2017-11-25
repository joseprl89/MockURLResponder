//
//  MockURLRecorderAcceptanceTests.swift
//  MockURLResponderTests
//
//  Created by Josep Rodríguez López on 23/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest
import MockURLResponder
import MockURLResponderTestAPI
import MockURLRecorder

internal class MockURLRecorderAcceptanceTests: XCTestCase {

    let url = URL(string: "http://www.google.com/search?q=something")!

    func testRecordsGetCall() {
        MockURLResponder.setUp(with: mockFor(url, method: "GET", withResponse: "Hi!"))
        recordingSession()

        _ = get(url.absoluteString)

        XCTAssertEqual(MockURLRecorder.replayCode, contentsOf("getCall", ofType: "txt"))
    }

    func testRecordsGetTwoCallsDifferentResponse() {
        MockURLResponder.setUp(with:
            mockFor(url, method: "GET", withResponse: "Hi 1") +
            mockFor(url, method: "GET", withResponse: "Hi 2")
        )
        recordingSession()

        _ = get(url.absoluteString)
        _ = get(url.absoluteString)

        XCTAssertEqual(MockURLRecorder.replayCode, contentsOf("getTwoCallsDifferentResponses", ofType: "txt"))
    }

    func testRecordsGetTwoCallsSameResponseCollapsing() {
        MockURLResponder.setUp(with:
            mockFor(url, method: "GET", withResponse: "Hi") +
            mockFor(url, method: "GET", withResponse: "Hi")
        )
        recordingSession()

        _ = get(url.absoluteString)
        _ = get(url.absoluteString)

        XCTAssertEqual(MockURLRecorder.replayCode, contentsOf("getTwoCallsSameResponses", ofType: "txt"))
    }
}
