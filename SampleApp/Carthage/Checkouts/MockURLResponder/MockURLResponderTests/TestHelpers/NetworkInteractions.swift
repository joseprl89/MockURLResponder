//
//  NetworkInteractions.swift
//  MockURLResponderKitTests
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest
import MockURLResponder

func get(_ url: String) -> String {
    return submitRequest(method: .GET, url: url)
}

func post(_ url: String) -> String {
    return submitRequest(method: .POST, url: url)
}

func getStatus(_ url: String) -> Int {
    guard let urlBuilt = URL(string: url) else {
        fatalError("Couldn't create a url request from \(url)")
    }

    var urlRequest = URLRequest(url: urlBuilt)
    urlRequest.httpMethod = HTTPMethod.GET.rawValue

    let semaphore = DispatchSemaphore(value: 0)

    var resultStatus: Int!

    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        XCTAssertNil(error)
        XCTAssertNotNil(data)

        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Response \(String(describing: response)) was not an HTTPURLResponse")
        }
        resultStatus = httpResponse.statusCode
        semaphore.signal()
        }.resume()

    semaphore.wait()

    return resultStatus
}

func getError(_ url: String) -> Error {
    guard let urlBuilt = URL(string: url) else {
        fatalError("Couldn't create a url request from \(url)")
    }

    var urlRequest = URLRequest(url: urlBuilt)
    urlRequest.httpMethod = HTTPMethod.GET.rawValue

    let semaphore = DispatchSemaphore(value: 0)

    var result: Error!

    URLSession.shared.dataTask(with: urlRequest) { data, _, error in
        XCTAssertNotNil(error)
        XCTAssertNil(data)

        result = error
        semaphore.signal()
    }.resume()

    semaphore.wait()

    return result
}

func getHeaders(_ url: String) -> [String: String] {
    guard let urlBuilt = URL(string: url) else {
        fatalError("Couldn't create a url request from \(url)")
    }

    var urlRequest = URLRequest(url: urlBuilt)
    urlRequest.httpMethod = HTTPMethod.GET.rawValue

    let semaphore = DispatchSemaphore(value: 0)

    var result: [String: String]!

    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        XCTAssertNil(error)
        XCTAssertNotNil(data)

        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Response \(String(describing: response)) was not an HTTPURLResponse")
        }
        result = httpResponse.allHeaderFields as? [String: String]
        semaphore.signal()
    }.resume()

    semaphore.wait()

    return result
}

func submitRequest(method: HTTPMethod, url: String) -> String {
    guard let urlBuilt = URL(string: url) else {
        fatalError("Couldn't create a url request from \(url)")
    }

    var urlRequest = URLRequest(url: urlBuilt)
    urlRequest.httpMethod = method.rawValue

    let semaphore = DispatchSemaphore(value: 0)

    var result: String!
    URLSession.shared.dataTask(with: urlRequest) { data, _, error in
        XCTAssertNil(error)
        XCTAssertNotNil(data)
        result = String(data: data!, encoding: .utf8)

        semaphore.signal()
    }.resume()

    semaphore.wait()

    return result
}
