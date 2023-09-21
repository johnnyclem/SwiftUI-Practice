//
//  WeatherItem.swift
//  SwiftUI-Weather
//
//  Created by Jonathan Clem on 9/21/23.
//

import Foundation

enum WeatherError: Error {
    case InvalidURL
}

struct WeatherItem: Identifiable {
    let id = UUID()
    var dayOfWeek: String
    var imageName: String
    var temperature: Int
    
    static func startingWeatherSet() -> [WeatherItem] {
        return [WeatherItem(dayOfWeek: "TUE", imageName: "cloud.sun.fill", temperature: 74), WeatherItem(dayOfWeek: "WED", imageName: "sun.max.fill", temperature: 95), WeatherItem(dayOfWeek: "THU", imageName: "sun.haze.fill", temperature: 55), WeatherItem(dayOfWeek: "FRI", imageName: "cloud.drizzle.fill", temperature: 45), WeatherItem(dayOfWeek: "SAT", imageName: "cloud.sleet.fill", temperature: 28)]
    }
    
    static func getUpdatedWeather() async throws -> [WeatherItem] {
        var weatherItems = [WeatherItem]()

        // create the url for the weather call for the given location (static for now)
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=29.9891&longitude=-97.8772&daily=temperature_2m_max,showers_sum,snowfall_sum&temperature_unit=fahrenheit") else {
            throw WeatherError.InvalidURL
        }
        
        // call api and get JSON data for next 5 days of weather
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // parse the JSON into WeatherItem objects
        let weatherData = try JSONDecoder().decode(WeatherWeek.self, from: data)
        
        print(weatherData)
        
        for i in 0...4 {
            let temp = Int(weatherData.daily.temperature2MMax[i])
            let dayOfWeek = getDayOfWeek(weatherData.daily.time[i])
            var imageName = "sun.max.fill"
            if weatherData.daily.showersSum[i] > 0.0 {
                imageName = "cloud.rain.fill"
            }
            let weatherItem = WeatherItem(dayOfWeek: dayOfWeek, imageName: imageName, temperature: temp)
            weatherItems.append(weatherItem)
        }
        return weatherItems.isEmpty ? WeatherItem.startingWeatherSet() : weatherItems
    }
}

// MARK: - WeatherWeek
struct WeatherWeek: Codable {
    let latitude, longitude: Double
    let timezoneAbbreviation: String
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case timezoneAbbreviation = "timezone_abbreviation"
        case daily
    }
}

// MARK: - Daily
struct Daily: Codable {
    let time: [String]
    let temperature2MMax, showersSum: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2MMax = "temperature_2m_max"
        case showersSum = "showers_sum"
    }
}

func getDayOfWeek(_ today:String) -> String {
    let formatter  = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let todayDate = formatter.date(from: today) else { return "ERR" }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate)
    switch weekDay {
    case 1:
        return "SUN"
    case 2:
        return "MON"
    case 3:
        return "TUE"
    case 4:
        return "WED"
    case 5:
        return "THU"
    case 6:
        return "FRI"
    case 7:
        return "SAT"
    default:
        return "ERR"
    }
}

