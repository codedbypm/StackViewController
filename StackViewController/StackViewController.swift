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
        get { return viewModel.transitioningDelegate }
        set { viewModel.transitioningDelegate = newValue }
    }

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
        let selector = #selector(StackViewModel.screenEdgeGestureRecognizerDidChangeState(_:))
        let recognizer = ScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        recognizer.addTarget(viewModel, action: selector)
        return recognizer
    }()

    // MARK: - Private properties

    private var viewControllerWrapperView: UIView {
        return viewModel.viewControllerWrapperView
    }

    private let viewModel: StackViewModel

    private var transitionHandler: TransitionHandler?

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        let stackHandler = StackHandler()
        viewModel = StackViewModel(stackHandler: stackHandler)
        super.init(nibName: nil, bundle: nil)

        stackHandler.delegate = viewModel
        viewModel.delegate = self
        viewModel.setStack(viewControllers, animated: false)
    }

    public required init?(coder aDecoder: NSCoder) {
        let stackHandler = StackHandler()
        viewModel = StackViewModel(stackHandler: stackHandler)
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
}

// MARK: - StackViewModelDelegate

extension StackViewController: StackViewModelDelegate {

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

//    func didCreateTransition(_ transition: Transition) {
//        debugTransitionStarted()
//        assert(transitionHandler == nil)
//        assert(isViewLoaded == true)
//        assert(view.window != nil)
//
//        transitionHandler = TransitionHandler(
//            transition: transition,
//            containerView: viewControllerWrapperView,
//            stackViewControllerDelegate: delegate,
//            screenEdgeGestureRecognizer: screenEdgePanGestureRecognizer
//        )
//        transitionHandler?.delegate = self
//        transitionHandler?.performTransition()
//    }
}

// MARK: - TransitionHandlerDelegate

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
