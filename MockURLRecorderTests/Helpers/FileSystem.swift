//
//  FileSystem.swift
//  MockURLResponderTests
//
//  Created by Josep Rodríguez López on 23/11/2017.
//  Copyright © 2017 com.github.joseprl89. All rights reserved.
//

import XCTest

internal func contentsOf(_ fileName: String, ofType ext: String) -> String {
    let bundle = Bundle(for: MockURLRecorderAcceptanceTests.self)
    guard let url = bundle.url(forResource: fileName, withExtension: ext),
        let data = try? Data(contentsOf: url) else {
        XCTFail("No such file \(fileName).\(ext)")
        return ""
    }

    guard let contents = String(data: data, encoding: .utf8) else {
         fatalError("Couldn't convert contents of file \(fileName).\(ext) to a utf8 string.")
    }

    return contents
}
