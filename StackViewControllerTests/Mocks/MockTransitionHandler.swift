//
//  MockTransitionHandler.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 09/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockTransitionHandler: TransitionHandling {
    weak var delegate: TransitionHandlingDelegate?

    var didCallPrepareTransition: Bool?
    func prepareTransition(context: TransitionContext) {
        didCallPrepareTransition = true
        transitionContext = context
    }

    var didCallPerformTransition: Bool?
    var transitionContext: TransitionContext?
    var animationController: UIViewControllerAnimatedTransitioning?
    func performTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning
    ) {
        didCallPerformTransition = true
        transitionContext = context
        self.animationController = animationController
    }

    var didCallPerformInteractiveTransition: Bool?
    var interactiveTransitionContext: TransitionContext?
    var interactionController: UIViewControllerInteractiveTransitioning?
    func performInteractiveTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning,
        interactionController: UIViewControllerInteractiveTransitioning
    ) {
        didCallPerformInteractiveTransition = true
        transitionContext = context
        self.animationController = animationController
        self.interactionController = interactionController

    }
}
