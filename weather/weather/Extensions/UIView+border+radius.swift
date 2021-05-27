//
//  UIView+border+radius.swift
//  weather
//
//  Created by Pavel Akulenak on 26.05.21.
//

import UIKit

extension UIView {
    func stetupUIView(borderWidth: CGFloat, cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        clipsToBounds = true
    }
}
