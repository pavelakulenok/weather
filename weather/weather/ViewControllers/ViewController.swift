//
//  ViewController.swift
//  weather
//
//  Created by Pavel Akulenak on 24.05.21.
//

import CoreLocation
import UIKit

class ViewController: UIViewController {
    enum DataSourceForRequest {
        case cityName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    enum TypeOfRequest {
        case currentWeather
        case forecastWeather
    }

    private var city: String?
    private var currentCityWeather: ListWeatherData?
    private var forecastCityWeather: WeatherData?
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    private lazy var locationManager = CLLocationManager()
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDiscriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var getWeatherButton: UIButton!
    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "ForecastWeatherTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else if let lastLongitude = UserDefaults.standard.value(forKey: "longitude"), let lastLatitude = UserDefaults.standard.value(forKey: "latitude") {
            longitude = lastLongitude as? CLLocationDegrees
            latitude = lastLatitude as? CLLocationDegrees
            getWeatherForLocation()
        } else if let lastCityNameEntered = UserDefaults.standard.string(forKey: "city") {
            city = lastCityNameEntered
            getWeatherForCityName()
        }
    }

    @IBAction private func onGetWeatherButton(_ sender: Any) {
        if let inputText = textField.text {
            if !inputText.isEmpty {
                let cityNameForRequest = inputText.split(separator: " ").joined(separator: "%20")
                city = cityNameForRequest
            }
        }
        getWeatherForCityName()
    }

    @IBAction private func onLocationButton(_ sender: Any) {
        locationManager.requestLocation()
    }

    private func setupUI() {
        textField.setupTextField(fontName: "HelveticaNeue-Medium", fontSize: 20, placeholderName: "City name")
        textField.stetupUIView(borderWidth: 2, cornerRadius: 10)
        getWeatherButton.setupButton(title: "Get", titleColor: .darkGray, fontName: "HelveticaNeue-Bold", fontSize: 30)
        getWeatherButton.stetupUIView(borderWidth: 2, cornerRadius: 10)
        currentWeatherView.stetupUIView(borderWidth: 2, cornerRadius: 10)
        cityNameLabel.setupLabel(fontName: "HelveticaNeue-Bold", fontSize: 30, fontColor: .darkGray)
        temperatureLabel.setupLabel(fontName: "HelveticaNeue-Bold", fontSize: 50, fontColor: .darkGray)
        weatherDiscriptionLabel.setupLabel(fontName: "HelveticaNeue-Bold", fontSize: 20, fontColor: .darkGray)
        feelsLikeLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .lightGray)
        minTemperatureLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .lightGray)
        maxTemperatureLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .lightGray)
        pressureLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .lightGray)
        humidityLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .lightGray)
        windLabel.setupLabel(fontName: "HelveticaNeue-Medium", fontSize: 20, fontColor: .lightGray)
        tableView.stetupUIView(borderWidth: 2, cornerRadius: 10)
        locationButton.setImage(UIImage(named: "location"), for: .normal)
        locationButton.tintColor = .darkGray
    }

    private func getWeather(dataSourseForRequest: DataSourceForRequest, typeOfRequest: TypeOfRequest) {
        var urlString = ""
        var type = ""
        switch typeOfRequest {
        case .currentWeather:
            type = "weather"
        case .forecastWeather:
            type = "forecast"
        }
        switch dataSourseForRequest {
        case let .cityName(city):
            urlString = "https://api.openweathermap.org/data/2.5/\(type)?q=\(city)&appid=9276e12f77d3514a750b09c32403379e"
        case let .coordinate(latitude, longitude):
            urlString = "https://api.openweathermap.org/data/2.5/\(type)?lat=\(latitude)&lon=\(longitude)&appid=9276e12f77d3514a750b09c32403379e"
        }
        guard let url = URL(string: urlString) else {
            return
        }
        let requestWeather = URLRequest(url: url)
        let dataTaskCurrentWeather = URLSession.shared.dataTask(with: requestWeather) { data, _, _ in
            guard let data = data else {
                assertionFailure("Can't get data from \(urlString)")
                return
            }
            do {
                switch typeOfRequest {
                case .currentWeather:
                    self.currentCityWeather = try JSONDecoder().decode(ListWeatherData.self, from: data)
                    UserDefaults.standard.setValue(self.city, forKey: "city")
                    DispatchQueue.main.async {
                        self.showCurrentCityWeather()
                    }
                case .forecastWeather:
                    self.forecastCityWeather = try JSONDecoder().decode(WeatherData.self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlertWithOneButton(title: "Can't find this city", message: "please, check the city name", actionTitle: "Ok", actionStyle: .default, handler: nil)
                }
            }
        }
        dataTaskCurrentWeather.resume()
    }

    private func getWeatherForLocation() {
        if let longitude = longitude, let latitude = latitude {
            getWeather(dataSourseForRequest: .coordinate(latitude: latitude, longitude: longitude), typeOfRequest: .currentWeather)
            getWeather(dataSourseForRequest: .coordinate(latitude: latitude, longitude: longitude), typeOfRequest: .forecastWeather)
        }
    }

    private func getWeatherForCityName() {
        if let cityName = city {
            getWeather(dataSourseForRequest: .cityName(city: cityName), typeOfRequest: .currentWeather)
            getWeather(dataSourseForRequest: .cityName(city: cityName), typeOfRequest: .forecastWeather)
        }
    }

    private func showCurrentCityWeather() {
        guard let info = currentCityWeather else {
            return
        }
        if let cityName = info.name {
            cityNameLabel.text = cityName
        }
        if let iconName = info.weather.first?.icon {
            imageView.image = getImage(name: iconName)
        }
        temperatureLabel.text = "\((info.main.temperature - 273.15).rounded(toPlaces: 1))℃"
        weatherDiscriptionLabel.text = info.weather.first?.description
        feelsLikeLabel.text = "feels like: \(Int((info.main.feelsLike - 273.15).rounded()))℃"
        windLabel.text = "wind: \((info.wind.speed).rounded(toPlaces: 1)) m/s, \(getWindDirection(deg: info.wind.deg)), gust: \((info.wind.gust).rounded(toPlaces: 1)) m/s"
        minTemperatureLabel.text = "min: \((info.main.temperatureMin - 273.15).rounded(toPlaces: 1))℃"
        maxTemperatureLabel.text = "max: \((info.main.temperatureMax - 273.15).rounded(toPlaces: 1))℃"
        pressureLabel.text = "pressure: \((info.main.pressure)) hPa"
        humidityLabel.text = "humidity: \((info.main.humidity))%"
    }

    private func getImage(name: String) -> UIImage {
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

    private func getWindDirection(deg: Int) -> String {
        let doubleDeg = Double(deg)
        var direction = ""
        if doubleDeg > 337.5 || doubleDeg <= 22.5 {
            direction = "N"
        } else if doubleDeg > 22.5 && doubleDeg <= 67.5 {
            direction = "NE"
        } else if doubleDeg > 67.5 && doubleDeg <= 112.5 {
            direction = "E"
        } else if doubleDeg > 112.5 && doubleDeg <= 157.5 {
            direction = "SE"
        } else if doubleDeg > 157.5 && doubleDeg <= 202.5 {
            direction = "S"
        } else if doubleDeg > 202.5 && doubleDeg <= 247.5 {
            direction = "SW"
        } else if doubleDeg > 247.5 && doubleDeg <= 292.5 {
            direction = "W"
        } else if doubleDeg > 292.5 && doubleDeg <= 337.5 {
            direction = "NW"
        }
        return direction
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = forecastCityWeather?.list.count else {
            return 0
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ForecastWeatherTableViewCell else {
            return UITableViewCell()
        }
        if let temperature = forecastCityWeather?.list[indexPath.row].main.temperature {
            cell.forecastTemperatureLabel.text = "\((temperature - 273.15).rounded(toPlaces: 1))℃"
        }
        if let iconName = forecastCityWeather?.list[indexPath.row].weather.first?.icon {
            cell.forecastImageView.image = getImage(name: iconName)
        }
        if let timestamp = forecastCityWeather?.list[indexPath.row].dt {
            let date = Date(timeIntervalSince1970: Double(timestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM HH.mm"
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            cell.dateLabel.text = localDate
        }
        cell.stetupUIView(borderWidth: 1, cornerRadius: 0)
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = locations.last?.coordinate.latitude
        longitude = locations.last?.coordinate.longitude
        UserDefaults.standard.setValue(latitude, forKey: "latitude")
        UserDefaults.standard.setValue(longitude, forKey: "longitude")
        getWeatherForLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        assertionFailure("\(error)")
    }
}
