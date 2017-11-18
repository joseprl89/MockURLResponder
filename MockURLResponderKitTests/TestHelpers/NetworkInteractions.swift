//
//  NetworkInteractions.swift
//  MockURLResponderKitTests
//
//  Created by Hannah Paulson on 18/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest
import MockURLResponderKit

func get(_ url: String) -> String {
    return submitRequest(method: .GET, url: url)
}

func post(_ url: String) -> String {
    return submitRequest(method: .POST, url: url)
}

func submitRequest(method: HTTPMethod, url: String) -> String {
    guard let urlBuilt = URL(string: url) else {
        fatalError("Couldn't create a url request from \(url)")
    }

    var urlRequest = URLRequest(url: urlBuilt)
    urlRequest.httpMethod = method.rawValue

    let semaphore = DispatchSemaphore(value: 0)

    var result: String!
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        XCTAssertNil(error)
        XCTAssertNotNil(data)
        result = String(data: data!, encoding: .ascii)

        semaphore.signal()
    }.resume()

    semaphore.wait()

    return result
}
