//
//  Result.swift
//  MockURLResponder
//
//  Created by Josep Rodriguez on 19/08/2018.
//  Copyright © 2018 com.github.joseprl89. All rights reserved.
//

import UIKit

internal enum Result<SuccessType, FailureType> {
    case success(value: SuccessType)
    case failure(value: FailureType)

    var successValue: SuccessType? {
        switch self {
        case .success(value: let successValue): return successValue
        default: return nil
        }
    }

    var failureValue: FailureType? {
        switch self {
        case .failure(value: let failureValue): return failureValue
        default: return nil
        }
    }

    var isSuccess: Bool {
        switch self {
        case .success(value: _): return true
        default: return false
        }
    }

    var isFailure: Bool {
        return !isSuccess
    }
}
