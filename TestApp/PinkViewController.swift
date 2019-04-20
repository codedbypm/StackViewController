//
//  PinkViewController.swift
//  TestApp
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

class PinkViewController: UIViewController {

    let debugAppearance = false

    var onBack: (() -> Void)?
    var onNext: (() -> Void)?

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
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pink"
        view.backgroundColor =  UIColor(red: 250/255,
                                        green: 130/255,
                                        blue: 160/255,
                                        alpha: 1.0)

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

    @objc func didTapNext() {
        onNext?()
    }

    @objc func didTapBack() {
        onBack?()
    }
}

private extension PinkViewController {

    func addSubviews() {
        view.addSubview(backButton)
        view.addSubview(nextButton)
    }

    func addSubviewsLayoutConstraints() {
        addBackButtonLayoutConstraints()
        addNextButtonLayoutConstraints()
    }

    func addBackButtonLayoutConstraints() {
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.0).isActive = true
        backButton.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }

    func addNextButtonLayoutConstraints() {
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nextButton.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }

}
