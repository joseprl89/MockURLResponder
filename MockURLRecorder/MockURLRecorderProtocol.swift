//
//  MockURLRecorderProtocol.swift
//  MockURLRecorder
//
//  Created by Josep Rodríguez López on 23/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import UIKit

private let recordingKey = "requestBeingRecorded"

public class MockURLRecorderProtocol: URLProtocol {

    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: nil, client: client)
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url, isHTTP(url), !isRecording(request) else {
            return false
        }
        return true
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        let recordedRequest = requestMarkedAsLoading(with: request)
        URLSession.shared.dataTask(with: recordedRequest) { data, response, error in
            defer {
                self.client?.urlProtocolDidFinishLoading(self)
            }

            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                fatalError("Should never occur")
            }

            MockURLRecorder.record(response, for: recordedRequest, data: data)

            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }

            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }.resume()
    }

    public override func stopLoading() {
        // The ship has sailed.
    }

    private func requestMarkedAsLoading(with request: URLRequest) -> URLRequest {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            fatalError("Mutable copy of URLRequest should always be convertible to NSMutableURLRequest.")
        }

        markRequestAsBeingRecorded(mutableRequest)

        return mutableRequest as URLRequest
    }

    private func markRequestAsBeingRecorded(_ mutableRequest: NSMutableURLRequest) {
        MockURLRecorderProtocol.setProperty(true, forKey: recordingKey, in: mutableRequest)
    }

    private class func isHTTP(_ url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }
        return ["http", "https"].contains(scheme)
    }

    private class func isRecording(_ request: URLRequest) -> Bool {
        return property(forKey: recordingKey, in: request) as? Bool ?? false
    }
}
