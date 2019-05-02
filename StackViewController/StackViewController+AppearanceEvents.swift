//
//  StackViewController+AppearanceEvents.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension StackViewController {

    func sendInitialViewAppearanceEvents(for transition: Transition) {
        let isAnimated = transition.isAnimated
        let from = transition.viewController(forKey: .from)
        let to = transition.viewController(forKey: .to)

        from?.beginAppearanceTransition(false, animated: isAnimated)
        to?.beginAppearanceTransition(true, animated: isAnimated)
    }

    func sendFinalViewAppearanceEvents(for transition: Transition) {
        let from = transition.viewController(forKey: .from)
        let to = transition.viewController(forKey: .to)

        from?.endAppearanceTransition()
        to?.endAppearanceTransition()
    }
}
