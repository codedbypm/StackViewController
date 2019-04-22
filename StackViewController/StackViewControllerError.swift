//
//  StackViewControllerError.swift
//  StackViewController
//
//  Created by Paolo Moroni on 22/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public enum StackViewControllerError: Error {
    case duplicateOnPushing
}

extension StackViewControllerError {

    public var localizedDescription: String {
        switch self {
        case .duplicateOnPushing:
            return NSLocalizedString("It is not allowed to push an instance of UIViewController, if the same instance is already in the stack",
                                     comment: "")
        }
    }

    
}
