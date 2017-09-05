

import CoreLocation

class LocationManager {

    
    static let shared: CLLocationManager = {
        
        if Thread.isMainThread{
            return CLLocationManager()
        } else {
            return DispatchQueue.main.sync {
                return CLLocationManager()
            }
        
        }
    
    }()
  
    private init() { }
}
