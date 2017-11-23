//
//  FileSystem.swift
//  MockURLResponderTests
//
//  Created by Josep Rodríguez López on 23/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest

func contentsOf(_ fileName: String, ofType ext: String) -> String {
    guard let url = Bundle(for: MockURLRecorderAcceptanceTests.self).url(forResource: fileName, withExtension: ext) else {
        XCTFail("No such file \(fileName).\(ext)")
        return ""
    }
    return get(url.absoluteString)
}
