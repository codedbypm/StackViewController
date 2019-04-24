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

    lazy var yellowViewController: BaseViewController = {
        let yellow = BaseViewController(color: .yellow, title: "yellow", showsBackButton: false)
        yellow.onNext = {
            self.stackViewController.pushViewController(self.greenViewController, animated: true)
        }

        yellow.onReplaceViewControllers = {
            let viewControllers = [
                self.newGreenViewController(title: "root green"),
                yellow,
                self.newGreenViewController(title: "top green") {
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

    lazy var pinkViewController: UIViewController = newGreenViewController(title: "var pink")

    func newGreenViewController(title: String, onEmptyStack: (() -> Void)? = nil) -> UIViewController {
        let pink = BaseViewController(color: .green, title: title)
        pink.navigationItem.title = title
        pink.onBack = { self.stackViewController.popViewController(animated: true) }
        pink.onEmptyStack = onEmptyStack
        return pink
    }
}
