//
//  MockURLResponseBuilder.swift
//  MockURLResponderKit
//
//  Created by Josep Rodríguez López on 19/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import Foundation

public class MockURLResponseBuilder {

	private let configurator: MockURLResponderConfigurator
	private let path: String
	private var method: String = HTTPMethod.GET.rawValue
	private var status = 200
	private var body: String = ""
	private var headerFields: [String: String] = [:]
    private var expectedQueryFields: [String: String] = [:]
    private var expectedHeaderFields: [String: String] = [:]
	private var delay: TimeInterval = 0
	private var dropConnection = false

	init(configurator: MockURLResponderConfigurator, path: String) {
		self.configurator = configurator
		self.path = path
	}
    
    // Response matching
    
    public func when(value: String, forQueryField key: String) -> MockURLResponseBuilder {
        expectedQueryFields[key] = value
        return self
    }
    
    public func when(value: String, forHeaderField key: String) -> MockURLResponseBuilder {
        expectedHeaderFields[key] = value
        return self
    }
    
    public func when(method: HTTPMethod) -> MockURLResponseBuilder {
        return when(method: method.rawValue)
    }
    
    public func when(method: String) -> MockURLResponseBuilder {
        self.method = method
        return self
    }
    
    // Response configuration
    
    public func with(body: String) -> MockURLResponseBuilder {
        self.body = body
        return self
    }
    
    public func with(resource: String, ofType type: String, directory: String? = nil,
                     localization: String? = nil, bundle: Bundle = .main) -> MockURLResponseBuilder {
        let url = bundle.url(
            forResource: resource,
            withExtension: type,
            subdirectory: directory,
            localization: localization
        )!
        
        return with(bodyFromURL: url)
    }
    
    public func with(bodyFromURL url: URL) -> MockURLResponseBuilder {
        guard let urlContents = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("Couldn't read contents of url \(url)")
        }
        
        self.body = urlContents
        return self
    }
    
    public func with(status: Int) -> MockURLResponseBuilder {
        self.status = status
        return self
    }
    
    public func with(value: String, forHeaderField key: String) -> MockURLResponseBuilder {
        headerFields[key] = value
        return self
    }
    
    public func withDroppedRequest() -> MockURLResponseBuilder {
        dropConnection = true
        return self
    }
    
    public func with(delay: TimeInterval) -> MockURLResponseBuilder {
        self.delay = delay
        return self
    }

    // Repetitions

	public func once() {
		self.configurator.responses += [buildResponse(repetitions: 1)]
	}

	public func times(_ repetitions: Int) {
		self.configurator.responses += [buildResponse(repetitions: repetitions)]
	}

	public func always() {
		self.configurator.responses += [buildResponse(repetitions: Int.max)]
	}

	private func buildResponse(repetitions: Int) -> MockURLResponse {
        return MockURLResponse(path: path, method: method, expectedQueryFields: expectedQueryFields,
                               expectedHeaderFields: expectedHeaderFields, dropConnection: dropConnection,
                               status: status, headerFields: headerFields, body: body,
                               repetitionsLeft: repetitions, delay: delay)
	}
}
