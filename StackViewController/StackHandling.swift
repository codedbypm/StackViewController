//
//  StackHandling.swift
//  StackViewController
//
//  Created by Paolo Moroni on 31/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackHandling {
    func push(_: UIViewController) -> StackOperationResult
    func pop() -> StackOperationResult
    func popToRoot() -> StackOperationResult
    func popToElement(_: Stack.Element) -> StackOperationResult
    func replaceStack(with newStack: Stack) -> StackOperationResult
}
