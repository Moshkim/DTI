
//
//  File.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/24/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import CoreBluetooth


struct Device {
    
    //Heart Rate Monitor UUID
    //Wahoo Fitness Equipment Service
    
    static let heartRateServiceInfoUUID = "180A"
    
    static let totalServiceUUID = "A026EE07-0A7D-4AB3-97FAF1500F9FEB8B"
 
    
    
    static let characteristicUUID = "A026E01D-0A7D-4AB3-97FAF1500F9FEB8B"
}


enum ServiceUUID: String{

    case HeartRate          = "0x180D"
    case DeviceInformation  = "0x180A"
    
    static func uuid(enumName: ServiceUUID) -> CBUUID {
        return CBUUID(String: enumName.rawValue)
    }
    
    static func uuids(enumNames: [ServiceUUID]) -> [CBUUID]{
    
        return enumNames.map {uuid($0)}
    }
}

enum HeartRateCharacteristicUUID: String {
    
    // Heart Rate Characteristics
    case HeartRateMeasurement   = "0x2A37"
    case BodySensorLocation     = "0x2A38"

    
    static func uuid(enumName: HeartRateCharacteristicUUID) -> CBUUID {
        return CBUUID(string: enumName.rawValue)
    }
    
    static func uuids(enumNames: [HeartRateCharacteristicUUID]) -> [CBUUID] {
        return enumNames.map {uuid($0)}
    
    }
}


enum DeviceInformationCharacteristicUUID : String{

    // Device Information Characteristics
    case ManufacturerName   = "0x2A29"
    case ModelNumber        = "0x2A24"
    case HardwareRevision   = "0x2A27"
    
    
    static func uuid(enumName: DeviceInformationCharacteristicUUID) -> CBUUID {
        return CBUUID(string: enumName.rawValue)
    }
    
    static func uuids(enumNames: [DeviceInformationCharacteristicUUID]) -> [CBUUID] {
        return enumNames.map {uuid($0)}
        
    }

}
