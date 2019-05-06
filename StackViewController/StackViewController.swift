//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public class StackViewController: UIViewController, StackViewControllerHandling, UIGestureRecognizerDelegate {

    public enum Operation {
        case push
        case pop
    }

    // MARK: - Public properties
    
    public var debugDelegate: DebugDelegate?

    public weak var delegate: StackViewControllerDelegate?
    
    public var viewControllers: [UIViewController] {
        get { return viewModel.stack }
        set { viewModel.setStack(newValue, animated: false) }
    }

    public var topViewController: UIViewController? {
        return viewModel.topViewController
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    // MARK: - Internal properties


    lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        return recognizer
    }()

    // MARK: - Private properties

    private(set) var interactionController: UIViewControllerInteractiveTransitioning?

    private lazy var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    internal var viewModel: StackViewModel

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        viewModel = StackViewModel(stack: viewControllers)
        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self    
        addChildren(viewControllers)
    }

    public required init?(coder aDecoder: NSCoder) {
        viewModel = StackViewModel(stack: [])
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        debugFunc(#function, allowed: true)

        view.addGestureRecognizer(screenEdgePanGestureRecognizer)

        if let topViewController = topViewController {
            view.addSubview(viewControllerWrapperView)
            viewControllerWrapperView.frame = view.bounds
            viewControllerWrapperView.addSubview(topViewController.view)
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topViewController?.endAppearanceTransition()
        topViewController?.didMove(toParent: self)
        debugEndTransition()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topViewController?.endAppearanceTransition()
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === screenEdgePanGestureRecognizer else { return false }

        return viewModel.canPopViewControllerInteractively()
    }

    // MARK: - Public methods

    // TODO: remove this one
    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllers([viewController], animated: animated)
    }

    public func pushViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewModel.push(viewControllers, animated: animated)
    }

    @discardableResult
    public func popViewController(animated: Bool) -> UIViewController? {
        return viewModel.pop(animated: animated)
    }

    @discardableResult
    public func popToRootViewController(animated: Bool) -> Stack? {
        return viewModel.popToRoot(animated: animated)
    }

    @discardableResult
    public func popToViewController(_ viewController: UIViewController, animated: Bool) -> Stack? {
        return viewModel.popTo(viewController, animated: animated)
    }

    public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewModel.setStack(viewControllers, animated: animated)
    }

    // MARK: - Private methods

    private func popViewControllerInteractively() -> Bool {
//        guard stackHandler.canPopInteractively() else { return false }
//        transition = .interactiveAnimated()
//        stackHandler.popLast()
//
        return true
    }
}

extension StackViewController: StackViewModelDelegate {

    func didCreateTransition() {
        guard let transition = viewModel.transition else { return assertionFailure() }

        let animationController = self.animationController(for: transition)

        let context = viewModel.context(for: transition,
                                        in: viewControllerWrapperView)

        context.onTransitionFinished = { didComplete in
            self.interactionController = nil

            if didComplete {
                self.sendFinalViewAppearanceEvents(using: context)
                self.sendFinalViewContainmentEvents(using: context)
            } else {
                self.sendInitialViewAppearanceEvents(using: context)
                self.sendFinalViewAppearanceEvents(using: context)
            }

            animationController.animationEnded?(didComplete)

            self.viewModel.transitionFinished(didComplete)
            self.debugEndTransition()
        }

        sendInitialViewContainmentEvents(using: context)
        sendInitialViewAppearanceEvents(using: context)

        if context.isInteractive {
            startInteractiveTransition(animationController: animationController, context: context)
        } else {
            startTransition(animationController: animationController, context: context)
        }
    }
}

// MARK: - Transition

private extension StackViewController {

    func performStackTransition(_ transition: TransitionContext,
                                whenCompleted: (() -> Void)? = nil) {

//        let from = transition.viewController(forKey: .from)
//        let to = transition.viewController(forKey: .to)
//
//        switch (from, to) {
//        case (.some(let from), .none):
//            performInstantPopTransition(of: from)
//            whenCompleted?()
//        case (.none, .some(let to)):
//            performInstantPushTransition(of: to)
//            whenCompleted?()
//        case (.some(let from), .some(let to)):
//            performTransition(transition,
//                              from: from,
//                              to: to,
//                              whenCompleted: whenCompleted)
//        case (.none, .none):
//            assertionFailure()
//        }
    }

//    func performTransition(_ transition: TransitionContext,
//                           from: UIViewController,
//                           to: UIViewController,
//                           whenCompleted: (() -> Void)? = nil) {
//
//        assert(isInViewHierarchy)
//
//        let animationController = self.animationController(for: transition.operation, from: from, to: to)
//
//        transition.onTransitionFinished = { didComplete in
//            self.interactionController = nil
//
//            if didComplete {
//                self.sendFinalViewAppearanceEvents(for: transition)
//                self.sendFinalViewContainmentEvents(for: transition)
//                whenCompleted?()
//            } else {
//                self.sendInitialViewAppearanceEvents(for: transition)
//                self.sendFinalViewAppearanceEvents(for: transition)
//            }
//
//            animationController.animationEnded?(didComplete)
//
//            self.debugEndTransition()
//        }
//
//        sendInitialViewContainmentEvents(for: transition)
//        sendInitialViewAppearanceEvents(for: transition)
//
//        if transition.isInteractive {
//            startInteractiveTransition(animationController: animationController, context: transition)
//        } else {
//            startTransition(animationController: animationController, context: transition)
//        }
//    }

    func startTransition(animationController: UIViewControllerAnimatedTransitioning,
                         context: UIViewControllerContextTransitioning) {
        animationController.animateTransition(using: context)
    }

    func startInteractiveTransition(animationController: UIViewControllerAnimatedTransitioning,
                                    context: UIViewControllerContextTransitioning) {
        interactionController = self.interactionController(animationController: animationController,
                                                           context: context)
    }

    func performInstantPushTransition(of viewController: UIViewController) {
        addChild(viewController)
        viewController.beginAppearanceTransition(true, animated: false)
        view.addSubview(viewController.view)
        viewController.endAppearanceTransition()
        viewController.didMove(toParent: self)
    }

    func performInstantPopTransition(of viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.beginAppearanceTransition(false, animated: false)
        viewController.view.removeFromSuperview()
        viewController.endAppearanceTransition()
        viewController.removeFromParent()
    }
}

extension StackViewController: ConsoleDebuggable {
    public override var description: String {
        return "SVC"
    }
}
