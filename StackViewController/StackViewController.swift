//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public class StackViewController: UIViewController {

    public enum Operation {
        case push
        case pop
        case none
    }

    // MARK: - Public properties

    public weak var delegate: StackViewControllerDelegate?

    public var viewControllers: [UIViewController] {
        get {
            trace(.stackOperation, self, #function)
            return interactor.stack
        }
        set {
            trace(.stackOperation, self, #function)
            setStack(newValue, animated: false)
        }
    }

    public var topViewController: UIViewController? {
        return interactor.topViewController
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    public override var description: String { return "SVC" }

    // MARK: - Internal properties

    let interactor: StackViewControllerInteractor

    lazy var screenEdgePanGestureRecognizer: ScreenEdgePanGestureRecognizer = {
        let selector = #selector(screenEdgeGestureRecognizerDidChangeState(_:))
        let recognizer = ScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.addTarget(self, action: selector)
        return recognizer
    }()

    var viewControllerWrapperView: UIView {
        return interactor.viewControllerWrapperView
    }

    // MARK: - Init

    public init(rootViewController: UIViewController) {
        self.interactor = StackViewControllerInteractor()
        super.init(nibName: nil, bundle: nil)

        self.interactor.delegate = self
        self.pushViewController(rootViewController, animated: false)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.interactor = StackViewControllerInteractor()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.interactor.delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        self.interactor = StackViewControllerInteractor()
        super.init(coder: aDecoder)
    }

    // MARK: - Internal Init

    convenience init(viewControllers: [UIViewController]) {
        self.init(nibName: nil, bundle: nil)

        self.viewControllers = viewControllers
    }

    init(interactor: StackViewControllerInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        trace(.viewLifeCycle, self, #function)

        view.addGestureRecognizer(screenEdgePanGestureRecognizer)
        view.addSubview(viewControllerWrapperView)
        viewControllerWrapperView.frame = view.bounds

        if let topViewController = topViewController {
            viewControllerWrapperView.addSubview(topViewController.view)
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trace(.viewLifeCycle, self, #function)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trace(.viewLifeCycle, self, #function)
        topViewController?.endAppearanceTransition()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        trace(.viewLifeCycle, self, #function)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        trace(.viewLifeCycle, self, #function)
        topViewController?.endAppearanceTransition()
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        trace(.stackOperation, self, #function)
        interactor.pushViewController(viewController, animated: animated)
    }

    @discardableResult
    public func popViewController(animated: Bool) -> UIViewController? {
        trace(.stackOperation, self, #function)
        return interactor.popViewController(animated: animated)
    }

    @discardableResult
    public func popToRootViewController(animated: Bool) -> Stack? {
        trace(.stackOperation, self, #function)
        return interactor.popToRoot(animated: animated)
    }

    @discardableResult
    public func popToViewController(_ viewController: UIViewController, animated: Bool) -> Stack? {
        trace(.stackOperation, self, #function)
        return interactor.pop(to: viewController, animated: animated)
    }

    public func setStack(_ stack: Stack, animated: Bool) {
        trace(.stackOperation, self, #function)
        interactor.setStack(stack, animated: animated)
    }
}

// MARK: - StackViewControllerInteractorDelegate

extension StackViewController: StackViewControllerInteractorDelegate {

    public func animationController(
        for operation: StackViewController.Operation,
        from: UIViewController,
        to: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return delegate?.animationController(for: operation,
                                             from: from,
                                             to: to)
    }

    public func interactionController(
        for animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return delegate?.interactionController(for: animationController)
    }

    func startInteractivePopTransition() {
        interactor.popViewController(animated: true, interactive: true)
    }

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

    @objc func screenEdgeGestureRecognizerDidChangeState(_ gestureRecognizer: ScreenEdgePanGestureRecognizer) {
        interactor.handleScreenEdgePanGestureRecognizerStateChange(gestureRecognizer)
    }
}

extension StackViewController: StackViewControllerHandling {
    public func setViewControllers(_ stack: [UIViewController], animated: Bool) {
        setStack(stack, animated: animated)
    }
}

extension StackViewController: Tracing {}
