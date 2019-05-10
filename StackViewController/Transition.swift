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
    let from: UIViewController?
    let to: UIViewController?
    let isAnimated: Bool
    let isInteractive: Bool
    var undo: (() -> Void)?

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
