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

    // MARK: - Init
    init() {

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
        }

        context.onTransitionCancelled = { _ in

        }

        transitionId = UUID()
        animationController.animateTransition(using: context)
    }

    func performInteractiveTransition(
        context: TransitionContext,
        interactionController: UIViewControllerInteractiveTransitioning
    ) {
        delegate?.willStartTransition(context)
        transitionId = UUID()
        interactionController.startInteractiveTransition(context)
    }
}

private extension TransitionHandler {
    
}

extension TransitionHandler: CustomStringConvertible {

    var description: String {
        return String(describing: type(of: self)).appending(" \(String(describing: transitionId))")
    }
}
