//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public protocol StackViewControllerHandling: UIViewController {
    func popViewController(animated: Bool) -> UIViewController?
    func pushViewController(_: UIViewController, animated: Bool)
}

public protocol StackViewControllerDelegate: class {
    func stackViewController(_: StackViewController,
                             animationControllerForTransitionFrom from: UIViewController,
                             to: UIViewController) -> UIViewControllerAnimatedTransitioning?

}

public class StackViewController: UIViewController, StackViewControllerHandling {

    public enum Operation {
        case push
        case pop
        case none
    }
    
    // MARK: - Public properties

    public weak var delegate: StackViewControllerDelegate?

    public private(set) var viewControllers: [UIViewController]

    public var topViewController: UIViewController? {
        return viewControllers.last
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    // MARK: - Private properties

    private lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        return recognizer
    }()

    private var interactiveController: HorizontalSlideInteractiveController?

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.viewControllers = []
        super.init(coder: aDecoder)
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard !viewControllers.contains(viewController) else {
            assertionFailure(StackViewControllerError.controllerAlreadyInStack(viewController).localizedDescription)
            return
        }

        viewControllers.append(viewController)

        if let from = topViewController {
            let to = viewController
            performTransition(from: from, to: to, animated: animated, interactive: false)
        } else {
            showTopViewController()
        }
    }

    @discardableResult
    public func popViewController(animated: Bool) -> UIViewController? {
        guard let from = topViewController else { return nil }
        guard let to = viewControllerBefore(from) else { return nil }

        return popToViewController(to, animated: animated).first
    }

    @discardableResult
    func popToViewController(_ to: UIViewController, animated: Bool) -> [UIViewController] {
        guard let from = topViewController, topViewController != to else { return [] }
        guard let indexOfTo = viewControllers.firstIndex(where: { $0 === to }) else { return [] }

        let poppedViewControllers = viewControllers[(indexOfTo + 1)...]
        performTransition(from: from, to: to, animated: animated, interactive: false)
        return Array(poppedViewControllers)
    }

    public func setViewControllers(_ newViewControllers: [UIViewController], animated: Bool) {
        guard let newTopViewController = newViewControllers.last else {
            assertionFailure("Error: Cannot replace viewControllers with an empty array")
            return
        }

        let operation = stackViewControllerOperation(for: newViewControllers)

        switch operation {
        case .push:
            pushViewController(newTopViewController, animated: animated)
        case .pop:
            popToViewController(newTopViewController, animated: animated)
        case .none:
            break
        }

        viewControllers = newViewControllers

//
//        guard let topViewController = topViewController else {
//            pushViewController(newTopViewController, animated: animated)
//            return
//        }
//
//        guard topViewController != newTopViewController else {
//            return
//        }
//
//        if viewControllers.contains(newTopViewController) {
//            popToViewController(newTopViewController, animated: animated)
//            return
//        } else {
//            pushViewController(newTopViewController, animated: animated)
//            return
//        }
    }
}

// MARK: - UIViewController

public extension StackViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(screenEdgePanGestureRecognizer)

        showTopViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topViewController?.endAppearanceTransition()
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
        guard interactiveController == nil else { return false }
        guard let from = topViewController else { return false }
        guard let to = viewControllerBefore(from) else { return false }

        performInteractiveTransition(from: from, to: to)
        return true
    }
}

// MARK: - Transition

private extension StackViewController {

    func performInteractiveTransition(from: UIViewController, to: UIViewController) {
        performTransition(from: from, to: to, animated: true, interactive: true)
    }

    func performTransition(from: UIViewController, to: UIViewController, animated: Bool, interactive: Bool) {
        let transitionType = self.transitionType(fromViewController: from, toViewController: to)

        let context = transitionContextForTransition(from: from,
                                                     to: to,
                                                     animated: animated,
                                                     interactive: interactive)

        context.onTransitionFinished = { didComplete in
            defer { self.interactiveController = nil }

            guard didComplete else { return }

            self.sendFinalViewAppearanceEvents(from: from, to: to)

            if transitionType == .slideOut {
                self.viewControllers.removeLast()
            }
        }

        sendInitialViewAppearanceEvents(from: from, to: to, animated: animated)

        let animationController = animatorForTransition(from: from, to: to)

        if interactive {
            interactiveController = HorizontalSlideInteractiveController(animationController: animationController,
                                                                         gestureRecognizer: screenEdgePanGestureRecognizer,
                                                                         context: context)
        } else {
            animationController.animateTransition(using: context)
        }
    }

    func sendInitialViewAppearanceEvents(from: UIViewController, to: UIViewController, animated: Bool) {
        from.willMove(toParent: nil)
        from.beginAppearanceTransition(false, animated: animated)

        addChild(to)
        to.beginAppearanceTransition(true, animated: animated)
    }

    func sendFinalViewAppearanceEvents(from: UIViewController, to: UIViewController) {
        from.view.removeFromSuperview()
        from.removeFromParent()
        from.endAppearanceTransition()

        to.didMove(toParent: self)
        to.endAppearanceTransition()
    }

    func showTopViewController() {
        guard let to = topViewController else { return }

        addChild(to)
        view.addSubview(to.view)
        to.didMove(toParent: self)
    }
}

// MARK: - Object creation

private extension StackViewController {

    func viewControllerBefore(_ viewController: UIViewController) -> UIViewController? {
        let indexOfViewControllerInStack = viewControllers.firstIndex(of: viewController)

        guard let beforeIndex = indexOfViewControllerInStack?.advanced(by: -1), beforeIndex >= 0 else {
            return nil
        }

        return viewControllers[beforeIndex]
    }

    func animatorForTransition(from: UIViewController,
                               to: UIViewController) -> UIViewControllerAnimatedTransitioning {

        if let animator = delegate?.stackViewController(self,
                                                        animationControllerForTransitionFrom: from,
                                                        to: to) {
            return animator
        } else {
            let transitionType = self.transitionType(fromViewController: from, toViewController: to)
            return HorizontalSlideAnimationController(type: transitionType)
        }
    }

    func transitionContextForTransition(from: UIViewController,
                                        to: UIViewController,
                                        animated: Bool = true,
                                        interactive: Bool = false) -> StackViewControllerTransitionContext {

        let context = StackViewControllerTransitionContext(from: from,
                                                           to: to,
                                                           containerView: view)
        context.isAnimated = animated
        context.isInteractive = interactive

        return context
    }

    func transitionType(fromViewController from: UIViewController, toViewController to: UIViewController) -> HorizontalSlideTransitionType {
        if let topViewController = topViewController, topViewController === to {
            return .slideIn
        } else {
            return .slideOut
        }
    }
}
