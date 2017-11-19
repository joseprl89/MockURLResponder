//
//  MockURLResponder.swift
//  MockURLResponderKit
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import UIKit

public class MockURLResponder {
	
	public struct Configuration {
		static internal var responseHosts: [MockURLHostResponse]!
		static internal var mockingBehaviour: MockingBehaviour = .preventNonMockedNetworkCalls
		
		public enum MockingBehaviour {
			case allowNonMockedNetworkCalls
			case dropNonMockedNetworkCalls
			case preventNonMockedNetworkCalls
		}
	}

    public static func setUp(with arguments: [String] = ProcessInfo.processInfo.arguments) {
        let tempResponseHosts = arguments.flatMap { MockURLHostResponse.from(argument: $0) }

        Configuration.responseHosts = tempResponseHosts

        URLProtocol.registerClass(MockURLProtocol.self)
    }

    public static func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        Configuration.responseHosts = nil
    }

}
