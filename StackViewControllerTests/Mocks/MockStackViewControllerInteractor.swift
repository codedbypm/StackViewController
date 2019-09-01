//
//  MockStackViewControllerInteractor.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 14/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackViewControllerInteractor: StackViewControllerInteractor {

    var didCallStackGetter: Bool?
    override var stack: Stack {
        didCallStackGetter = true
        return Stack.default
    }

    var didCallPushViewControllerAnimated: Bool?
    var pushedViewController: UIViewController?
    var pushedViewControllerAnimated: Bool?
    override func push(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        didCallPushViewControllerAnimated = true
        pushedViewController = viewController
        pushedViewControllerAnimated = animated
    }

    var didCallPopAnimatedInteractive: Bool?
    var popAnimated: Bool?
    var popInteractive: Bool?
    var popReturnValue: UIViewController?
    @discardableResult
    override func popViewController(animated: Bool, interactive: Bool = false) -> UIViewController? {
        didCallPopAnimatedInteractive = true
        popAnimated = animated
        popInteractive = interactive
        return popReturnValue
    }

    var didCallPopToRootAnimated: Bool?
    var popToRootAnimated: Bool?
    var popToRootReturnValue: Stack = []
    @discardableResult
    override func popToRoot(animated: Bool) -> Stack {
        didCallPopToRootAnimated = true
        popToRootAnimated = animated
        return popToRootReturnValue
    }

    var didCallPopToViewControllerAnimated: Bool?
    var popToViewControllerViewController: UIViewController?
    var popToViewControllerAnimated: Bool?
    var popToViewControllerReturnValue: Stack = []
    @discardableResult
    override func pop(to viewController: UIViewController, animated: Bool) -> Stack {
        didCallPopToViewControllerAnimated = true
        popToViewControllerViewController = viewController
        popToViewControllerAnimated = animated
        return popToViewControllerReturnValue
    }
    
    var didCallSetStackAnimated: Bool?
    var setStackStack: Stack?
    var setStackAnimated: Bool?
    override func setStack(_ newStack: Stack, animated: Bool) {
        didCallSetStackAnimated = true
        setStackStack = newStack
        setStackAnimated = animated
    }

    var didCallHandleScreenEdgePanGestureRecognizerStateChange: Bool?
    var gestureRecognizer: UIScreenEdgePanGestureRecognizer?
    override func handleScreenEdgePanGestureRecognizerStateChange(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        didCallHandleScreenEdgePanGestureRecognizerStateChange = true
        self.gestureRecognizer = gestureRecognizer
    }

    var isAnimated: Bool?

    var didCallViewWillAppear: Bool?
    override func viewWillAppear(_ animated: Bool) {
        didCallViewWillAppear = true
        isAnimated = animated
    }

    var didCallViewDidAppear: Bool?
    override func viewDidAppear(_ animated: Bool) {
        didCallViewDidAppear = true
        isAnimated = animated
    }

    var didCallViewWillDisappear: Bool?
    override func viewWillDisappear(_ animated: Bool) {
        didCallViewWillDisappear = true
        isAnimated = animated
    }

    var didCallViewDidDisappear: Bool?
    override func viewDidDisappear(_ animated: Bool) {
        didCallViewDidDisappear = true
        isAnimated = animated
    }
}
