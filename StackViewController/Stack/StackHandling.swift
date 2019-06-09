//
//  StackHandling.swift
//  StackViewController
//
//  Created by Paolo Moroni on 31/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackHandling {
    var stack: Stack { get }

    func canPushViewController(_: UIViewController) -> Bool
    func pushViewController(_: UIViewController)

    func canPopViewController() -> Bool
    func popViewController() -> UIViewController?

    func canPopToRoot() -> Bool
    func popToRoot() -> [UIViewController]?

    func canPop(to: UIViewController) -> Bool
    func pop(to: UIViewController) -> [UIViewController]?

    func canSetStack(_: Stack) -> Bool
    func setStack(_: Stack)
}
