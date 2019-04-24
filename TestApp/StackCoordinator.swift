//
//  StackCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 20/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//


import StackViewController

class StackCoordinator {

    var debugPrefix = "[Stack]"
    let canPrint = true

    lazy var stackViewController: StackViewController = {
        let stack = StackViewController(viewControllers: [yellowViewController])
        stack.tabBarItem = UITabBarItem(title: debugPrefix, image: nil, tag: 1)
        return stack
    }()

    lazy var yellowViewController: BaseViewController = {
        let yellow = BaseViewController(delegate: self, color: .yellow, title: titled("lazy var yellow"), showsBackButton: false)
        yellow.onNext = {
            self.stackViewController.pushViewController(self.greenViewController, animated: true)
        }

        yellow.onReplaceViewControllers = {
            let root = self.newGreenViewController(title: self.titled("root green"))
            let top = self.newGreenViewController(title: self.titled("top green")) {
                self.stackViewController.setViewControllers([], animated: false)
            }

            self.stackViewController.setViewControllers([root, yellow, top], animated: true)
        }

        yellow.onEmptyStack = {
            self.stackViewController.setViewControllers([], animated: true)
        }

        return yellow
    }()

    lazy var greenViewController: BaseViewController = {
        let green = newGreenViewController(title: titled("lazy var green"))
        green.delegate = self
        return green
    }()

    func newGreenViewController(title: String, onEmptyStack: (() -> Void)? = nil) -> BaseViewController {
        let green = BaseViewController(delegate: self, color: .green, title: title)
        green.navigationItem.title = title
        green.onBack = { self.stackViewController.popViewController(animated: true) }
        green.onEmptyStack = onEmptyStack
        return green
    }

    func titled(_ title: String) -> String {
        return "\(debugPrefix) \(title)"
    }
}

extension StackCoordinator: DebugDelegate {
    
    func debug(_ text: String) {
        guard canPrint else { return }
        print(text)
    }
}
