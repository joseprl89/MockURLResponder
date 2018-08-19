//
//  NetworkInteractions.swift
//  MockURLResponderKitTests
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest
import MockURLResponder

internal typealias SuccessfulHTTPResponse = (status: Int, body: String, httpHeaders: [AnyHashable: Any])
internal typealias FailedHTTPResponse = Error
internal typealias HTTPResponse = Result<SuccessfulHTTPResponse, FailedHTTPResponse>

internal func get(_ url: String, headerFields: [String: String] = [:]) -> HTTPResponse {
    return submitRequest(method: .GET, url: url, headerFields: headerFields)
}

internal func post(_ url: String, headerFields: [String: String] = [:]) -> HTTPResponse {
    return submitRequest(method: .POST, url: url, headerFields: headerFields)
}

internal func submitRequest(method: HTTPMethod, url: String, headerFields: [String: String]) -> HTTPResponse {
    guard let urlBuilt = URL(string: url) else {
        fatalError("Couldn't create a url request from \(url)")
    }

    var urlRequest = URLRequest(url: urlBuilt)
    urlRequest.httpMethod = method.rawValue
    urlRequest.allHTTPHeaderFields = headerFields
    let semaphore = DispatchSemaphore(value: 0)

    var result: HTTPResponse = .failure(value: NSError(domain: "No response received", code: 111, userInfo: nil))
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        defer { semaphore.signal() }

        if let error = error {
            result = .failure(value: error)
            return
        }

        guard let data = data, let body = String(data: data, encoding: .utf8) else {
            fatalError("Couldn't load the body from the data provided.")
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Response \(String(describing: response)) was not an HTTPURLResponse")
        }

        let responseStruct = (
            status: httpResponse.statusCode,
            body: body,
            httpHeaders: httpResponse.allHeaderFields
        )

        result = .success(value: responseStruct)
    }.resume()

    semaphore.wait()

    return result
}
