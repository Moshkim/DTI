//
//  RouteStore.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/15/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

private let eBikeStoreSharedInstance = RouteStore()

class RouteStore: NSObject {


    class var sharedInstance: RouteStore {
        return eBikeStoreSharedInstance
    }
    
}
