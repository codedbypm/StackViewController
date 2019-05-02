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

    static let knownViewControllers = [
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
        let viewControllers = (0..<count).map { _ in return UIViewController() }
        return StackViewController(viewControllers: viewControllers)
    }

    static func withKnownStack() -> StackViewController {
        return StackViewController(viewControllers: knownViewControllers)
    }
}


extension StackViewController {

    func loadingTopViewControllerView() -> StackViewController {
        _ = topViewController?.view
        return self
    }

    func embeddedInWindow() -> StackViewController {
        class MockWindowView: UIView {
            override var window: UIWindow? { return UIWindow() }
        }

        guard let topViewController = topViewController else { return .dummy }
        topViewController.view = MockWindowView()
        return self
    }
}
