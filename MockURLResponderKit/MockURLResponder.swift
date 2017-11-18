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

    public static func setUp(with arguments: [String] = ProcessInfo.processInfo.arguments) {
        let tempResponseHosts = arguments.map { MockURLHostResponse.from(argument: try! JSONSerialization.jsonObject(with: $0.data(using: .ascii)!) as! [String: Any]) }

        responseHosts = tempResponseHosts

        URLProtocol.registerClass(self)
    }

    public static func tearDown() {
        URLProtocol.unregisterClass(self)
        responseHosts = nil
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        return matchingResponse(forRequest: request) != nil
    }

    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        guard let mockResponse = matchingResponse(forRequest: request) else {
            fatalError("Couldn't locate a valid response to \(request)")
        }

        defer {
            client?.urlProtocolDidFinishLoading(self)
        }

        let bodyData = mockResponse.body.data(using: .ascii)!
        let response = HTTPURLResponse(url: request.url!, statusCode: mockResponse.status, httpVersion: nil, headerFields: mockResponse.headerFields)
        client?.urlProtocol(self, didLoad: bodyData)
        client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
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
        return $0.method == request.httpMethod && $0.path == request.url?.path
    })
}
