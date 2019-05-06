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
        let selector = #selector(screenEdgeGestureRecognizerDidChangeState(_:))
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        recognizer.addTarget(self, action: selector)
        return recognizer
    }()

    // MARK: - Private properties

    var viewControllerWrapperView: UIView {
        return viewModel.viewControllerWrapperView
    }

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

    @objc private func screenEdgeGestureRecognizerDidChangeState(_
        gestureRecognizer: UIScreenEdgePanGestureRecognizer) {        
        guard gestureRecognizer === screenEdgePanGestureRecognizer else { return }
        viewModel.screenEdgeGestureRecognizerDidChangeState(gestureRecognizer)
    }
}

extension StackViewController: StackViewModelDelegate {

    public func animationController(
        for operation: StackViewController.Operation,
        from: UIViewController,
        to: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return delegate?.animationController(for: operation, from: from, to: to)
    }

    public func interactionController(
        for animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return delegate?.interactionController(for: animationController)
    }

    func willStartTransition(using context: TransitionContext) {
        sendInitialViewControllerContainmentEvents(using: context)
        sendInitialViewAppearanceEvents(using: context)
    }

    func didEndTransition(using context: TransitionContext, completed: Bool) {
        if completed  {
            sendFinalViewAppearanceEvents(using: context)
            sendFinalViewControllerContainmentEvents(using: context)
        } else {
            sendInitialViewAppearanceEvents(using: context)
            sendFinalViewAppearanceEvents(using: context)
        }
    }
}

private extension StackViewController {

    func sendInitialViewAppearanceEvents(using context: UIViewControllerContextTransitioning) {
        let isAnimated = context.isAnimated
        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)

        from?.beginAppearanceTransition(false, animated: isAnimated)
        to?.beginAppearanceTransition(true, animated: isAnimated)
    }

    func sendFinalViewAppearanceEvents(using context: UIViewControllerContextTransitioning) {
        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)

        from?.endAppearanceTransition()
        to?.endAppearanceTransition()
    }
}

private extension StackViewController {
    
    func sendInitialViewControllerContainmentEvents(using context: TransitionContext) {

        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)

        switch context.operation {
        case .pop:
            from?.willMove(toParent: nil)
        case .push:
            guard let to = to else { return assertionFailure() }
            addChild(to)
        }
    }

    func sendFinalViewControllerContainmentEvents(using context: TransitionContext) {

        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)

        switch context.operation {
        case .pop:
            from?.removeFromParent()
        case .push:
            to?.didMove(toParent: self)
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
