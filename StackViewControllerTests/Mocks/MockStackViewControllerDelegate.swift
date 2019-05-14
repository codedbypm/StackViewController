//
//  MockStackViewControllerDelegate.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 14/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackViewControllerDelegate: StackViewControllerDelegate {

    func animationController(
        for operation: StackViewController.Operation,
        from: UIViewController,
        to: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func interactionController(
        for animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
