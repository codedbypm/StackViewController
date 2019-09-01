//
//  NavigationController.swift
//  TestApp
//
//  Created by Paolo Moroni on 01/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

class NavigationBar: UINavigationBar {
    override var description: String { return "UINC Bar" }
}

class NavigationView: UIView, Tracing {

    let name: String

    override var description: String { return name }

    init(_ string: String) {
        name = string
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddSubview(_ subview: UIView) {
        trace(.viewChanges, self, #function, subview)
        super.didAddSubview(subview)
    }

    override func willRemoveSubview(_ subview: UIView) {
        trace(.viewChanges, self, #function, subview)
        super.willRemoveSubview(subview)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        trace(.viewChanges, self, #function, "\(String(describing: newSuperview))")
        super.willMove(toSuperview: newSuperview)
    }

    override func didMoveToSuperview() {
        trace(.viewChanges, self, #function)
        super.didMoveToSuperview()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        trace(.viewChanges, self, #function, "\(String(describing: newWindow))")
        super.willMove(toWindow: newWindow)
    }

    override func didMoveToWindow() {
        trace(.viewChanges, self, #function)
        super.didMoveToWindow()
    }
}

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
