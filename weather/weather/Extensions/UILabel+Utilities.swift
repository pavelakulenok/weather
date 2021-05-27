//
//  UILabel+Utilities.swift
//  weather
//
//  Created by Pavel Akulenak on 26.05.21.
//

import UIKit

extension UILabel {
    func setupLabel(fontName: String, fontSize: CGFloat, fontColor: UIColor) {
        textAlignment = .center
        textColor = fontColor
        font = UIFont(name: fontName, size: fontSize)
    }
}
