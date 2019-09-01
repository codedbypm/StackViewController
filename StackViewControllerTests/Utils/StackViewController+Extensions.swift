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

    convenience init(viewControllers: [UIViewController]) {
        self.init(nibName: nil, bundle: nil)
        self.stack = viewControllers
    }

    static var dummy: StackViewController {
        return StackViewController(viewControllers: [])
    }

    static func withEmptyStack() -> StackViewController {
        return StackViewController(viewControllers: .empty)
    }

    static func withNumberOfViewControllers(_ count: UInt) -> StackViewController {
        let viewControllers = (0..<count).map { _ in return UIViewController() }
        return StackViewController(viewControllers: viewControllers)
    }

    static func withDefaultStack() -> StackViewController {
        return StackViewController(viewControllers: .default)
    }
}

extension StackViewController {

    func loadingTopViewControllerView() -> StackViewController {
        _ = topViewController?.view
        return self
    }

    static func embeddedInWindow() -> StackViewController {
        class MockWindowView: UIView {
            override var window: UIWindow? { return UIWindow() }
        }

        let stackViewController = StackViewController()
        stackViewController.view = MockWindowView()
        return stackViewController
    }
}
