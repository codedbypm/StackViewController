//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

typealias OnTransitionDone = (Bool) -> Void

public class StackViewController: UIViewController, StackViewControllerHandling {

    public enum Operation {
        case push
        case pop
    }
    
    // MARK: - Public properties

    public weak var delegate: StackViewControllerDelegate?

    public var viewControllers: [UIViewController] {
        get { return _viewControllers }
        set { setViewControllers(newValue, animated: false) }
    }

    public var topViewController: UIViewController? {
        return _viewControllers.last
    }

    public var visibleViewController: UIViewController? {
        guard
            let topViewController = topViewController,
            topViewController.isViewLoaded && topViewController.view.window != nil
        else { return nil }

        return topViewController
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    // MARK: - Private properties

    private var _viewControllers: [UIViewController]

    private lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        return recognizer
    }()

    private var interactionController: UIViewControllerInteractiveTransitioning?

    private var onTransitionCompleted: (() -> Void)?

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        self._viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self._viewControllers = []
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(screenEdgePanGestureRecognizer)

        guard let topViewController = topViewController else { return }
        addChild(topViewController)
        view.addSubview(topViewController.view)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let topViewController = topViewController else { return }
        topViewController.endAppearanceTransition()
        topViewController.didMove(toParent: self)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topViewController?.endAppearanceTransition()
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard canPush(viewController) else { return }

        forcePushViewController(viewController, animated: animated)
    }

    @discardableResult
    public func popViewController(animated: Bool) -> UIViewController? {
        guard canPop() else { return nil }

        guard let from = visibleViewController else { return nil }
        guard let to = viewControllerBefore(from) else { return nil }

        return popToViewController(to, animated: animated).first
    }

    public func setViewControllers(_ newViewControllers: [UIViewController], animated: Bool) {
        guard canReplaceViewControllers(_viewControllers, with: newViewControllers) else { return }

        replaceViewControllers(_viewControllers, with: newViewControllers, animated: false)
    }
}

// MARK: - Push

private extension StackViewController {

    func forcePushViewController(_ viewController: UIViewController, animated: Bool) {
        let from = visibleViewController
        let to = viewController

        _viewControllers.append(to)
        performTransition(forOperation: .push, from: from, to: to, animated: animated)
    }
}

// MARK: - Pop

private extension StackViewController {

    @discardableResult
    func popToViewController(_ to: UIViewController, animated: Bool) -> [UIViewController] {
        guard let from = visibleViewController, visibleViewController != to else { return [] }
        guard let indexOfTo = _viewControllers.firstIndex(where: { $0 === to }) else { return [] }

        let poppedViewControllers = viewControllers.suffix(from: indexOfTo + 1)
        _viewControllers = _viewControllers.dropLast(poppedViewControllers.count)
        performTransition(forOperation: .pop, from: from, to: to, animated: animated, interactive: false)
        return Array(poppedViewControllers)
    }
}

// MARK: - Stack modifications

private extension StackViewController {

    func replaceViewControllers(_ currentViewControllers: [UIViewController],
                                with newViewControllers: [UIViewController],
                                animated: Bool) {

        switch (currentViewControllers.isEmpty, newViewControllers.isEmpty) {
        case (true, true): assertionFailure()
        case (true, false): installViewControllers(newViewControllers)
        case (false, true): removeAllViewControllers()
        case (false, false): assertionFailure()
        }
    }

    func installViewControllers(_ newViewControllers: [UIViewController]) {
        guard let newTopViewController = newViewControllers.last else { return assertionFailure() }
        guard isViewLoaded else { return assertionFailure() }

        _viewControllers = newViewControllers
        sendInitialViewContainmentEvents(from: nil, to: newTopViewController)

        performTransition(forOperation: .push, from: nil, to: newTopViewController, animated: false)
    }

