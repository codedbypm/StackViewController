//
//  StackViewController+ViewContainmentEvents.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension StackViewController {

    func addChildren(_ stack: Stack) {
        stack.forEach { addChild($0) }
    }
    
    func notifyChildrenDidMove(_ stack: Stack) {
        stack.forEach { $0.didMove(toParent: self) }
    }

    func sendInitialViewContainmentEvents(for transition: Transition) {

        let from = transition.viewController(forKey: .from)
        let to = transition.viewController(forKey: .to)

        switch transition.operation {
        case .pop:
            from?.willMove(toParent: nil)
        case .push:
            guard let to = to else { return assertionFailure() }
            addChild(to)
        }
    }

    func sendFinalViewContainmentEvents(for transition: Transition) {

        let from = transition.viewController(forKey: .from)
        let to = transition.viewController(forKey: .to)

        switch transition.operation {
        case .pop:
            from?.removeFromParent()
        case .push:
            to?.didMove(toParent: self)
        }
    }
}
