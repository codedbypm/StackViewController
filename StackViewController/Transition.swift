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
    let animated: Bool
    let interactive: Bool

    init(operation: StackViewController.Operation,
         from: UIViewController?,
         to: UIViewController?,
         animated: Bool = true,
         interactive: Bool = false) {

        self.operation = operation
        self.from = from
        self.to = to
        self.animated = animated
        self.interactive = interactive
    }
}
