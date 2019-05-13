//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public class StackViewController: UIViewController, UIGestureRecognizerDelegate {

    public enum Operation {
        case push
        case pop
        case none
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

    lazy var screenEdgePanGestureRecognizer: ScreenEdgePanGestureRecognizer = {
        let selector = #selector(screenEdgeGestureRecognizerDidChangeState(_:))
        let recognizer = ScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        recognizer.addTarget(self, action: selector)
        return recognizer
    }()

    // MARK: - Private properties

    private var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    private let viewModel: StackViewModel

    private var transitionHandler: TransitionHandler?

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        let stackHandler = StackHandler(stack: viewControllers)
        viewModel = StackViewModel(stackHandler: stackHandler)
        super.init(nibName: nil, bundle: nil)

        stackHandler.delegate = viewModel
        viewModel.delegate = self
        viewControllers.forEach { addChild($0) }
    }

    public required init?(coder aDecoder: NSCoder) {
        let stackHandler = StackHandler(stack: [])
        viewModel = StackViewModel(stackHandler: stackHandler)
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        debugFunc(#function, allowed: true)

        view.addGestureRecognizer(screenEdgePanGestureRecognizer)
        view.addSubview(viewControllerWrapperView)
        viewControllerWrapperView.frame = view.bounds

        if let topViewController = topViewController {
            viewControllerWrapperView.addSubview(topViewController.view)
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        debugFunc(#function, allowed: true)

        super.viewWillAppear(animated)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        debugFunc(#function, allowed: true)
        super.viewDidAppear(animated)
        topViewController?.endAppearanceTransition()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        debugFunc(#function, allowed: true)
        super.viewWillDisappear(animated)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        debugFunc(#function, allowed: true)
        super.viewDidDisappear(animated)
        topViewController?.endAppearanceTransition()
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer === screenEdgePanGestureRecognizer)
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushStack([viewController], animated: animated)
    }

    public func pushStack(_ stack: Stack, animated: Bool) {
        viewModel.push(stack, animated: animated)
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

    public func setStack(_ stack: Stack, animated: Bool) {
        viewModel.setStack(stack, animated: animated)
    }

    // MARK: - Actions

    @objc private func screenEdgeGestureRecognizerDidChangeState(_
        gestureRecognizer: ScreenEdgePanGestureRecognizer) {        

        guard gestureRecognizer === screenEdgePanGestureRecognizer else { return }
        guard case .began = gestureRecognizer.state else { return }

        viewModel.pop(animated: true, interactive: true)
    }
}

// MARK: - StackViewModelDelegate

extension StackViewController: StackViewModelDelegate {
    func prepareToMoveToParent(for viewController: UIViewController) {
        addChild(viewController)
    }

    func finalizeMoveToParent(for viewController: UIViewController) {
        viewController.didMove(toParent: self)
    }

    func prepareToRemoveFromParent(for viewController: UIViewController) {
        viewController.willMove(toParent: nil)
    }

    func finalizeRemoveFromParent(for viewController: UIViewController) {
        viewController.removeFromParent()
    }
        removals.forEach {
            $0.willMove(toParent: nil)
            $0.removeFromParent()
        }
    }

    func didReplaceStack(_ oldStack: Stack, with newStack: Stack) {
        didRemoveStackElements(oldStack)
        didAddStackElements(newStack)
    }

    func didCreateTransition(_ transition: Transition) {
        debugTransitionStarted()
        assert(transitionHandler == nil)

        transitionHandler = TransitionHandler(
            transition: transition,
            containerView: viewControllerWrapperView,
            stackViewControllerDelegate: delegate,
            screenEdgeGestureRecognizer: screenEdgePanGestureRecognizer
        )
        transitionHandler?.delegate = self
        transitionHandler?.performTransition()
    }
}

// MARK: - TransitionHandlerDelegate

extension StackViewController: TransitionHandlerDelegate {

    func willStartTransition(_ transition: Transition) {
        sendInitialViewControllerContainmentEvents(for: transition)
        sendInitialViewAppearanceEvents(for: transition)
    }

    func didEndTransition(_ transition: Transition, didComplete: Bool) {
        if didComplete  {
            sendFinalViewAppearanceEvents(for: transition)
            sendFinalViewControllerContainmentEvents(for: transition)
        } else {
            sendInitialViewAppearanceEvents(for: transition, swapElements: true)
            sendFinalViewAppearanceEvents(for: transition)

            transition.undo?()
        }

        transitionHandler = nil
        debugTransitionEnded()
    }
}

// MARK: - Containment and Appearance events

private extension StackViewController {

    func sendInitialViewControllerContainmentEvents(for transition: Transition) {
    }

    func sendFinalViewControllerContainmentEvents(for transition: Transition) {
    }

    func sendInitialViewAppearanceEvents(for transition: Transition, swapElements: Bool = false) {
        let isAnimated = transition.isAnimated

        let from = (swapElements ? transition.to : transition.from)
        let to = (swapElements ? transition.from : transition.to)

        from?.beginAppearanceTransition(false, animated: isAnimated)
        to?.beginAppearanceTransition(true, animated: isAnimated)
    }

    func sendFinalViewAppearanceEvents(for transition: Transition) {
        transition.from?.endAppearanceTransition()
        transition.to?.endAppearanceTransition()
    }
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
