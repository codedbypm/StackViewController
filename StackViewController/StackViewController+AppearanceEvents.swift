//
//  StackViewController+AppearanceEvents.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension StackViewController {

    func sendInitialViewAppearanceEvents(using context: TransitionContext) {
        let isAnimated = context.isAnimated
        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)

        from?.beginAppearanceTransition(false, animated: isAnimated)
        to?.beginAppearanceTransition(true, animated: isAnimated)
    }

    func sendFinalViewAppearanceEvents(using context: TransitionContext) {
        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)

        from?.endAppearanceTransition()
        to?.endAppearanceTransition()
    }
}
