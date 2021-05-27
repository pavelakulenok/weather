//
//  ForecastWeatherTableViewCell.swift
//  weather
//
//  Created by Pavel Akulenak on 27.05.21.
//

import UIKit

class ForecastWeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var forecastTemperatureLabel: UILabel!
    @IBOutlet weak var forecastImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .darkGray)
        forecastTemperatureLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .darkGray)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
