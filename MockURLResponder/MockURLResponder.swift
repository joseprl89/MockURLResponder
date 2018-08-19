//
//  MockURLResponder.swift
//  MockURLResponderKit
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

public class MockURLResponder {

	public enum MockingBehaviour {
		case allowNonMockedNetworkCalls
		case dropNonMockedNetworkCalls
		case preventNonMockedNetworkCalls
	}

	public struct Configuration {
		static internal var responseHosts: [MockURLHostResponse] = []
		static public var mockingBehaviour: MockingBehaviour = .preventNonMockedNetworkCalls
	}

    public static func setUp(with arguments: [String] = ProcessInfo.processInfo.arguments,
                             setupDefaultSessionConfiguration: Bool = true) {
        let tempResponseHosts = arguments.compactMap { MockURLHostResponse.from(argument: $0) }

        Configuration.responseHosts = tempResponseHosts

        if setupDefaultSessionConfiguration {
            URLProtocol.registerClass(MockURLProtocol.self)
        }
    }

    public static func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        Configuration.responseHosts = []
    }

}
