//
//  RequestCoffeeNearby.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/16/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation


class RequestCoffeeNearby {
    
    func getForecast(lat: Double, long: Double, type: String) {
    
        let jsonURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=3200&type=\(type)&key=AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA"
        
        guard let urlString = URL(string: jsonURLString) else {
            print("Error: Cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: urlString)
        
        
        // Set up the session
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
        
                
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            switch httpResponse.statusCode {
                case 200:
                    do{
                
                        guard let data = data else { return }
                        
                        guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary else { return }
                        
                        print(json)
                
                        let arrayPlaces = json["results"] as! NSArray
                        print(arrayPlaces)
                        
                        var arrayOfLocations = [[Double(),Double()]]
                        var arrayOfNames = [String()]
                        
                        for i in 0..<arrayPlaces.count {
                            
                            let arrayForLocations = (((arrayPlaces[i] as! NSDictionary).object(forKey: "geometry") as! NSDictionary).object(forKey: "location") as! NSDictionary)
                        
                            let arrayForName = (arrayPlaces[i] as! NSDictionary).object(forKey: "name") as! String
                            
                            
                            arrayOfNames.append(arrayForName)
                            
                            arrayOfLocations.append([arrayForLocations.object(forKey: "lat") as! Double, arrayForLocations.object(forKey: "lng") as! Double])
                        
                        }
                        //for i in 0..<arrayPlaces.count {
                        
                            //arrayLocations.adding((arrayPlaces[i] as! NSDictionary).object(forKey: "geometry") as! NSArray)
                        //}
                        print(arrayOfLocations)
                        print(arrayOfNames)
                        
                        //let arrayCoordinates = arrayPlaces[]
                        //print(arrayCoordinates)
                        
                    }catch let error as NSError {
                        print(error.debugDescription)
                    }
                
                
                
                default:
                    print("HTTP Reponse Code: \(httpResponse.statusCode)")
                
            }
                
        }
        task.resume()
    
    
    }



}
