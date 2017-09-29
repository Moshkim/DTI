//
//  MulticolorPolyline.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/27/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

struct MulticolorPolyline {
   static let solidRed = GMSStrokeStyle.solidColor(.red)
   static let redToYellow = GMSStrokeStyle.solidColor(.orange)
   static let solidYellow = GMSStrokeStyle.solidColor(.yellow)
    static let yellowToGreen = GMSStrokeStyle.solidColor(UIColor.colorFromHex(hexString: "#DFFF00"))
   static let solidGreen = GMSStrokeStyle.solidColor(.green)
}
