//
//  ConfiguratorDSL.swift
//  MockURLResponderTests
//
//  Created by Josep Rodríguez López on 23/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import MockURLRecorder
import MockURLResponderTestAPI

internal func mockFor(_ url: URL, method: String, withResponse response: String) -> [String] {
    guard let scheme = url.scheme, let host = url.host else {
        fatalError("URL \(url) did not contain a host or a scheme.")
    }
    let configurator = MockURLResponderConfigurator(scheme: scheme, host: host)

    configurator.respond(to: url.path)
        .when(method: method)
        .with(body: response)
        .once()

    return configurator.arguments
}

internal func recordingSession() {
    MockURLRecorder.clearSession()
    MockURLRecorder.register()
}
