//
//  Transition.swift
//  StackViewController
//
//  Created by Paolo Moroni on 04/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

struct Transition {
    let operation: StackViewController.Operation
    var from: UIViewController?
    var to: UIViewController?
    let isAnimated: Bool
    let isInteractive: Bool
    var undo: (() -> Void)?

    static func push() -> Transition { return Transition(operation: .push) }

    static func pop() -> Transition { return Transition(operation: .pop) }

    static func instantPush() -> Transition { return Transition(operation: .push, animated: false) }

    static func instantPop() -> Transition { return Transition(operation: .pop, animated: false) }

    static func interactivePop() -> Transition { return Transition(operation: .pop, interactive: true) }

    init(operation: StackViewController.Operation,
         animated: Bool = true,
         interactive: Bool = false) {
        self.operation = operation
        self.isAnimated = animated
        self.isInteractive = interactive
    }

    init(operation: StackViewController.Operation,
         from: UIViewController?,
         to: UIViewController?,
         animated: Bool = true,
         interactive: Bool = false,
         undo: (() -> Void)? = nil) {

        self.operation = operation
        self.from = from
        self.to = to
        self.isAnimated = animated
        self.isInteractive = interactive
        self.undo = undo
    }
}
