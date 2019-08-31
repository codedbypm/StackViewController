//
//  MockStackViewControllerDelegate.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 14/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackViewControllerDelegate: StackViewControllerDelegate {

    var animationController: MockAnimatedTransitioning?
    func animationController(
        for operation: StackViewController.Operation,
        from: UIViewController,
        to: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }

    var interactiveController: MockInteractiveTransitioning?
    func interactionController(
        for animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController
    }
}
