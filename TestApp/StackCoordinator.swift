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
        let stack = StackViewController(viewControllers: [yellowViewController])
        stack.tabBarItem = UITabBarItem(title: "Stack", image: nil, tag: 1)
        return stack
    }()

    lazy var yellowViewController: YellowViewController = {
        let yellow = YellowViewController()
        yellow.navigationItem.title = "var yellow"
        yellow.onNext = {
            self.stackViewController.pushViewController(self.pinkViewController, animated: true)
        }

        yellow.onReplaceViewControllers = {
            let viewControllers = [
                self.newPinkViewController(title: "root pink"),
                yellow,
                self.newPinkViewController(title: "top pink") {
                    self.stackViewController.setViewControllers([], animated: false)
                }
            ]

            self.stackViewController.setViewControllers(viewControllers, animated: true)
        }

        yellow.onEmptyStack = {
            self.stackViewController.setViewControllers([], animated: true)
        }

        return yellow
    }()

    lazy var pinkViewController: UIViewController = newPinkViewController(title: "var pink")

    func newPinkViewController(title: String, onEmptyStack: (() -> Void)? = nil) -> UIViewController {
        let pink = PinkViewController()
        pink.navigationItem.title = title
        pink.onBack = { self.stackViewController.popViewController(animated: true) }
        pink.onEmptyStack = onEmptyStack
        return pink
    }
}
