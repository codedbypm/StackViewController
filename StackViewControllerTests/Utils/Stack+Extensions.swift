//
//  Stack+Extensions.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 10/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

@testable import StackViewController

extension Stack {
    static let empty: Stack = []

    static func distinctElements(_ size: Int) -> Stack {
        guard size > 0 else { return .empty }
        return (0..<size).map { _ in return UIViewController() }
    }

    static let firstViewController = UIViewController()
    static let middleViewController = UIViewController()
    static let lastViewController = UIViewController()
    
    static let `default` = [
        firstViewController,
        middleViewController,
        lastViewController
    ]
}
