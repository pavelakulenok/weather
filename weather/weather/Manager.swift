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

enum Manager {
    static func getWeather(dataSourse: DataSource, completionCurrentWeather: @escaping (ListWeatherData) -> Void, completionForecastWeather: @escaping (WeatherData) -> Void) {
        var urlStringCurrentWeather = ""
        var urlStringForecastWeather = ""
        switch dataSourse {
        case let .cityName(city):
            urlStringCurrentWeather = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=9276e12f77d3514a750b09c32403379e"
            urlStringForecastWeather = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=9276e12f77d3514a750b09c32403379e"
        case let .coordinate(latitude, longitude):
            urlStringCurrentWeather = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=9276e12f77d3514a750b09c32403379e"
            urlStringForecastWeather = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=9276e12f77d3514a750b09c32403379e"
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
