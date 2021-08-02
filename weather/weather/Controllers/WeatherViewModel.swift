//
//  WeatherViewModel.swift
//  weather
//
//  Created by Pavel Akulenak on 2.07.21.
//

import CoreLocation
import RxRelay

enum DataSource {
    case cityName(city: String)
    case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class WeatherViewModel {
    var currentWeather = PublishRelay<ListWeatherData>()
    var forecastWeather = PublishRelay<WeatherData>()
    var items = PublishRelay<[ListWeatherData]>()
    var errorAlertMessage = PublishRelay<String>()

    func getWeather(dataSourse: DataSource) {
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
        let dataTaskCurrentWeather = URLSession.shared.dataTask(with: requestCurrentWeather) { data, _, error in
            if error != nil {
                self.errorAlertMessage.accept("network error")
            }
            guard let data = data else {
                assertionFailure("Can't get data from \(urlStringCurrentWeather)")
                return
            }
            do {
                let currentWeather = try JSONDecoder().decode(ListWeatherData.self, from: data)
                self.currentWeather.accept(currentWeather)
            } catch {
                self.errorAlertMessage.accept("can't find info for this place")
            }
        }
        dataTaskCurrentWeather.resume()
        let dataTaskForecastWeather = URLSession.shared.dataTask(with: requestForecastWeather) { data, _, _ in
            guard let data = data else {
                assertionFailure("Can't get data from \(urlStringForecastWeather)")
                return
            }
            do {
                let forecastWeather = try JSONDecoder().decode(WeatherData.self, from: data)
                self.forecastWeather.accept(forecastWeather)
                self.items.accept(forecastWeather.list)
            } catch {
                self.errorAlertMessage.accept("can't find info for this place")
            }
        }
        dataTaskForecastWeather.resume()
    }

    func getImage(name: String) -> UIImage {
        var image: UIImage?
        if let url = URL(string: "https://openweathermap.org/img/wn/\(name)@2x.png") {
            do {
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
            } catch {
                assertionFailure("Can't get image from \(url)")
            }
        }
        guard let image = image else {
            return UIImage()
        }
        return image
    }
}
