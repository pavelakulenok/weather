//
//  UITextField+UIUtilities.swift
//  weather
//
//  Created by Pavel Akulenak on 26.05.21.
//

import UIKit

extension UITextField {
    func setupTextField(fontName: String, fontSize: CGFloat, placeholderName: String) {
        textAlignment = .center
        placeholder = placeholderName
        font = UIFont(name: fontName, size: fontSize)
    }
}
