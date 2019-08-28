//
//  MockStackOperationProvider.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 21/07/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation
@testable import StackViewController

class MockStackOperationProvider: StackOperationProviding {

    var didCallStackOperation: Bool?
    var oldStack: Stack?
    var newStack: Stack?
    var stackOperationValue: StackViewController.Operation = .none
    func stackOperation(whenReplacing oldStack: Stack, with newStack: Stack) -> StackViewController.Operation {
        didCallStackOperation = true
        self.oldStack = oldStack
        self.newStack = newStack
        return stackOperationValue
    }
}
