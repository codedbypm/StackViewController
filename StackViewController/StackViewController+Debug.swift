//
//  StackViewController+Debug.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension StackViewController {

    func debug(_ text: String) {
        print(
            """

            =========== \(text) ===========
            """
        )
    }

    func debugTransitionStarted() { debug("Transition started") }
    func debugTransitionEnded() {
        debug("Transition ended")
        debugRecap()
    }

    func debugRecap() {
        print(
            """

            Stack \(stack.isEmpty ? "is empty" : "contains \(stack.count) view controllers")
            StackViewControllers has \(children.isEmpty ? "no child" : "\(children.count) children")
            TopViewController is \(topViewController == nil ? "nil" : "\(String(describing: topViewController!))")
            """
        )
    }
}

