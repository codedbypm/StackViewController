//
//  StackViewControllerError.swift
//  StackViewController
//
//  Created by Paolo Moroni on 22/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public enum StackViewControllerError: Error {
    case controllerAlreadyInStack(UIViewController)
}

extension StackViewControllerError {

    public var localizedDescription: String {
        switch self {
        case .controllerAlreadyInStack(let viewController):
            return NSLocalizedString("It is not allowed to push view controller \(viewController), since it is already in the stack",
                                     comment: "")
        }
    }

    
}
