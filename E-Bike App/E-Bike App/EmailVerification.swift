//
//  EmailVerification.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/30/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation


struct StringVerification {

    
    static func emailValidation(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let result = regex.matches(in: emailAddressString, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if result.count == 0 {
                returnValue = false
            }
        } catch let error as NSError{
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
            
        }
        return returnValue
    }

}
