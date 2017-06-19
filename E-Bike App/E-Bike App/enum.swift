//
//  enum.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 5/22/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps




class Destination: NSObject {
    let name: String
    let location: CLLocationCoordinate2D
    let zoom: Float
    
    
    init(name: String, location: CLLocationCoordinate2D, zoom: Float){
        self.name = name
        self.location = location
        self.zoom = zoom
    
    }
}

enum LocationCase {

    case startLocation
    case destinationLocation
    
}