    func whatever(_ currentViewControllers: [UIViewController],
                  with newViewControllers: [UIViewController],
                  animated: Bool) {
        // In case there is no visible VC....
        guard let visibleViewController = visibleViewController else {
            guard let newTopViewController = newViewControllers.last else { return assertionFailure() }

            // 1. the SVC is not yet on the screen
            if view.window == nil {

            } else {
                // 2. the SVC is on screen but empty
                _viewControllers = newViewControllers
                sendInitialViewContainmentEvents(from: nil, to: newTopViewController)
            }

            performTransition(forOperation: .push,
                              from: nil,
                              to: newTopViewController,
                              animated: false)
            return
        }

        _viewControllers = newViewControllers

        guard let currentVisibleViewController = currentViewControllers.last, currentVisibleViewController.view.window != nil else {
            guard let newTopViewController = newViewControllers.last else { return }
            performTransition(forOperation: .push, from: nil, to: newTopViewController, animated: false)

            return
        }

        guard let newTopViewController = newViewControllers.last else {
            hideVisibleViewController()
            _viewControllers = []
            return
        }

        //        guard let topViewController = visibleViewController else {
        //
        //        }

        guard let operation = operationWhenReplacingStack(with: newViewControllers) else {
            return
        }

        // When dealing with empty stacks replacements, animations are not allowed
        let allowsAnimation = !_viewControllers.isEmpty && !newViewControllers.isEmpty
        let shouldAnimate = allowsAnimation ? animated : false

        switch operation {
        case .push:
            forcePushViewController(newTopViewController, animated: shouldAnimate)
        case .pop:
            popToViewController(newTopViewController, animated: shouldAnimate)
        }

    }

    func operationWhenReplacingStack(with newStack: [UIViewController]) -> Operation? {

        // newStack is empty => instant pop all
        guard let newTopViewController = newStack.last else {
            return .pop
        }

        // oldStack is empty => instant push all
        guard let topViewController = visibleViewController else {
            return .push
        }

        // Same topViewController => do nothing
        guard newTopViewController != topViewController else {
            return nil
        }

        if _viewControllers.contains(newTopViewController) {
            return .pop
        } else {
            return .push
        }
    }

    func removeAllViewControllers() {
        _viewControllers.forEach {
            let isInViewHierarchy = ($0.view.superview != nil)

            if isInViewHierarchy {
                $0.beginAppearanceTransition(false, animated: false)
                $0.view.removeFromSuperview()
            }

            $0.removeFromParent()

            if isInViewHierarchy {
                $0.endAppearanceTransition()
            }
        }

        _viewControllers.removeAll()
    }
}

// MARK: - Validation

private extension StackViewController {

    func canPush(_ viewController: UIViewController) -> Bool {
        guard !_viewControllers.contains(viewController) else { return false }
        return true
    }

    func canPop() -> Bool {
        return (viewControllers.count > 1 && visibleViewController != nil)
    }

    func canReplaceViewControllers(_ currentViewControllers: [UIViewController],
                                   with newViewControllers: [UIViewController]) -> Bool {

        guard !currentViewControllers.isEmpty || !newViewControllers.isEmpty else { return false }

        return true
    }
}

// MARK: - Transition

private extension StackViewController {

    func performInteractivePopTransition(from: UIViewController, to: UIViewController) {
        performTransition(forOperation: .pop, from: from, to: to, animated: true, interactive: true)
    }

    func performTransition(forOperation operation: Operation,
                           from: UIViewController?,
                           to: UIViewController,
                           animated: Bool = true,
                           interactive: Bool = false) {

        sendInitialViewContainmentEvents(from: from, to: to)

        sendInitialViewAppearanceEvents(from: from, to: to, animated: animated)

        let animationController = animationControllerForOperation(operation, from: from, to: to)
        let context = transitionContextForTransition(from: from,
                                                     to: to,
                                                     animated: animated,
                                                     interactive: interactive)

        context.onTransitionFinished = { didComplete in
            animationController.animationEnded?(didComplete)
            self.interactionController = nil

            if didComplete {
                self.sendFinalViewAppearanceEvents(from: from, to: to)
                self.sendFinalViewContainmentEvents(from: from, to: to)
            }

            self.debugEndTransition()
        }

        if interactive {
            interactionController = interactionController(for: animationController, context: context)
        } else {
            animationController.animateTransition(using: context)
        }
    }

    func sendInitialViewContainmentEvents(from: UIViewController?, to: UIViewController) {
        from?.willMove(toParent: nil)
        addChild(to)
    }

    func undoInitialViewContainmentEvents(from: UIViewController?, to: UIViewController) {
        to.removeFromParent()
    }

