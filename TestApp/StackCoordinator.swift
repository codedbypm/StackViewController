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
        var yellow: BaseViewController = UIViewController.stacked(on: nil,
                                                                 delegate: self,
                                                                 color: .yellow)
        var black: BaseViewController = UIViewController.stacked(on: nil,
                                                                 delegate: self,
                                                                 color: .black)
        var green: BaseViewController = UIViewController.stacked(on: nil,
                                                                 delegate: self,
                                                                 color: .green)

        let stackViewController = StackViewController(viewControllers: [yellow, black, green])
        yellow.stack = stackViewController
        black.stack = stackViewController
        green.stack = stackViewController

        stackViewController.debugDelegate = self
        stackViewController.tabBarItem = UITabBarItem(title: debugPrefix, image: nil, tag: 1)
        stackViewController.viewControllers = [
            yellow,
            UIViewController.stacked(on: stackViewController, delegate: self, color: .green),
            black,
            green
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
