//
//  NearPlaces.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/15/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation

class CoffeeNear {
    
    let latitude: Double?
    let longitude: Double?
    let vicinity: String?
    let name: String?
    
    struct nearbyPlacesKey{
        static let latitude = "lat"
        static let longitude = "lng"
        static let vicinity = "vicinity"
        static let name = "name"
    }
    
    init(nearbyDictionary: [String : Any]) {
        latitude = nearbyDictionary[nearbyPlacesKey.latitude] as? Double
        longitude = nearbyDictionary[nearbyPlacesKey.longitude] as? Double
        vicinity = nearbyDictionary[nearbyPlacesKey.vicinity] as? String
        name = nearbyDictionary[nearbyPlacesKey.name] as? String
    }

    
    
    
}


