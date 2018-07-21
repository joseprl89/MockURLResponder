//
//  MockURLResponse.swift
//  MockURLResponderKit
//
//  Created by Josep Rodríguez López on 19/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

public class MockURLResponse {

	let path: String
	let method: String
	let dropConnection: Bool
	let status: Int
	let headerFields: [String: String]
	let body: String
	let delay: TimeInterval
    let expectedQueryFields: [String: String]
    let expectedHeaderFields: [String: String]
	private(set) var repetitionsLeft: Int

    public init(path: String,
                method: String,
                expectedQueryFields: [String: String],
                expectedHeaderFields: [String: String],
                dropConnection: Bool,
                status: Int,
                headerFields: [String: String],
                body: String,
                repetitionsLeft: Int,
                delay: TimeInterval) {
		self.path = path
		self.dropConnection = dropConnection
		self.method = method
		self.status = status
		self.headerFields = headerFields
		self.body = body
		self.repetitionsLeft = repetitionsLeft
		self.delay = delay
        self.expectedQueryFields = expectedQueryFields
        self.expectedHeaderFields = expectedHeaderFields
	}

	public var jsonArguments: [String: Any] {
		return [
			"path": path,
			"method": method,
			"dropConnection": dropConnection ? "true" : "false",
			"status": status,
			"headerFields": headerFields,
			"body": body,
			"repetitions": repetitionsLeft,
			"delay": delay,
            "expectedQueryFields": expectedQueryFields,
            "expectedHeaderFields": expectedHeaderFields
		]
	}

	static func from(argument: [String: Any]) -> MockURLResponse {
		guard let path = argument["path"] as? String,
			let method = argument["method"] as? String,
			let status = argument["status"] as? Int,
			let headerFields = argument["headerFields"] as? [String: String],
			let repetitionsLeft = argument["repetitions"] as? Int,
			let delay = argument["delay"] as? TimeInterval,
			let body = argument["body"] as? String,
            let expectedQueryFields = argument["expectedQueryFields"] as? [String: String],
            let expectedHeaderFields = argument["expectedHeaderFields"] as? [String: String] else {
				fatalError("Unexpected nil values in MockURLResponse. Argument: \(argument)")
		}

		let dropConnection = argument["dropConnection"] as? String == "true"

		return MockURLResponse(
			path: path,
			method: method,
            expectedQueryFields: expectedQueryFields,
            expectedHeaderFields: expectedHeaderFields,
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
