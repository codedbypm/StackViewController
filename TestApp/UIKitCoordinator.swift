//
//  UIKitCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 20/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

extension UINavigationController: StackViewControllerHandling {}

class UIKitCoordinator: NSObject {

    lazy var navigationController: NavigationController = {
//        let root = BaseViewController.colored(.yellow)
        let navController = NavigationController()
//        root.stack = navController
//        navController.push(root, animated: false)

        navController.delegate = self
        navController.tabBarItem = UITabBarItem(title: String(describing: navController),
                                                image: nil,
                                                tag: 1)
        return navController
    }()

    var interactionController: InteractivePopAnimator?
}

extension UIKitCoordinator: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

//        print("Operation: \(operation.rawValue)")
//        print("From: \(fromVC)")
//        print("To: \(toVC == nil ? "nil" : toVC.description)")

        switch operation {
        case .push:
            return PushAnimator()
        case .pop:
            return PopAnimator()
        default:
            return nil
        }
    }

    //    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    //
    //        guard let gestureRecognizer = navigationController.interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer else { return nil }
    //
    //        gestureRecognizer.removeTarget(nil, action: nil)
    //        interactionController = HorizontalSlideInteractiveController(animationController: animationController,
    //                                                                     gestureRecognizer: gestureRecognizer)
    //        return interactionController
    //    }
}
