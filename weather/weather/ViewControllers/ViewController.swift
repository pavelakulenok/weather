//
//  ViewController.swift
//  weather
//
//  Created by Pavel Akulenak on 24.05.21.
//

import UIKit

class ViewController: UIViewController {
    private var city = "Minsk"
    private var currentCityWeather: ListWeatherData?
    private var forecastCityWeather: WeatherData?
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let lastCityNameEntered = UserDefaults.standard.string(forKey: "city") {
            city = lastCityNameEntered
        }
        tableView.register(UINib(nibName: "ForecastWeatherTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        getCityWeather()
    }

    @IBAction private func onGetWeatherButton(_ sender: Any) {
        if let inputText = textField.text {
            if !inputText.isEmpty {
                let cityNameForRequest = inputText.split(separator: " ").joined(separator: "%20")
                city = cityNameForRequest
            }
        }
        getCityWeather()
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
    }

    private func getCityWeather() {
        guard let urlCurrentWeather = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=9276e12f77d3514a750b09c32403379e") else {
            return
        }
        guard let urlForecastWeather = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=9276e12f77d3514a750b09c32403379e") else {
            return
        }
        let requestCurrentWeather = URLRequest(url: urlCurrentWeather)
        let requestForecastWeather = URLRequest(url: urlForecastWeather)

        let dataTaskCurrentWeather = URLSession.shared.dataTask(with: requestCurrentWeather) { data, _, _ in
            guard let data = data else {
                assertionFailure("Can't get data from \(urlCurrentWeather)")
                return
            }
            do {
                self.currentCityWeather = try JSONDecoder().decode(ListWeatherData.self, from: data)
                UserDefaults.standard.setValue(self.city, forKey: "city")
                DispatchQueue.main.async {
                    self.showCurrentCityWeather()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlertWithOneButton(title: "Can't find this city", message: "please, check the city name", actionTitle: "Ok", actionStyle: .default, handler: nil)
                }
            }
        }
        dataTaskCurrentWeather.resume()

        let dataTaskForecastWeather = URLSession.shared.dataTask(with: requestForecastWeather) { data, _, _ in
            guard let data = data else {
                assertionFailure("Can't get data from \(urlForecastWeather)")
                return
            }
            do {
                self.forecastCityWeather = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlertWithOneButton(title: "Can't find this city", message: "please, check the city name", actionTitle: "Ok", actionStyle: .default, handler: nil)
                }
            }
        }
        dataTaskForecastWeather.resume()
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
