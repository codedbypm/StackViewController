//
//  YellowViewController.swift
//  TestApp
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

class YellowViewController: UIViewController {

    let debugAppearance = true

    var onNext: (() -> Void)?
    var onReplaceViewControllers: (() -> Void)?
    var onEmptyStack: (() -> Void)?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = String(describing: YellowViewController.self)
        return label
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow

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
}

private extension YellowViewController {

    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(nextButton)
        view.addSubview(replaceViewControllersButton)
        view.addSubview(emptyStackButton)
    }

    func addSubviewsLayoutConstraints() {
        addTitleLabelLayoutConstraints()
        addNextButtonLayoutConstraints()
        addReplaceViewControllersButtonConstraints()
        addEmptyStackButtonConstraints()
    }

    func addTitleLabelLayoutConstraints() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }

    func addNextButtonLayoutConstraints() {
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 20.0).isActive = true
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
}
