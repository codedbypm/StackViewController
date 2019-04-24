//
//  StackViewController+Extensions.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation
@testable import StackViewController

extension StackViewController {

    static let knwownViewControllerA = UIViewController()
    static let knwownViewControllerB = UIViewController()
    static let knwownViewControllerC = UIViewController()

    static let knownStack = [
        knwownViewControllerA,
        knwownViewControllerB,
        knwownViewControllerC
    ]

    static var dummy: StackViewController {
        return StackViewController(viewControllers: [])
    }

    static func withEmptyStack() -> StackViewController {
        return .withNumberOfViewControllers(0)
    }

    static func withNumberOfViewControllers(_ count: UInt) -> StackViewController {
        let stack = (0..<count).map { _ in return UIViewController() }
        return StackViewController(viewControllers: stack)
    }

    static func withKnownStack() -> StackViewController {
        return StackViewController(viewControllers: knownStack)
    }
}


extension StackViewController {

    func loadingTopViewControllerView() -> StackViewController {
        _ = topViewController?.view
        return self
    }

    func showingTopViewControllerView() -> StackViewController {
        guard let topViewControllerView = topViewController?.view else { return .dummy }
        view.addSubview(topViewControllerView)
        return self
    }
}
