//
//  MockURLResponder.swift
//  MockURLResponderKit
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import UIKit

private var responseHosts: [MockURLHostResponse]!

public class MockURLResponder: URLProtocol {

    public enum MockingBehaviour {
        case allowNonMockedNetworkCalls
        case dropNonMockedNetworkCalls
        case preventNonMockedNetworkCalls
    }

    /**
     * Set to true if you want to allow your tests to hit the network
     *    while the Mock URL responder is activated.
     * When set to false, the URLProtocol implementation will crash your
     * app if a network request sent to an unexpected host is fired.
     */
    public static var mockingBehaviour: MockingBehaviour = .preventNonMockedNetworkCalls

    public static func setUp(with arguments: [String] = ProcessInfo.processInfo.arguments) {
        let tempResponseHosts = arguments.flatMap { MockURLHostResponse.from(argument: $0) }

        responseHosts = tempResponseHosts

        URLProtocol.registerClass(self)
    }

    public static func tearDown() {
        URLProtocol.unregisterClass(self)
        responseHosts = nil
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        switch mockingBehaviour {
        case .allowNonMockedNetworkCalls:
            return matchingResponse(forRequest: request) != nil
        case .dropNonMockedNetworkCalls, .preventNonMockedNetworkCalls:
            return true
        }
    }

    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        guard let mockResponse = matchingResponse(forRequest: request) else {
            switch MockURLResponder.mockingBehaviour {
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
            let response = HTTPURLResponse(url: request.url!, statusCode: mockResponse.status, httpVersion: nil, headerFields: mockResponse.headerFields)
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
    let host = responseHosts.first(where: {
        $0.host == request.url?.host && $0.scheme == request.url?.scheme
    })

    return host?.responses.first(where: {
        return $0.method == request.httpMethod && $0.path == request.url?.path && $0.repetitionsLeft > 0
    })
}
