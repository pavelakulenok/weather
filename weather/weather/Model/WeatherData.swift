//
//  WeatherData.swift
//  weather
//
//  Created by Pavel Akulenak on 27.05.21.
//

import Foundation

struct City: Codable {
    let name: String
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double
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
    let city: City
}
