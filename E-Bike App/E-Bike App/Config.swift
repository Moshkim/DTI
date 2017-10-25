
//
//  File.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/7/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation



struct Window {
    static let Size = UIApplication.shared.keyWindow

}

struct appDel {
    static let appDelegate = UIApplication.shared.delegate as? AppDelegate
}

struct SettingConfig {
    static var WeatherEnable            = true
}


struct DrivingMode {
    static let BICYCLING = "bicycling"
    static let DRIVING = "driving"
    
}


struct Config {
    static var STORAGE_ROOT_REF         = "gs://e-bike-app.appspot.com"
    static var DATABASE_ROOT_REF        = "https://e-bike-app.firebaseio.com"
    
    
    // GOOGLE MAP API KEY
    static var GOOGLE_API_KEY           = "AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA"
    
    
    // WEATHER FORECAST API KEY
    static var FORECAST_API_KEY         = "d224f7da1fbbabe89fd206fcfbcf4868"
}

struct Device {
    
    //HEART RATE MONITOR UUID
    static let HEART_RATE_DEVICE        = "0x180D"
    static let DEVICE_INFOMATION        = "0x180A"
}


struct Characteristic {
    
    // HEART RATE MONITOR DEVICE CHARACTERISTICS
    
    static let HEART_RATE_MEASUREMENT   = "2A37"
    static let BODY_SENSOR_LOCATION     = "2A38"
    static let HRM_MANUFACTURER_NAME    = "2A29"
    static let HEART_RATE_CONTROL_POINT = "2A39"
}
