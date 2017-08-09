//
//  ForecastService.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/8/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation

class ForecastService {

    let forecastAPIKey: String
    let forecastBaseURL: URL?
    
    //37.39299238
    //-122.17434528
    
    // https://forecastBaseURL/forecastAPIKey/lat,long
    
    //33c371344898311931ea3058dcc4730f
    init(APIKey: String) {
        forecastAPIKey = APIKey
        forecastBaseURL = URL(string: "https://api.darksky.net/forecast/\(forecastAPIKey)")
    }
    
    func getForecast(lat: Double, long: Double, completion: @escaping (CurrentWeather?) -> Void) {
    
        if let forecastURL = URL(string: "\(forecastBaseURL!)/\(lat),\(long)"){
            let networkProcessor = NetworkProcessor(url: forecastURL)
            
            networkProcessor.downloadJSONFromURL({ (jsonDictionary) in
                // TODO: Somehow parse jsonDictionary into a swfit weather object
                if let currentWeatherDictionary = jsonDictionary?["currently"] as? [String: Any]{
                    let currentWeather = CurrentWeather(weatherDictionary: currentWeatherDictionary)
                    completion(currentWeather)
                
                } else {
                
                    completion(nil)
                }
            })
        
        }
    }
    
}
