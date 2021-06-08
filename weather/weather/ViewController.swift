//
//  ViewController.swift
//  weather
//
//  Created by Pavel Akulenak on 24.05.21.
//

import CoreLocation
import UIKit

class ViewController: UIViewController {
    private var city: String?
    private var currentCityWeather: ListWeatherData?
    private var forecastCityWeather: WeatherData?
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    private var locationManager = CLLocationManager()

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
        textField.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else if let lastCityName = UserDefaults.standard.string(forKey: "city") {
            getWeather(dataSourse: .cityName(city: lastCityName))
        }
    }

    @IBAction private func onGetWeatherButton(_ sender: Any) {
        if let inputText = textField.text {
            if !inputText.isEmpty {
                let cityNameForRequest = inputText.split(separator: " ").joined(separator: "%20")
                city = cityNameForRequest
                getWeather(dataSourse: .cityName(city: cityNameForRequest))
            }
        }
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
        currentWeatherView.isHidden = true
        tableView.isHidden = true
    }

    private func getWeather(dataSourse: DataSource) {
        switch dataSourse {
        case .cityName:
            if let cityName = city {
                Manager.getWeather(dataSourse: .cityName(city: cityName)) { currentCityWeather in
                    DispatchQueue.main.async {
                        self.currentCityWeather = currentCityWeather
                        self.showCurrentCityWeather()
                        self.currentWeatherView.isHidden = false
                    }
                } completionForecastWeather: { forecastCityWeather in
                    DispatchQueue.main.async {
                        self.forecastCityWeather = forecastCityWeather
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                    }
                }
            }
        case .coordinate:
            if let longitude = longitude, let latitude = latitude {
                Manager.getWeather(dataSourse: .coordinate(latitude: latitude, longitude: longitude)) { currentCityWeather in
                    DispatchQueue.main.async {
                        self.currentCityWeather = currentCityWeather
                        self.showCurrentCityWeather()
                        self.currentWeatherView.isHidden = false
                    }
                } completionForecastWeather: { forecastCityWeather in
                    DispatchQueue.main.async {
                        self.forecastCityWeather = forecastCityWeather
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                    }
                }
            }
        }
    }

    private func showCurrentCityWeather() {
        guard let info = currentCityWeather else {
            return
        }
        if let cityName = info.name {
            cityNameLabel.text = cityName
            UserDefaults.standard.setValue(cityName, forKey: "city")
        }
        if let iconName = info.weather.first?.icon {
            imageView.image = getImage(name: iconName)
        }
        temperatureLabel.text = "\((info.main.temperature - 273.15).rounded(toPlaces: 1))℃"
        weatherDiscriptionLabel.text = info.weather.first?.description
        feelsLikeLabel.text = "feels like: \(Int((info.main.feelsLike - 273.15).rounded()))℃"
        if let windDirection = info.wind.direction {
            windLabel.text = "wind: \((info.wind.speed).rounded(toPlaces: 1)) m/s, \(windDirection), gust: \((info.wind.gust).rounded(toPlaces: 1)) m/s"
        }
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
        if let latitude = latitude, let longitude = longitude {
            getWeather(dataSourse: .coordinate(latitude: latitude, longitude: longitude))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        assertionFailure("\(error)")
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
