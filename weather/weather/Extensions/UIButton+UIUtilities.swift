//
//  UIButton+UIUtilities.swift
//  weather
//
//  Created by Pavel Akulenak on 26.05.21.
//

import UIKit

extension UIButton {
    func setupButton(title: String, titleColor: UIColor, fontName: String, fontSize: CGFloat) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont(name: fontName, size: fontSize)
    }
}
