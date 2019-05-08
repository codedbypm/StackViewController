//
//  StackCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 20/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//


import StackViewController

class StackCoordinator {

    let canPrint = true

    lazy var stackViewController: StackViewController = {
        var first: BaseViewController = UIViewController.stacked(on: nil,
                                                                 delegate: self,
                                                                 color: .yellow)
        let stackViewController = StackViewController(viewControllers: [])
        first.stack = stackViewController

        stackViewController.debugDelegate = self
        stackViewController.tabBarItem = UITabBarItem(title: debugPrefix, image: nil, tag: 1)
        stackViewController.viewControllers = [
            UIViewController.stacked(on: stackViewController, delegate: self, color: .black),
            UIViewController.stacked(on: stackViewController, delegate: self, color: .red),
            UIViewController.stacked(on: stackViewController, delegate: self, color: .green),
        ]
        return stackViewController
    }()
}

extension StackCoordinator: DebugDelegate {

    var debugPrefix: String {
        return "[Stack] "
    }

    func debug(_ text: String) {
        guard canPrint else { return }
        print(debugPrefix + text)
    }
}
