
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
    
    
    struct WeatherKey{
    
        static let temperature = "temperature"
        static let sumary = "summary"
        
    }
    
    init(weatherDictionary: [String : Any]) {
        temperature = weatherDictionary[WeatherKey.temperature] as? Double
        summary = weatherDictionary[WeatherKey.sumary] as? String
    }

}
