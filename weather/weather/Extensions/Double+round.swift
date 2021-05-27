//
//  Double+round.swift
//  weather
//
//  Created by Pavel Akulenak on 25.05.21.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
