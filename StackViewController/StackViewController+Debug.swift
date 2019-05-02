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
            Stack contains \(self.viewControllers.count) view controllers
            StackViewControllers has \(self.children.count) children
            TopViewController is \(String(describing: self.topViewController!))

            """
        )
    }
}

