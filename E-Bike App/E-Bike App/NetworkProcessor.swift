//
//  NetworkProcessor.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/8/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation

class NetworkProcessor {
    
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    
    lazy var session: URLSession = URLSession(configuration: self.configuration)

    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    
    // api.darksky.net/forecast/d224f7da1fbbabe89fd206fcfbcf4868/37.8267,-122.4233
    
    
    typealias JSONDictionaryHandler = (([String : Any]?) -> Void)
    
    func downloadJSONFromURL(_ completion: @escaping JSONDictionaryHandler){
    
        let request = URLRequest(url: self.url)
        let dataTask = session.dataTask(with: request){ (data, response, error) in
        
            if error != nil{
                print("Error: \(String(describing: error?.localizedDescription))")
            
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        // Successful response
                        if let data = data{
                            
                            do{
                                let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                                completion(jsonDictionary as? [String : Any])
                            
                            } catch let error as NSError {
                                print("Error processing json data: \(error)")
                            
                            }
                        }
                        
                    default:
                        print("HTTP Reponse Code: \(httpResponse.statusCode)")
                    
                    
                    }
                
                
                }
            
            }
        
        }
        
        dataTask.resume()
    }
    

}
