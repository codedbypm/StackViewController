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

    // MARK: - Private properties

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private var transitionId: UUID?
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?

    // MARK: - Init

    init(delegate: TransitionHandlerDelegate) {
        self.delegate = delegate
    }

    deinit {
        print("\(String(describing: self)): \(#function)")
    }

    func performTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning
    ) {
        delegate?.willStartTransition(context)

        context.onTransitionFinished = { didComplete in
            animationController.animationEnded?(didComplete)
            self.delegate?.didEndTransition(context, didComplete: didComplete)
            self.animationController = nil
        }

        context.onTransitionCancelled = { _ in

        }

        transitionId = UUID()
        self.animationController = animationController
        animationController.animateTransition(using: context)
    }

    func performInteractiveTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning,
        interactionController: UIViewControllerInteractiveTransitioning
    ) {
        delegate?.willStartTransition(context)

        context.onTransitionFinished = { didComplete in
            animationController.animationEnded?(didComplete)
            self.delegate?.didEndTransition(context, didComplete: didComplete)
            self.animationController = nil
            self.interactionController = nil
        }

        transitionId = UUID()
        self.interactionController = interactionController
        interactionController.startInteractiveTransition(context)
    }
}

extension TransitionHandler: CustomStringConvertible {

    var description: String {
        return String(describing: type(of: self)).appending(" \(String(describing: transitionId))")
    }
}
