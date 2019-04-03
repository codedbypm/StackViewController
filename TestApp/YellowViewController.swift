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

    var didTapNext: (() -> Void)?

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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        addSubviews()
        addSubviewsLayoutConstraints()
    }
}

private extension YellowViewController {

    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(nextButton)
    }

    func addSubviewsLayoutConstraints() {
        addTitleLabelLayoutConstraints()
        addNextButtonLayoutConstraints()
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

    @objc func didTapShowNext() {
        didTapNext?()
    }
}
