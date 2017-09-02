//
//  AuthService.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/31/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Firebase

class AuthService {
    
    //static var shared = AuthService()
    //static var storageRootRef = ""
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error ) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            } else {
                let keyChain = DataServiceFirebase().keyChain
                keyChain.set((user?.uid)!, forKey: "uid")
                
                onSuccess()
            }
        })
    }

    
    static func signUp(name: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                onError(error!.localizedDescription)
                
            } else {
                
                
                guard let uid = user?.uid else { return }
                let storageRef = Storage.storage().reference(forURL: "gs://e-bike-app.appspot.com").child("profile_image").child(uid)
                let userRef = Database.database().reference(fromURL: "https://e-bike-app.firebaseio.com").child("users").child(uid)
                

                storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                
                    if error != nil {
                        return
                        
                    }
                    
                    let profileImageURL = metaData?.downloadURL()?.absoluteString
                    userRef.setValue(["username": name, "email": email, "profileImageURL": profileImageURL])
            
                    onSuccess()
                })
            }
            
        })
    }

    
    


}
