//
//  File.swift
//  MockURLResponderKit
//
//  Created by Josep Rodríguez López on 19/11/2017.
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
