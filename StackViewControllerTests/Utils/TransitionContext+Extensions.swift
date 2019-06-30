//
//  TransitionContext+Extensions.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 30/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

extension TransitionContext {

    static var dummy: TransitionContext {
        return TransitionContext(
            operation: .push,
            from: UIViewController(),
            to: UIViewController(),
            containerView: ViewControllerWrapperView(),
            animated: true,
            interactive: false
        )
    }
}