    func sendFinalViewContainmentEvents(from: UIViewController?, to: UIViewController) {
        from?.removeFromParent()

        if to.isViewLoaded, to.view.window != nil {
            to.didMove(toParent: self)
        }
    }

    func sendInitialViewAppearanceEvents(from: UIViewController?,
                                         to: UIViewController,
                                         animated: Bool) {
        if let from = from, from.isViewLoaded, from.view.window != nil {
            from.beginAppearanceTransition(false, animated: animated)
        }

        to.beginAppearanceTransition(true, animated: animated)
    }

    func sendFinalViewAppearanceEvents(from: UIViewController?,
                                       to: UIViewController) {
        if let from = from, from.isViewLoaded, from.view.window == nil {
            from.endAppearanceTransition()
        }

        if to.isViewLoaded, to.view.window != nil {
            to.endAppearanceTransition()
        }
    }

    func hideVisibleViewController() {
        let visibleViewController = self.visibleViewController
        
        visibleViewController?.beginAppearanceTransition(false, animated: false)
        visibleViewController?.view.removeFromSuperview()
        visibleViewController?.endAppearanceTransition()

        visibleViewController?.willMove(toParent: nil)
        visibleViewController?.removeFromParent()
    }
}

// MARK: - Object creation

private extension StackViewController {

    func animationControllerForOperation(_ operation: Operation,
                                         from: UIViewController?,
                                         to: UIViewController) -> UIViewControllerAnimatedTransitioning {
        let transitionType = self.transitionType(for: operation)

        guard let from = from else {
            return HorizontalSlideAnimationController(type: transitionType)
        }

        let delegateController =  delegate?.stackViewController(self,
                                                                animationControllerFor: operation,
                                                                from: from,
                                                                to: to)
        if let delegateController = delegateController {
            return delegateController
        } else {
            return HorizontalSlideAnimationController(type: transitionType)
        }
    }

    func interactionController(for animationController: UIViewControllerAnimatedTransitioning,
                               context: UIViewControllerContextTransitioning) -> UIViewControllerInteractiveTransitioning? {

        guard let delegate = delegate else {
            return HorizontalSlideInteractiveController(animationController: animationController,
                                                        gestureRecognizer: screenEdgePanGestureRecognizer,
                                                        context: context)
        }

        return delegate.stackViewController(self, interactionControllerFor: animationController)
    }

    func transitionContextForTransition(from: UIViewController?,
                                        to: UIViewController,
                                        animated: Bool = true,
                                        interactive: Bool = false) -> StackViewControllerTransitionContext {

        let animationsEnabled = (from != nil)
        let context = StackViewControllerTransitionContext(from: from,
                                                           to: to,
                                                           containerView: view)
        context.isAnimated = animated && animationsEnabled
        context.isInteractive = interactive

        return context
    }
}

// MARK: - Stack-based information

extension StackViewController {

    func viewControllerBefore(_ viewController: UIViewController) -> UIViewController? {
        let indexOfViewControllerInStack = _viewControllers.firstIndex(of: viewController)

        guard let beforeIndex = indexOfViewControllerInStack?.advanced(by: -1), beforeIndex >= 0 else {
            return nil
        }

        return viewControllers[beforeIndex]
    }

    func transitionType(for operation: Operation) -> HorizontalSlideTransitionType {
        switch operation {
        case .push: return .slideIn
        case .pop: return .slideOut
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension StackViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === screenEdgePanGestureRecognizer {
            return screenEdgePanGestureRecognizerShouldBegin()
        } else {
            return false
        }
    }

    private func screenEdgePanGestureRecognizerShouldBegin() -> Bool {
        guard interactionController == nil else { return false }
        guard let from = visibleViewController else { return false }
        guard let to = viewControllerBefore(from) else { return false }

        performInteractivePopTransition(from: from, to: to)
        return true
    }
}

private extension StackViewController {
    func debugEndTransition() {
        print(
            """

            =========== Transition completed ===========
            Stack contains \(self.viewControllers.count) view controllers
            StackViewControllers has \(self.children.count) children
            TopViewController is \(self.topViewController)
            VisibleViewController is \(self.visibleViewController)

            """
        )
    }
}
