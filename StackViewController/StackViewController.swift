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
    }

    // MARK: - Public properties
    
    public var debugDelegate: DebugDelegate?

    public weak var delegate: StackViewControllerDelegate?
    
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
        let selector = #selector(screenEdgeGestureRecognizerDidChangeState(_:))
        let recognizer = ScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        recognizer.addTarget(self, action: selector)
        return recognizer
    }()

    // MARK: - Private properties

    var viewControllerWrapperView: UIView {
        return interactor.viewControllerWrapperView
    }

    internal var interactor: StackInteractor

    private var transitionHandler: TransitionHandler?

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        interactor = StackInteractor(stack: viewControllers)
        super.init(nibName: nil, bundle: nil)

        interactor.delegate = self
        addChildren(viewControllers)
    }

    public required init?(coder aDecoder: NSCoder) {
        interactor = StackInteractor(stack: [])
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

        return interactor.canPopViewControllerInteractively()
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushStack([viewController], animated: animated)
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

    @objc private func screenEdgeGestureRecognizerDidChangeState(_
        gestureRecognizer: ScreenEdgePanGestureRecognizer) {        

        guard gestureRecognizer === screenEdgePanGestureRecognizer else { return }
        guard case .began = gestureRecognizer.state else { return }

        interactor.pop(animated: true, interactive: true)
    }
}

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
        debugEndTransition()
    }
}

extension StackViewController: StackViewModelDelegate {
    
    func didReplaceStack(oldStack: Stack, with newStack: Stack) {
        removeChildren(oldStack)
        addChildren(newStack)
    }


    func didCreateTransition(_ transition: Transition) {
        assert(transitionHandler == nil)

        transitionHandler = TransitionHandler(transition: transition, stackViewControllerDelegate: delegate, screenEdgeGestureRecognizer: screenEdgePanGestureRecognizer)
        transitionHandler?.delegate = self
        transitionHandler?.performTransition()
    }
}

private extension StackViewController {

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

private extension StackViewController {
    
    func sendInitialViewControllerContainmentEvents(for transition: Transition) {
        switch transition.operation {
        case .pop:
            transition.from?.willMove(toParent: nil)
        case .push:
            guard let to = transition.to else { return assertionFailure() }
            addChild(to)
        }
    }

    func sendFinalViewControllerContainmentEvents(for transition: Transition) {
        switch transition.operation {
        case .pop:
            transition.from?.removeFromParent()
        case .push:
            transition.to?.didMove(toParent: self)
        }
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
