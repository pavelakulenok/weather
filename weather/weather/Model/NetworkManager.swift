//
//  Manager.swift
//  weather
//
//  Created by Pavel Akulenak on 7.06.21.
//

import CoreLocation
import Foundation

enum DataSource {
    case cityName(city: String)
    case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

enum NetworkManager {
    static func getWeather(dataSourse: DataSource, completionCurrentWeather: @escaping (ListWeatherData) -> Void, completionForecastWeather: @escaping (WeatherData) -> Void) {
        let baseCurrentWeatherURLString = "https://api.openweathermap.org/data/2.5/weather"
        let baseForecastWeatherURLString = "https://api.openweathermap.org/data/2.5/forecast"
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            assertionFailure()
            return
        }
        let keys = NSDictionary(contentsOfFile: path)
        guard let apiKey = keys?.value(forKey: "API Key") else {
            assertionFailure()
            return
        }
        var urlStringCurrentWeather = ""
        var urlStringForecastWeather = ""
        switch dataSourse {
        case let .cityName(city):
            urlStringCurrentWeather = "\(baseCurrentWeatherURLString)?q=\(city)&appid=\(apiKey)"
            urlStringForecastWeather = "\(baseForecastWeatherURLString)?q=\(city)&appid=\(apiKey)"
        case let .coordinate(latitude, longitude):
            urlStringCurrentWeather = "\(baseCurrentWeatherURLString)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
            urlStringForecastWeather = "\(baseForecastWeatherURLString)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        }
        guard let urlCurrentWeather = URL(string: urlStringCurrentWeather) else {
            return
        }
        guard let urlForecastWeather = URL(string: urlStringForecastWeather) else {
            return
        }
        let requestCurrentWeather = URLRequest(url: urlCurrentWeather)
        let requestForecastWeather = URLRequest(url: urlForecastWeather)
        let dataTaskCurrentWeather = URLSession.shared.dataTask(with: requestCurrentWeather) { data, _, _ in
            guard let data = data else {
                assertionFailure("Can't get data from \(urlStringCurrentWeather)")
                return
            }
            do {
                let currentCityWeather = try JSONDecoder().decode(ListWeatherData.self, from: data)
                completionCurrentWeather(currentCityWeather)
            } catch {
                assertionFailure("error: can't decode json")
            }
        }
        dataTaskCurrentWeather.resume()
        let dataTaskForecastWeather = URLSession.shared.dataTask(with: requestForecastWeather) { data, _, _ in
            guard let data = data else {
                assertionFailure("Can't get data from \(urlStringForecastWeather)")
                return
            }
            do {
                let forecastCityWeather = try JSONDecoder().decode(WeatherData.self, from: data)
                completionForecastWeather(forecastCityWeather)
            } catch {
                assertionFailure("error: can't decode json")
            }
        }
        dataTaskForecastWeather.resume()
    }
}
