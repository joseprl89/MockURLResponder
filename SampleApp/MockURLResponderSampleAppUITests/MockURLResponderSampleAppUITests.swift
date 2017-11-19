//
//  MockURLResponderSampleAppUITests.swift
//  MockURLResponderSampleAppUITests
//
//  Created by Josep Rodríguez López on 19/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest
import MockURLResponderTestAPI

class MockURLResponderSampleAppUITests: XCTestCase {
    
    func test_mocksNetwork() {
		let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.google.com")
		
		configurator.respond(to: "/", method: "GET")
			.with(body: "Mock URL Responder is great!")
			.always()
		
		let application = XCUIApplication()
		application.launchArguments = configurator.arguments
		application.launch()
		
		let textAppeared = application.staticTexts["Mock URL Responder is great!"].waitForExistence(timeout: 1)
		
		XCTAssert(textAppeared)
    }
}
