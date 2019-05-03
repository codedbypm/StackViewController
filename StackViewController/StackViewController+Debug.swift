//
//  StackViewController+Debug.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension StackViewController {

    func debugWillSetStack() {
        print(
            """
            =========== willSet Stack ===========
            """
        )
    }

    func debugEndTransition() {
        print(
            """

            =========== Transition completed ===========
            Stack \(viewControllers.isEmpty ? "is empty" : "contains \(viewControllers.count) view controllers")
            StackViewControllers has \(children.isEmpty ? "no child" : "\(children.count) children")
            TopViewController is \(topViewController == nil ? "nil" : "\(String(describing: topViewController!))")

            """
        )
    }
}

