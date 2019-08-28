//
//  StackOperationProvider.swift
//  StackViewController
//
//  Created by Paolo Moroni on 21/07/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackOperationProviding {
    func stackOperation(whenReplacing oldStack: Stack,
                        with newStack: Stack) -> StackViewController.Operation
}

class StackOperationProvider: StackOperationProviding {

    static let shared = StackOperationProvider()
    
    func stackOperation(whenReplacing oldStack: Stack,
                        with newStack: Stack) -> StackViewController.Operation {
        let from = oldStack.last
        let to = newStack.last

        guard from !== to else { return .none }

        if let to = to {
            if oldStack.contains(to) { return .pop }
            else { return .push }
        } else {
            if from != nil { return .pop }
            else { return .none }
        }
    }
}
