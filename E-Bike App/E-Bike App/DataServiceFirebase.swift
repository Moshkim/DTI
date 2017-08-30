//
//  DataServiceFirebase.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/29/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import KeychainSwift

let DB_BASE = Database.database().reference()

class DataServiceFirebase {
    
    fileprivate var _keyChain = KeychainSwift()
    fileprivate var _refDatabase = DB_BASE
    
    var keyChain: KeychainSwift{
        get{
            return _keyChain
        } set {
            _keyChain = newValue
        }
    
    }

}
