//
//  MockURLProtocol.swift
//  MockURLResponderKit
//
//  Created by Josep Rodríguez López on 19/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

public class MockURLProtocol: URLProtocol {

	override public class func canInit(with request: URLRequest) -> Bool {
        guard isHTTP(request) else {
            return false
        }

		switch MockURLResponder.Configuration.mockingBehaviour {
		case .allowNonMockedNetworkCalls:
			return matchingResponse(forRequest: request) != nil
		case .dropNonMockedNetworkCalls, .preventNonMockedNetworkCalls:
			return true
		}
	}

    private class func isHTTP(_ request: URLRequest) -> Bool {
        return ["http", "https"].contains(request.url?.scheme ?? "")
    }

	override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}

	public override func startLoading() {
		guard let mockResponse = matchingResponse(forRequest: request) else {
			switch MockURLResponder.Configuration.mockingBehaviour {
			case .preventNonMockedNetworkCalls:
				fatalError("Couldn't locate a valid response to \(request)")
			default:
				client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLRespoderKit", code: 1001, userInfo: nil))
				client?.urlProtocolDidFinishLoading(self)
			}
			return
		}

		mockResponse.consume()

		func respond() {
			defer {
				client?.urlProtocolDidFinishLoading(self)
			}

			guard !mockResponse.dropConnection else {
				client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLRespoderKit", code: 1001, userInfo: nil))
				return
			}

			let bodyData = mockResponse.body.data(using: .ascii)!
			let response = HTTPURLResponse(url: request.url!, statusCode: mockResponse.status,
										   httpVersion: nil, headerFields: mockResponse.headerFields)
			client?.urlProtocol(self, didLoad: bodyData)
			client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
		}

		if mockResponse.delay > 0 {
			DispatchQueue.global().asyncAfter(deadline: .now() + mockResponse.delay, execute: respond)
		} else {
			respond()
		}
	}

	public override func stopLoading() {
		// not supported
	}
}

private func matchingResponse(forRequest request: URLRequest) -> MockURLResponse? {
	let hosts = MockURLResponder.Configuration.responseHosts.filter {
		$0.host == request.url?.host && $0.scheme == request.url?.scheme
	}

    return hosts.flatMap { $0.responses }.first(where: {
        return $0.method == request.httpMethod && $0.path == request.url?.path
            && queries(of: request, match: $0.expectedQueryFields) && headers(of: request, match: $0.expectedHeaderFields) &&
            $0.repetitionsLeft > 0
	})
}

private func queries(of request: URLRequest, match expectedQueryFields: [String: String]) -> Bool {
    guard let url = request.url,
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
        let queryItems = components.queryItems else {
        return expectedQueryFields.isEmpty
    }
    
    
    let matchedKeys = expectedQueryFields.keys.filter { (queryKey) -> Bool in
        return queryItems.contains(where: { $0.name == queryKey && $0.value == expectedQueryFields[queryKey] })
    }
    
    return matchedKeys.count == expectedQueryFields.count
}

private func headers(of request: URLRequest, match expectedHeaderFields: [String: String]) -> Bool {
    let matchedKeys = expectedHeaderFields.keys.filter { (header) -> Bool in
        return request.allHTTPHeaderFields?.contains(where: { $0.key == header && $0.value == expectedHeaderFields[header] }) ?? false
    }

    return matchedKeys.count == expectedHeaderFields.count
}
