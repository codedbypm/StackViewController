//
//  Stack+Extensions.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 10/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

extension UIViewController {
    static let first = UIViewController()
    static let middle = UIViewController()
    static let last = UIViewController()
}

extension Stack {
    static let empty: Stack = []

    static let `default`: Stack = [.first, .middle, .last]

    static func distinctElements(_ size: Int) -> Stack {
        guard size > 0 else { return .empty }
        return (0..<size).map { _ in return UIViewController() }
    }

}
