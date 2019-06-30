//
//  TransitionHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 07/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandlerDelegate: class {
    func willStartTransition(_: TransitionContext)
    func didEndTransition(_: TransitionContext, didComplete: Bool)
}

class TransitionHandler: TransitionHandling {

    // MARK: - Internal properties

    weak var delegate: TransitionHandlerDelegate?

    var operation: StackViewController.Operation {
        return transitionContext?.operation ?? .none
    }

    // MARK: - Private properties

    private weak var stackViewControllerDelegate: StackViewControllerDelegate?
    private var transitionContext: TransitionContext?
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private let transitionId = UUID()

    // MARK: - Init
    init() {

    }

//    init(operation: StackViewController.Operation,
//         from: UIViewController?,
//         to: UIViewController?,
//         containerView: UIView,
//         animated: Bool,
//         interactive: Bool = false,
//         screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer? = nil) {
//
//        self.screenEdgePanGestureRecognizer = screenEdgePanGestureRecognizer
//
//        transitionContext = TransitionContext(operation: operation,
//                                              from: from,
//                                              to: to,
//                                              containerView: containerView,
//                                              animated: animated,
//                                              interactive: interactive)
//
//        transitionContext?.onTransitionFinished = { [weak self] didComplete in
//            self?.animationController?.animationEnded?(didComplete)
//            self?.transitionFinished(didComplete)
//        }
//
//        transitionContext?.onTransitionCancelled = { _ in
//
//        }
//    }

    deinit {
        print("\(String(describing: self)): \(#function)")
    }

    func performTransition(_ context: TransitionContext) {
        delegate?.willStartTransition(context)
    }

    func performTransition(
        animationController: UIViewControllerAnimatedTransitioning
    ) {
        assert(interactionController == nil)

        guard let transitionContext = transitionContext else {
            assertionFailure("Error: no TransitionContext found when trying to perform a transition")
            return
        }

        delegate?.willStartTransition(transitionContext)
        animationController.animateTransition(using: transitionContext)
    }

    func transitionFinished(_ didComplete: Bool) {
        guard let transitionContext = transitionContext else { return }

        delegate?.didEndTransition(transitionContext, didComplete: didComplete)
        interactionController = nil
        animationController = nil
    }

    func updateInteractiveTransition(_ gestureRecognizer: ScreenEdgePanGestureRecognizer) {
        guard let interactionController = interactionController as? InteractivePopAnimator else {
            return
        }
        interactionController.updateInteractiveTransition(gestureRecognizer)
    }

    func cancelInteractiveTransition() {
        guard let interactionController = interactionController as? InteractivePopAnimator else {
            return
        }
        interactionController.cancelInteractiveTransition()
    }

    func stopInteractiveTransition(_ gestureRecognizer: ScreenEdgePanGestureRecognizer) {
        guard let interactionController = interactionController as? InteractivePopAnimator else {
            return
        }
        interactionController.stopInteractiveTransition(gestureRecognizer)
    }
}

extension TransitionHandler: CustomStringConvertible {

    var description: String {
        return String(describing: type(of: self)).appending(" \(transitionId)")
    }
}
