//
//  WeatherData.swift
//  weather
//
//  Created by Pavel Akulenak on 27.05.21.
//

import Foundation

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double
    var direction: String? {
        switch Double(deg) {
        case 22.5..<67.5:
            return "NE"
        case 67.5..<112.5:
            return "E"
        case 112.5..<157.5:
            return "SE"
        case 157.5..<202.5:
            return "S"
        case 202.5..<247.5:
            return "SW"
        case 247.5..<292.5:
            return "W"
        case 292.5..<337.5:
            return "NW"
        default:
            return "N"
        }
    }
}

struct Main: Codable {
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case temperatureMax = "temp_max"
        case temperatureMin = "temp_min"
        case pressure = "pressure"
        case humidity = "humidity"
    }

    let temperature: Double
    let feelsLike: Double
    let temperatureMax: Double
    let temperatureMin: Double
    let pressure: Int
    let humidity: Int
}

struct ListWeatherData: Codable {
    let name: String?
    let dt: Int?
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct WeatherData: Codable {
    let list: [ListWeatherData]
}
