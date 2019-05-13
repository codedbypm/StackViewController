//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public class StackViewController: UIViewController, UIGestureRecognizerDelegate {

    let debugAppearance = true

    public enum Operation {
        case push
        case pop
        case none
    }

    // MARK: - Public properties
    
    public var debugDelegate: DebugDelegate?

    public weak var delegate: StackViewControllerDelegate? {
        get { return interactor.transitioningDelegate }
        set { interactor.transitioningDelegate = newValue }
    }

    public var viewControllers: [UIViewController] {
        get { return interactor.stack }
        set { interactor.setStack(newValue, animated: false) }
    }

    public var topViewController: UIViewController? {
        return interactor.topViewController
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    // MARK: - Internal properties

    lazy var screenEdgePanGestureRecognizer: ScreenEdgePanGestureRecognizer = {
        let selector = #selector(StackViewControllerInteractor.screenEdgeGestureRecognizerDidChangeState(_:))
        let recognizer = ScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        recognizer.addTarget(interactor, action: selector)
        return recognizer
    }()

    // MARK: - Private properties

    private var viewControllerWrapperView: UIView {
        return interactor.viewControllerWrapperView
    }

    private let interactor: StackViewControllerInteractor

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        let stackHandler = StackHandler()
        interactor = StackViewControllerInteractor(stackHandler: stackHandler)
        super.init(nibName: nil, bundle: nil)

        stackHandler.delegate = interactor
        interactor.delegate = self
        interactor.setStack(viewControllers, animated: false)
    }

    public required init?(coder aDecoder: NSCoder) {
        let stackHandler = StackHandler()
        interactor = StackViewControllerInteractor(stackHandler: stackHandler)
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        debugFunc(#function, allowed: debugAppearance)

        view.addGestureRecognizer(screenEdgePanGestureRecognizer)
        view.addSubview(viewControllerWrapperView)
        viewControllerWrapperView.frame = view.bounds

        if let topViewController = topViewController {
            viewControllerWrapperView.addSubview(topViewController.view)
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        debugFunc(#function, allowed: debugAppearance)
        super.viewWillAppear(animated)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        debugFunc(#function, allowed: debugAppearance)
        super.viewDidAppear(animated)
        topViewController?.endAppearanceTransition()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        debugFunc(#function, allowed: debugAppearance)
        super.viewWillDisappear(animated)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        debugFunc(#function, allowed: debugAppearance)
        super.viewDidDisappear(animated)
        topViewController?.endAppearanceTransition()
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer === screenEdgePanGestureRecognizer)
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        interactor.push(viewController, animated: animated)
    }

    public func pushStack(_ stack: Stack, animated: Bool) {
        interactor.push(stack, animated: animated)
    }

    @discardableResult
    public func popViewController(animated: Bool) -> UIViewController? {
        return interactor.pop(animated: animated)
    }

    @discardableResult
    public func popToRootViewController(animated: Bool) -> Stack? {
        return interactor.popToRoot(animated: animated)
    }

    @discardableResult
    public func popToViewController(_ viewController: UIViewController, animated: Bool) -> Stack? {
        return interactor.popTo(viewController, animated: animated)
    }

    public func setStack(_ stack: Stack, animated: Bool) {
        interactor.setStack(stack, animated: animated)
    }
}

// MARK: - StackViewControllerInteractorDelegate

extension StackViewController: StackViewControllerInteractorDelegate {

    func prepareAddingChild(_ viewController: UIViewController) {
        addChild(viewController)
    }

    func finishAddingChild(_ viewController: UIViewController) {
        viewController.didMove(toParent: self)
    }

    func prepareRemovingChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
    }

    func finishRemovingChild(_ viewController: UIViewController) {
        viewController.removeFromParent()
    }

    func prepareAppearance(of viewController: UIViewController, animated: Bool) {
        viewController.beginAppearanceTransition(true, animated: animated)
    }

    func finishAppearance(of viewController: UIViewController) {
        viewController.endAppearanceTransition()
    }

    func prepareDisappearance(of viewController: UIViewController, animated: Bool) {
        viewController.beginAppearanceTransition(false, animated: animated)
    }

    func finishDisappearance(of viewController: UIViewController) {
        viewController.endAppearanceTransition()
    }
}

extension StackViewController {

//    func willStartTransition(_ transition: Transition) {
//        sendInitialViewAppearanceEvents(for: transition)
//    }
//
//    func didEndTransition(_ transition: Transition, didComplete: Bool) {
//        if didComplete  {
//            sendFinalViewAppearanceEvents(for: transition)
//            sendFinalViewControllerContainmentEvents(for: transition)
//        } else {
//            sendInitialViewAppearanceEvents(for: transition, swapElements: true)
//            sendFinalViewAppearanceEvents(for: transition)
//
//            transition.undo?()
//        }
//
//        transitionHandler = nil
//        debugTransitionEnded()
//    }
}

extension StackViewController: ConsoleDebuggable {
    public override var description: String {
        return "SVC"
    }
}

extension StackViewController: StackViewControllerHandling {
    public func setViewControllers(_ stack: [UIViewController], animated: Bool) {
        setStack(stack, animated: animated)
    }
}
