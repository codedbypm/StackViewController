//
//  TransitionHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 04/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

class TransitionHandler {

    private(set) var currentTransition: TransitionContext?

    init() {
        currentTransition = nil
    }

    func createTransition(for operation: StackViewController.Operation,
                          viewControllers: [UIViewController],
                          animated: Bool,
                          interactive: Bool = false) {
        guard currentTransition != nil else {
            assertionFailure()
            return
        }

//        let transition = Transition()
//        transition.operation = operation
//        transition.isAnimated = animated
//        
//        currentTransition = transition
    }

    func setFrom(_ viewController: UIViewController?) {
        currentTransition?.setViewController(viewController, forKey: .from)
    }

    func setTo(_ viewController: UIViewController?) {
        currentTransition?.setViewController(viewController, forKey: .to)
    }


}
