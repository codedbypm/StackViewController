//
//  MockTransitionHandler.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 09/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockTransitionHandler: TransitionHandling {

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


    func performInteractiveTransition(
        context: TransitionContext,
        interactionController: UIViewControllerInteractiveTransitioning
    ) {

    }
}

