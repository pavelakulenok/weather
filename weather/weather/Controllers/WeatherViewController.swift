//
//  ViewController.swift
//  weather
//
//  Created by Pavel Akulenak on 24.05.21.
//

import CoreLocation
import RxCocoa
import RxSwift
import UIKit

class WeatherViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = WeatherViewModel()
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
        bindButtons()
        bindWeatherViews()
        bindAlert()
        tableView.register(UINib(nibName: "ForecastWeatherTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        textField.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else if let lastCityName = UserDefaults.standard.string(forKey: "city") {
            viewModel.getWeather(dataSourse: .cityName(city: lastCityName))
        }
    }

    private func bindButtons() {
        getWeatherButton.rx.tap
            .subscribe { _ in
                if let inputText = self.textField.text {
                    if !inputText.isEmpty {
                        let cityNameForRequest = inputText.split(separator: " ").joined(separator: "%20")
                        self.viewModel.getWeather(dataSourse: .cityName(city: cityNameForRequest))
                    }
                }
            }
            .disposed(by: disposeBag)

        locationButton.rx.tap
            .subscribe { _ in
                self.locationManager.requestLocation()
            }
            .disposed(by: disposeBag)
    }

    private func bindWeatherViews() {
        viewModel.currentWeather
            .observe(on: MainScheduler.instance)
            .subscribe { currentWeather in
                guard let info = currentWeather.element else {
                    return
                }
                if let cityName = info.name {
                    self.cityNameLabel.text = cityName
                    UserDefaults.standard.setValue(cityName, forKey: "city")
                }
                if let iconName = info.weather.first?.icon {
                    self.imageView.image = self.viewModel.getImage(name: iconName)
                }
                self.temperatureLabel.text = "\((info.main.temperature - 273.15).rounded(toPlaces: 1))℃"
                self.weatherDiscriptionLabel.text = info.weather.first?.description
                self.feelsLikeLabel.text = "feels like: \(Int((info.main.feelsLike - 273.15).rounded()))℃"
                if let windDirection = info.wind.direction {
                    self.windLabel.text = "wind: \((info.wind.speed).rounded(toPlaces: 1)) m/s, \(windDirection), gust: \((info.wind.gust).rounded(toPlaces: 1)) m/s"
                }
                self.minTemperatureLabel.text = "min: \((info.main.temperatureMin - 273.15).rounded(toPlaces: 1))℃"
                self.maxTemperatureLabel.text = "max: \((info.main.temperatureMax - 273.15).rounded(toPlaces: 1))℃"
                self.pressureLabel.text = "pressure: \((info.main.pressure)) hPa"
                self.humidityLabel.text = "humidity: \((info.main.humidity))%"
                self.currentWeatherView.isHidden = false
            }
            .disposed(by: disposeBag)

        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: ForecastWeatherTableViewCell.self)) { _, item, cell in
                self.tableView.isHidden = false
                let temperature = item.main.temperature
                    cell.forecastTemperatureLabel.text = "\((temperature - 273.15).rounded(toPlaces: 1))℃"
                if let iconName = item.weather.first?.icon {
                    cell.forecastImageView.image = self.viewModel.getImage(name: iconName)
                }
                if let timestamp = item.dt {
                    let date = Date(timeIntervalSince1970: Double(timestamp))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd.MM HH.mm"
                    dateFormatter.timeZone = .current
                    let localDate = dateFormatter.string(from: date)
                    cell.dateLabel.text = localDate
                }
                cell.stetupUIView(borderWidth: 1, cornerRadius: 0)
            }
            .disposed(by: disposeBag)
    }

    private func bindAlert() {
        viewModel.errorAlertMessage
            .observe(on: MainScheduler.instance)
            .subscribe { event in
                if let message = event.element {
                    self.showAlertWithOneButton(title: "error", message: message, actionTitle: "Ok", actionStyle: .default, handler: nil)
                }
            }
            .disposed(by: disposeBag)
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
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latitude = locations.last?.coordinate.latitude, let longitude = locations.last?.coordinate.longitude {
            viewModel.getWeather(dataSourse: .coordinate(latitude: latitude, longitude: longitude))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        assertionFailure("\(error)")
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
