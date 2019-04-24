//
//  BaseViewController.swift
//  TestApp
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    let debugAppearance = true
    let debugViewControllerContainment = true

    var onNext: (() -> Void)?
    var onReplaceViewControllers: (() -> Void)?
    var onEmptyStack: (() -> Void)?
    var onBack: (() -> Void)?

    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show next view controller", for: .normal)
        button.addTarget(self, action: #selector(didTapShowNext), for: .touchUpInside)
        return button
    }()

    lazy var replaceViewControllersButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Replace viewControllers", for: .normal)
        button.addTarget(self, action: #selector(didTapReplaceViewControllers), for: .touchUpInside)
        return button
    }()

    lazy var emptyStackButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Empty stack", for: .normal)
        button.addTarget(self, action: #selector(emptyStack), for: .touchUpInside)
        return button
    }()

    private let backgroundColor: UIColor
    private let showsBackButton: Bool
    
    required init(color: UIColor, title: String, showsBackButton: Bool = true) {
        backgroundColor = color
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor

        addSubviews()
        addSubviewsLayoutConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if debugAppearance {
            print("\(String(describing: self)): viewWillAppear")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if debugAppearance {
            print("\(String(describing: self)): viewDidAppear")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if debugAppearance {
            print("\(String(describing: self)): viewWillDisappear")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if debugAppearance {
            print("\(String(describing: self)): viewDidDisappear")
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if debugViewControllerContainment {
            print("\(String(describing: self)): willMove(toParent: \(String(describing: parent))")
        }
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if debugViewControllerContainment {
            print("\(String(describing: self)): didMove(toParent: \(String(describing: parent))")
        }
    }

    override var debugDescription: String {
        return "BaseViewController: \(navigationItem.title!)"
    }
}

private extension BaseViewController {

    func addSubviews() {
        view.addSubview(backButton)
        view.addSubview(nextButton)
        view.addSubview(replaceViewControllersButton)
        view.addSubview(emptyStackButton)
    }

    func addSubviewsLayoutConstraints() {
        addBackButtonLayoutConstraints()
        addNextButtonLayoutConstraints()
        addReplaceViewControllersButtonConstraints()
        addEmptyStackButtonConstraints()
    }

    func addBackButtonLayoutConstraints() {
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 40.0).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.0).isActive = true
        backButton.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }

    func addNextButtonLayoutConstraints() {
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 40.0).isActive = true
        nextButton.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }

    func addReplaceViewControllersButtonConstraints() {
        replaceViewControllersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        replaceViewControllersButton.topAnchor.constraint(greaterThanOrEqualTo: nextButton.bottomAnchor, constant: 20.0).isActive = true
        replaceViewControllersButton.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }

    func addEmptyStackButtonConstraints() {
        emptyStackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStackButton.topAnchor.constraint(greaterThanOrEqualTo: replaceViewControllersButton.bottomAnchor, constant: 20.0).isActive = true
        emptyStackButton.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }

    @objc func didTapShowNext() {
        onNext?()
    }

    @objc func didTapReplaceViewControllers() {
        onReplaceViewControllers?()
    }

    @objc func emptyStack() {
        onEmptyStack?()
    }

    @objc func didTapBack() {
        onBack?()
    }
}
