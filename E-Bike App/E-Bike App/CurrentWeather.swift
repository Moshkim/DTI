
//
//  currentWeather.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/8/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation



class CurrentWeather {
    
    let temperature: Double?
    let summary: String?
    let weatherStatus: String?
    let humidity: Double?
    
    struct WeatherKey{
        static let temperature = "temperature"
        static let summary = "summary"
        static let weatherStatus = "icon"
        static let humidity = "humidity"
    }
    
    init(weatherDictionary: [String : Any]) {
        temperature = weatherDictionary[WeatherKey.temperature] as? Double
        summary = weatherDictionary[WeatherKey.summary] as? String
        weatherStatus = weatherDictionary[WeatherKey.weatherStatus] as? String
        humidity = weatherDictionary[WeatherKey.humidity] as? Double
    }

}

