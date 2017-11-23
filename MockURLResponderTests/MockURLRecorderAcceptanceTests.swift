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

class MockURLRecorderAcceptanceTests: XCTestCase {

    let url = URL(string: "http://www.google.com/search?q=something")!

    func testRecordsGetCall() {
        MockURLResponder.setUp(with: mockFor(url, method: "GET", withResponse: "Hi!"))
        recordingSession()

        _ = get(url.absoluteString)

        XCTAssertEqual(MockURLRecorder.replayCode, contentsOf("getCall", ofType: "txt"))
    }
}
