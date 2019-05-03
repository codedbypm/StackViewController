//
//  StackViewControllerError.swift
//  StackViewController
//
//  Created by Paolo Moroni on 22/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol ExceptionThrowing {
    func throwError(_: StackViewControllerError, userInfo: [String: Any]?)
}

extension ExceptionThrowing {
    
    func throwError(_ error: StackViewControllerError, userInfo: [String: Any]? = nil) {
        error.raiseException(userInfo: userInfo)
    }
}

public enum StackViewControllerError: Error {
    case duplicateViewControllers
}

extension StackViewControllerError {

    func raiseException(userInfo: [String: Any]? = nil) {
        exception(userInfo: userInfo).raise()
    }

    private func exception(userInfo: [String: Any]? = nil) -> NSException {
        switch self {
        case .duplicateViewControllers:
            let name = NSExceptionName.internalInconsistencyException
            let stack = userInfo?["stack"] as? Stack ?? []
            let reason =
            """
                All view controllers in a navigation controller must be distinct:
                \(stack)
            """
            return NSException(name: name, reason: reason, userInfo: userInfo)
        }
    }
}

