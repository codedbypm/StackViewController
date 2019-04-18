//
//  RootCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 02/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

extension UINavigationController: StackViewControllerHandling {}

class RootCoordinator {

    lazy var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    var stackViewController: StackViewControllerHandling
    let rootViewController = YellowViewController()

    let navControllerDelegate = NavControllerDelegate()

    lazy var navigationController: UINavigationController = {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.delegate = navControllerDelegate
        navController.interactivePopGestureRecognizer?.isEnabled = false
        navController.view.addGestureRecognizer(screenEdgePanGestureRecognizer)
        return navController
    }()

    lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        return recognizer
    }()


    init(window: UIWindow) {
        stackViewController = StackViewController(viewControllers: [rootViewController])
        if false {
            stackViewController = navigationController
        }

        rootViewController.onNext = {
            let pink = PinkViewController()
            pink.onBack = {
                self.stackViewController.popViewController(animated: true)
            }
            self.stackViewController.pushViewController(pink, animated: true)
        }

        window.rootViewController = stackViewController
        window.makeKeyAndVisible()
    }
}

class NavControllerDelegate: NSObject, UINavigationControllerDelegate {

    var operation: UINavigationController.Operation = .none

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        self.operation = operation

        switch operation {
        case .push:
            return HorizontalSlideAnimationController(type: .slideIn)
        case .pop:
            return HorizontalSlideAnimationController(type: .slideOut)
        default:
            return nil
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        guard operation == .pop else { return nil }

        guard let recognizer = navigationController.view.gestureRecognizers?.first(where: { recognizer -> Bool in
            return (recognizer is UIScreenEdgePanGestureRecognizer)
        }) as? UIScreenEdgePanGestureRecognizer else { return nil }

        return HorizontalSlideInteractiveController(animator: animationController,
                                                  gestureRecognizer: recognizer)
    }
}
