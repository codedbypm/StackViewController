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

    override var stack: [UIViewController] {
        get {
            trace(.stackOperation, self, #function)
            return super.stack
        }
        set {
            trace(.stackOperation, self, #function)
            super.stack = newValue
        }
    }

//    override func loadView() {
//        let view = NavigationView("UINC View")
//        self.view = view
//    }

    override func viewDidLoad() {
        trace(.viewLifeCycle, self, #function)
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    override var description: String { return "UINC" }

    override func viewWillLayoutSubviews() {
        trace(.viewLifeCycle, self, #function)
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        trace(.viewLifeCycle, self, #function)
        super.viewDidLayoutSubviews()
    }
    override func addChild(_ childController: UIViewController) {
        trace(.viewControllerContainment, self, #function)
        super.addChild(childController)
    }

    override func push(_ viewController: UIViewController, animated: Bool) {
        trace(.stackOperation, self, #function)
        super.push(viewController, animated: animated)
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
