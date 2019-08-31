//
//  NavigationController.swift
//  TestApp
//
//  Created by Paolo Moroni on 01/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

class NavigationController: UINavigationController, Tracing {

    override var viewControllers: [UIViewController] {
        get {
            trace(.stackOperation, self, #function)
            return super.viewControllers
        }
        set {
            trace(.stackOperation, self, #function)
            super.viewControllers = newValue
        }
    }

    override func viewDidLoad() {
        trace(.viewLifeCycle, self, #function)
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    override var description: String { return "UINC" }

    override func addChild(_ childController: UIViewController) {
        trace(.viewControllerContainment, self, #function)
        super.addChild(childController)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        trace(.stackOperation, self, #function)
        super.pushViewController(viewController, animated: animated)
    }

    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        trace(.stackOperation, self, #function)
        let returned = super.popViewController(animated: animated)
        return returned
    }

    @discardableResult
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        trace(.stackOperation, self, #function)
        return super.popToRootViewController(animated: animated)
    }

    @discardableResult
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        trace(.stackOperation, self, #function)
        return super.popToViewController(viewController, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        super.viewDidDisappear(animated)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        trace(.stackOperation, self, #function)
        super.setViewControllers(viewControllers, animated: animated)
    }

    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        super.beginAppearanceTransition(isAppearing, animated: animated)
    }

    override func endAppearanceTransition() {
        trace(.viewLifeCycle, self, #function)
        super.endAppearanceTransition()
    }
}

extension NavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension NavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

//        print("Operation: \(operation.rawValue)")
//        print("From: \(fromVC)")
//        print("To: \(toVC == nil ? "nil" : toVC.description)")

        switch operation {
        case .push:
            return PushAnimator()
        case .pop:
            return PopAnimator()
        default:
            return nil
        }
    }

    //    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    //
    //        guard let gestureRecognizer = navigationController.interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer else { return nil }
    //
    //        gestureRecognizer.removeTarget(nil, action: nil)
    //        interactionController = HorizontalSlideInteractiveController(animationController: animationController,
    //                                                                     gestureRecognizer: gestureRecognizer)
    //        return interactionController
    //    }
}
