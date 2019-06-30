//
//  MockStackViewControllerInteractorDelegate.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 10/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackViewControllerInteractorDelegate: UIViewController, StackViewControllerInteractorDelegate {

    var animationController: UIViewControllerAnimatedTransitioning?
    func animationController(for operation: StackViewController.Operation, from: UIViewController, to: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }

    var interactiveController: UIViewControllerInteractiveTransitioning?
    func interactionController(for animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController
    }

    func prepareAddingChild(_ viewController: UIViewController) {

    }

    func finishAddingChild(_ viewController: UIViewController) {

    }

    var callsToPrepareRemovingChild: [Bool] = []
    var viewControllersPreparedToBeRemoved: [UIViewController] = []
    func prepareRemovingChild(_ viewController: UIViewController) {
        callsToPrepareRemovingChild.append(true)
        viewControllersPreparedToBeRemoved.append(viewController)
    }

    var callsToFinishRemovingChild: [Bool] = []
    var viewControllerFinishedToBeRemoved: [UIViewController] = []
    func finishRemovingChild(_ viewController: UIViewController) {
        callsToFinishRemovingChild.append(true)
        viewControllerFinishedToBeRemoved.append(viewController)
    }

    func prepareAppearance(of _: UIViewController, animated: Bool) {

    }

    func finishAppearance(of _: UIViewController) {

    }

    func prepareDisappearance(of _: UIViewController, animated: Bool) {

    }

    func finishDisappearance(of _: UIViewController) {

    }

    func startInteractivePopTransition() {

    }
}
