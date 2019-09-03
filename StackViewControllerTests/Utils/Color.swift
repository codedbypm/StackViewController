//
//  Color.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 02/09/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

enum Color: String, CaseIterable {
    case yellow
    case green
    case red
    case magenta
    case gray
    case blue
    case black


    var uiColor: UIColor {
        switch self {
        case .yellow: return .yellow
        case .green: return .green
        case .red: return .red
        case .magenta: return .magenta
        case .gray: return .gray
        case .blue: return .blue
        case .black: return .black
        }
    }

    var textColor: UIColor {
        switch self {
        case .red, .yellow, .magenta, .green : return .darkText
        case .blue, .black, .gray: return .lightText
        }
    }

    static var random: Color {
        return allCases.randomElement()!
    }
}
