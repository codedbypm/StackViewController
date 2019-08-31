//
//  MockTransitionHandlerDelegate.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 30/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockTransitionHandlerDelegate: TransitionHandlingDelegate {

    var didCallWillStartTransition: Bool?
    var willStartTransitionContext: TransitionContext?
    func willStartTransition(_ context: TransitionContext) {
        didCallWillStartTransition = true
        willStartTransitionContext = context
    }

    var didCallDidEndTransition: Bool?
    var didEndTransitionContext: TransitionContext?
    var didComplete: Bool?
    func didEndTransition(_ context: TransitionContext, didComplete: Bool) {
        didCallDidEndTransition = true
        didEndTransitionContext = context
        self.didComplete = didComplete
    }
}
