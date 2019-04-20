//
//  StackCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 20/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//


import StackViewController

class StackCoordinator {

    lazy var stackViewController: StackViewController = {
        let stack = StackViewController(viewControllers: [yellowViewController()])
        stack.tabBarItem = UITabBarItem(title: "Stack", image: nil, tag: 1)
        return stack
    }()

    func start() -> UIViewController {
        return stackViewController
    }

    func yellowViewController() -> UIViewController {
        let yellow = YellowViewController()
        yellow.onNext = {
            self.stackViewController.pushViewController(self.pinkViewController(), animated: true)
        }
        return yellow
    }

    func pinkViewController() -> UIViewController {
        let pink = PinkViewController()
        pink.onBack = { self.stackViewController.popViewController(animated: true) }
        return pink
    }

}
