//
//  RideStatusViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 7/7/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacesSearchController
import CoreLocation
import CoreData
import MapKit
import LocalAuthentication
import CoreBluetooth


class RiderStatusViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, MKMapViewDelegate{


    // JSON format for the get direction between two points
    
    
    enum JSONError: String, Error {
        case NoData = "Error: No Data"
        case ConversionFailed = "Error: Conversion from JSON failed"
    
    }
    
    /******************************************************************************************************/
    
    // Bluetooth Delegate
    
    var centralManager: CBCentralManager!
    var deviceConnectTo: CBPeripheral?
    
    // Bluetooth status
    var keepScanning = false
    
    // define our scanning interval times
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0
    
    //Temporary UUID or name
    // FIXIT - We need to find the right devices to integrate with
    let WahooHeartMonitorSensor = "TICKR 2DD7"
    var hrSensorName: String?
    
    
    let BEAN_SCRATCH_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    
    
    // Core Bluetooth properties
    
    var heartRateMonitorCharacteristic: CBCharacteristic?
    
    /******************************************************************************************************/
    
    
    
    // Changing the current location dot with our own icon or something!
    var userCurrentLocationMarker = GMSMarker()
    var GeoAngle = 0.0
    
    
    // Google API info between two points
    // Direction to Destination
    fileprivate var destinationTag = 0
    fileprivate var totalremainingDistance = Double()
    fileprivate var totalremainingDuration = Double()
    

    // Core Data stack infomation variables
    
    fileprivate var ride:Ride?
    fileprivate var distance = Measurement(value: 0, unit: UnitLength.miles)
    fileprivate var address: [String] = []
    fileprivate var locationList: [CLLocation] = []
    fileprivate var locationListWithDistance = [[CLLocation(),Double()]]
    fileprivate var timer: Timer?
    fileprivate var totalMovingTimer: Timer?
    
    
    fileprivate let locationManager = LocationManager.shared
    fileprivate var seconds = 0
    fileprivate var startLocation: CLLocation!
    fileprivate var lastLocation: CLLocation!
    fileprivate var totalTravelDistance: Double = 0
    fileprivate var movingSeconds = 0
    fileprivate var speedTag = 0
    

    // Weather Infomation Variables
    
    fileprivate let forecastAPIKey = "d224f7da1fbbabe89fd206fcfbcf4868"
    fileprivate var currentTemperature: Double?
    fileprivate var currentWeatherIcon: String?
    fileprivate var currentWeatherSummary: String?
    fileprivate var iconString: String?
    
    
    
    
    // Direction to Coffee places
    
    var latDirection = Double()
    var longDirection = Double()
    

    
    
    // Map View Polyline
    
    let path = GMSMutablePath()
    
    
    // Overall Path between two points
    var polyPath = GMSPolyline()
    
    
    let placesClient = GMSPlacesClient.shared()
    
    
    
    // Camera Tag
    
    var cameraTag = 0
    
    

    var likeltPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    
    var infoMarker = GMSMarker()
    
    var totalMovingTime: Int?
    
    
    
    
    
    var indexForFeature: Int!
    
    
    // Display on the dashboard
    var thirdData = UILabel()
    var thirdDataSecond = UILabel()
    var thirdDataThird = UILabel()
    var timeFromStart = UILabel()
    var distanceLabel = UILabel()
    
    
    
    // Labels of Display dock
    
    let labelArray = ["Speed", "Consumption", "Distance", "Time", "Calories(KCal)", "Heart", "Battery Life"]
    
    
    let descriptionArray = ["Rider Power(W)","Motor Power(W)","Speed(mph)","Consumption(Wh/mi)", "Distance(mi)","Cadence(rpm)","Time From Start","Elevation Gain(ft)", "Battery Level(%)", "Calories(KCal)", "Heart Monitoring(bpm)", "Goal"]
    
    var screenOne = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Time From Start","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenTwo = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenThree = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenFour = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenFive = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    

    
    var featureArray = [Dictionary<String, Any>]()
    
    
    lazy var ScrollView: UIScrollView = {
    
        let view = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        
        view.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
        
        return view
    
    }()
    
    
    let statusViewControl: UIPageControl = {
        let bar = UIPageControl(frame: CGRect(x: 0, y: 0, width:50, height: 30))
        bar.pageIndicatorTintColor = UIColor.DTIBlue()
        bar.currentPageIndicatorTintColor = UIColor.DTIRed()
        return bar
    }()
    
    let mainTitle: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width:120, height: 30))
        label.textAlignment = .center
        label.text = "Ride Status"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.layer.zPosition = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    
    let mapView: GMSMapView = {
        
        let view = GMSMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.layer.cornerRadius = 25
        view.mapType = .normal
        view.settings.setAllGesturesEnabled(true)
        view.tintColor = UIColor.DTIBlue()
        
        view.setMinZoom(5, maxZoom: 20)
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        let mapInsets = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)
        view.padding = mapInsets
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var coffeSearchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = button.frame.width/2
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.DTIBlue()
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(named: "coffeePlaces")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(POIForCoffee), for: .touchUpInside)
        
        return button
    }()
    

    lazy var directionToDestButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = button.frame.width/2
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.DTIBlue()
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        
        button.setImage(UIImage(named: "bike")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(directionToDest), for: .touchUpInside)
        
        return button
    }()
    
    
    
    func directionToDest(sender: UIButton) {
        
        let lat = latDirection
        let long = longDirection
        let position = CLLocationCoordinate2DMake(lat, long)
        locationManager.startUpdatingHeading()
        
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage(named: "direction")?.withRenderingMode(.alwaysTemplate), for: .normal)
            drawRouteBetweenTwoPoints(coordinate: position)
        }
        if sender.tag == 1 {
            sender.tag = 0
            
            
            // MARK - Destination tag should be on in order to keep track remaining distance and time
            destinationTag = 1
            
            startButton.setTitle("Stop", for: .normal)
            startButton.tag = 2
            //weatherAlert()
            startEbike()
            //let currentLocation = mapView.myLocation?.coordinate
            //let camera = GMSCameraPosition.camera(withTarget: currentLocation!, zoom: 15, bearing: 45, viewingAngle: 20)
            //self.mapView.animate(to: camera)
            
            
        
        }
        
        
        //sender.setImage(UIImage(named: "bike")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        latDirection = marker.position.latitude
        longDirection = marker.position.longitude
        print("wow")
        directionToDestButton.setImage(UIImage(named: "bike")?.withRenderingMode(.alwaysTemplate), for: .normal)
        directionToDestButton.isHidden = false
        
        
        return false
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.magneticHeading
        let heading2 = newHeading.trueHeading
        let heading2_2 = heading2*M_PI/180
        
    
        
        self.mapView.transform = CGAffineTransform(rotationAngle: CGFloat(heading2_2))
        let headingDegrees = (heading*M_PI/180)
        print(heading2)
        print(headingDegrees)
        let camera = GMSCameraPosition.camera(withTarget: (mapView.myLocation?.coordinate)!, zoom: 15, bearing: heading2, viewingAngle: 20)
        mapView.animate(to: camera)
        //mapView.animate(toBearing: headingDegrees)
        //let camera = GMSCameraPosition.camera(withTarget: (mapView.myLocation?.coordinate)!, zoom: 15, bearing: heading, viewingAngle: 45)
        //mapView.animate(toBearing: heading)
    }
    /*
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        latDirection = marker.position.latitude
        longDirection = marker.position.longitude
        print("Come in here ")
        directionToDestButton.isHidden = false
        
        
    }
    */
    
    func POIForCoffee() {
        guard let lat = mapView.myLocation?.coordinate.latitude else {return}
        guard let long = mapView.myLocation?.coordinate.longitude else {return}
        let coffee = "cafe"
        
        
        var arrayOfLocations = [[Double(),Double()]]
        var arrayOfNames = [String()]
        var arrayOfAddress = [String()]
        
        var name = String()
        
        var latitude = CLLocationDegrees()
        var longitude = CLLocationDegrees()
        
        
        /*
         let request = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.33165083%2C-122.03029752&radius=3200&type=cafe&key=AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA")! as URL,
                                            cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
         request.httpMethod = "GET"
         request.allHTTPHeaderFields = headers
         
         let session = URLSession.shared
         let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
         })
         
         dataTask.resume()
         */
        let jsonURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=3200&type=\(coffee)&key=AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA"
        
        guard let urlString = URL(string: jsonURLString) else {
            print("Error: Cannot create URL")
            return
        }
        
        let markerImage = UIImage(named: "dot")?.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: markerImage)
        markerView.tintColor = UIColor.DTIBlue()
        
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
                    
                    //print(json)
                    
                    DispatchQueue.global(qos: .background).async {
                    
                        let arrayPlaces = json["results"] as! NSArray
                        
                        for i in 0..<arrayPlaces.count {
                            
                            let arrayForLocations = (((arrayPlaces[i] as! NSDictionary).object(forKey: "geometry") as! NSDictionary).object(forKey: "location") as! NSDictionary)
                            
                            let arrayForName = (arrayPlaces[i] as! NSDictionary).object(forKey: "name") as! String
                            let arrayForAddress = (arrayPlaces[i] as! NSDictionary).object(forKey: "vicinity") as! String
                            
                            arrayOfNames.append(arrayForName)
                            arrayOfAddress.append(arrayForAddress)
                            
                            arrayOfLocations.append([arrayForLocations.object(forKey: "lat") as! Double, arrayForLocations.object(forKey: "lng") as! Double])
                            
                        }

                        DispatchQueue.main.async {
                            //print(arrayOfLocations)
                            //print(arrayOfNames)
                            for i in 1..<arrayOfLocations.count{
                                let nearbyMarker = GMSMarker()
                                    nearbyMarker.iconView = markerView
                                for j in 0..<arrayOfLocations[i].count {
                                    
                                    
                                    if j == 0 {
                                        latitude = arrayOfLocations[i][j]
                                    }
                                    if j == 1 {
                                        longitude = arrayOfLocations[i][j]
                                    }
                                    
                                    nearbyMarker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                }
                                
                                name = arrayOfNames[i]
                                nearbyMarker.title = name
                                nearbyMarker.snippet = arrayOfAddress[i]
                                nearbyMarker.map = self.mapView
                                
                            }
                            
                            
                        }
                    }
                    
                    
                    
                }catch let error as NSError {
                    print(error.debugDescription)
                }
                
                
                
            default:
                print("HTTP Reponse Code: \(httpResponse.statusCode)")
                
            }
            
        }
        task.resume()
        
        
    }
    
    
    lazy var myLocationButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = button.frame.width/2
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.DTIBlue()
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(UIImage(named: "myLocation")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(zoomToMyLocation), for: .touchUpInside)
        
        return button
    }()
    
    
    @objc fileprivate func zoomToMyLocation(sender: UIButton) {
        guard let lat = self.mapView.myLocation?.coordinate.latitude,
            let long = self.mapView.myLocation?.coordinate.longitude else { return }
        self.cameraTag = 0
    
        let camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D(latitude: lat, longitude: long), zoom: 15)
        self.mapView.animate(to: camera)
    }
    
    
    lazy var mySearchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = button.frame.width/2
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.DTIBlue()
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(named: "searchButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(searchAddressForDirection), for: .touchUpInside)
        
        return button
    }()
    
    

    
    // Auto SearchBar for the google places
    fileprivate let controller = GooglePlacesSearchController(
        apiKey: "AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA",
        placeType: PlaceType.address,
        radius: 1000
    )

    
    @objc fileprivate func searchAddressForDirection(sender: UIButton) {
        infoMarker.map = nil
        
        controller.didSelectGooglePlace{(place) -> Void in
            print(place.description)
            
            let position = place.coordinate
            self.infoMarker = GMSMarker(position: position)
            self.infoMarker.title = place.name
            self.infoMarker.snippet = place.formattedAddress
            self.infoMarker.map = self.mapView
            
            let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 10)
            self.mapView.animate(to: camera)
            
            self.drawRouteBetweenTwoPoints(coordinate: place.coordinate)
            
            
            self.controller.isActive = false
            
        }
        present(controller, animated: true, completion: nil)
    
    }
    
    func drawRouteBetweenTwoPoints(coordinate: CLLocationCoordinate2D) {
        
        
        
        
        guard let lat = mapView.myLocation?.coordinate.latitude else {return}
        guard let long = mapView.myLocation?.coordinate.longitude else {return}

        
        let aPointCoordinate = "\(lat),\(long)"
    
        let bPointCoordinate = "\(coordinate.latitude),\(coordinate.longitude)"
        
        let url = "http://maps.googleapis.com/maps/api/directions/json?origin=\(aPointCoordinate)&destination=\(bPointCoordinate)&sensor=false&mode=bicycling"
        
        guard let urlString = URL(string: url) else {
            print("Error: Cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: urlString)
        
        
        // Set up the session
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            do{
                
                if error != nil{
                    print("Error: \(error?.localizedDescription)")
                    
                } else {
                
                    guard let data = data else {
                        throw JSONError.NoData
                    }
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                        throw JSONError.ConversionFailed
                    }
                    
                    print(json)
                    
                    
                    let arrayRoutes = json["routes"] as! NSArray
                    let arrayLegs = (arrayRoutes[0] as! NSDictionary).object(forKey: "legs") as! NSArray
                    print(arrayLegs)
                    let arraySteps = arrayLegs[0] as! NSDictionary
                    
                    
                    let dicDistance = arraySteps["distance"] as! NSDictionary
                    let totalDistance = dicDistance["text"] as! String
                    self.totalremainingDistance = dicDistance["value"] as! Double

                    
                    let dicDuration = arraySteps["duration"] as! NSDictionary
                    let totalDuration = dicDuration["text"] as! String
                    self.totalremainingDuration = dicDuration["value"] as! Double


                    
                    
                    
                    print("\(totalDistance), \(totalDuration)")
                    
                    DispatchQueue.global(qos: .background).async {
                        let array = json["routes"] as! NSArray
                        let dic = array[0] as! NSDictionary
                        
                        //Getting overview bound of the path
                        /*
                        let overViewBoundOfNortheastLatitude = ((dic["bounds"] as! NSDictionary).object(forKey: "northeast") as! NSDictionary).object(forKey: "lat") as! Double
                        let overViewBoundOfNortheastLongitude = ((dic["bounds"] as! NSDictionary).object(forKey: "northeast") as! NSDictionary).object(forKey: "lng") as! Double
                        let overViewBoundOfSouthwestLatitude = ((dic["bounds"] as! NSDictionary).object(forKey: "southwest") as! NSDictionary).object(forKey: "lat") as! Double
                        let overViewBoundOfSouthwestLongitude = ((dic["bounds"] as! NSDictionary).object(forKey: "southwest") as! NSDictionary).object(forKey: "lng") as! Double
                        
                        let northeastBound = CLLocationCoordinate2DMake(overViewBoundOfNortheastLatitude, overViewBoundOfNortheastLongitude)
                        let southwestBound = CLLocationCoordinate2DMake(overViewBoundOfSouthwestLatitude, overViewBoundOfSouthwestLongitude)
                        
                        */
                        
                        let dic1 = dic["overview_polyline"] as! NSDictionary
                        let points = dic1["points"] as! String
                        print(points)
                        
                        DispatchQueue.main.async {
                            
                            self.totalDistanceToDestination.text = "Remaining Distance = \(totalDistance)"
                            self.totalDurationToDestination.text = "Remaining Duration = \(totalDuration)"
                            
                            let path = GMSPath(fromEncodedPath: points)
                            self.polyPath.map = nil
                            self.polyPath = GMSPolyline(path: path)
                            self.polyPath.strokeWidth = 4
                            self.polyPath.strokeColor = UIColor.darkGray
                            self.polyPath.map = self.mapView

                            
                        }
                        
                    
                        
                    }
                    
                }
            
            }catch let error as JSONError {
                print(error.rawValue)
            }catch let error as NSError {
                print(error.debugDescription)
            
            }
        
        
        })
        task.resume()
    
    }
    
    
    func featureViewController() {
        featureArray = [screenOne,screenTwo, screenThree, screenFour, screenFive]
        ScrollView.isPagingEnabled = true
        ScrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(featureArray.count), height: 400)
        statusViewControl.numberOfPages = featureArray.count
        ScrollView.showsHorizontalScrollIndicator = false
        ScrollView.delegate = self
    }
    

    

    func loadFeatures() {
    
        for (index,feature) in featureArray.enumerated() {

            if (index < 3) {
            
                // Main Frame of the each scroll view
                let mainFrameOfView = UIView()
                mainFrameOfView.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.ScrollView.frame.width, height: 400)
                mainFrameOfView.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
                    //UIColor(red:0.02, green:0.19, blue:0.38, alpha:1.00)
                mainFrameOfView.frame.size.width = self.view.bounds.size.width
                
                
                // First view frame of the main view (Left Side)
                let firstViewOfMain = UIView()
                firstViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                firstViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                firstViewOfMain.layer.borderColor = UIColor.DTIRed().cgColor
                firstViewOfMain.layer.borderWidth = 3
                firstViewOfMain.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                //(red:0.43, green:0.47, blue:0.69, alpha:1.00)
                
                
                // First main label of the first view
                let firstLabel = UILabel()
                firstLabel.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                firstLabel.backgroundColor = UIColor.clear
                firstLabel.font = UIFont.boldSystemFont(ofSize: 15)
                firstLabel.textColor = UIColor.white
                firstLabel.text = feature["description1"] as! String?
                firstLabel.textAlignment = .center
                
                
                
                
                // Second view frame of the main view (Right Side)
                let secondViewOfMain = UIView()
                secondViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                secondViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                secondViewOfMain.layer.borderColor = UIColor.DTIRed().cgColor
                secondViewOfMain.layer.borderWidth = 3
                secondViewOfMain.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                //UIColor(red:0.43, green:0.44, blue:0.89, alpha:1.00)
                
                // Second main label of the second view
                let secondLabel = UILabel()
                secondLabel.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                secondLabel.backgroundColor = UIColor.clear
                secondLabel.font = UIFont.boldSystemFont(ofSize: 15)
                secondLabel.textColor = UIColor.white
                secondLabel.text = feature["description2"] as! String?
                secondLabel.textAlignment = .center
                
                
                timeFromStart.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                timeFromStart.backgroundColor = UIColor.clear
                timeFromStart.font = UIFont.boldSystemFont(ofSize: 25)
                timeFromStart.textColor = UIColor.white
                //timeFromStart.text = "\(0):\(0):\(0)"
                
                timeFromStart.textAlignment = .center
                
                
                // Third view frame of the main view(Middle)
                
                let thirdViewOfMain = UIView()
                thirdViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                thirdViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                thirdViewOfMain.layer.borderColor = UIColor.DTIRed().cgColor
                thirdViewOfMain.layer.borderWidth = 3
                thirdViewOfMain.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                    //UIColor(red:0.99, green:0.73, blue:0.17, alpha:1.00)
                
                
                let thirdLabel = UILabel()
                thirdLabel.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                thirdLabel.backgroundColor = UIColor.clear
                thirdLabel.font = UIFont.boldSystemFont(ofSize: 15)
                thirdLabel.textColor = UIColor.white
                thirdLabel.text = feature["description3"] as! String?
                thirdLabel.textAlignment = .center
                
                
                
                thirdData.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                thirdData.backgroundColor = UIColor.clear
                thirdData.font = UIFont.boldSystemFont(ofSize: 25)
                thirdData.textColor = UIColor.white
                thirdData.textAlignment = .center
                
                thirdDataSecond.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                thirdDataSecond.backgroundColor = UIColor.clear
                thirdDataSecond.font = UIFont.boldSystemFont(ofSize: 25)
                thirdDataSecond.textColor = UIColor.white
                thirdDataSecond.textAlignment = .center
                
                
                thirdDataThird.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                thirdDataThird.backgroundColor = UIColor.clear
                thirdDataThird.font = UIFont.boldSystemFont(ofSize: 25)
                thirdDataThird.textColor = UIColor.white
                thirdDataThird.textAlignment = .center
                
                
                
                // Fourth view frame of the main view (bottom left)
                
                let fourthViewOfMain = UIView()
                fourthViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                fourthViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                fourthViewOfMain.layer.borderColor = UIColor.DTIRed().cgColor
                fourthViewOfMain.layer.borderWidth = 3
                fourthViewOfMain.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                //UIColor(red:0.66, green:0.46, blue:0.83, alpha:1.00)
                
                
                let fourthLabel = UILabel()
                fourthLabel.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                fourthLabel.backgroundColor = UIColor.clear
                fourthLabel.font = UIFont.boldSystemFont(ofSize: 15)
                fourthLabel.textColor = UIColor.white
                fourthLabel.text = feature["description4"] as! String?
                fourthLabel.textAlignment = .center
                
                
                
                // Fifth view frame of the main view (bottom right)
                
                let fifthViewOfMain = UIView()
                fifthViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                fifthViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                fifthViewOfMain.layer.borderColor = UIColor.DTIRed().cgColor
                fifthViewOfMain.layer.borderWidth = 3
                fifthViewOfMain.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                
                
                let fifthLabel = UILabel()
                fifthLabel.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                fifthLabel.backgroundColor = UIColor.clear
                fifthLabel.font = UIFont.boldSystemFont(ofSize: 15)
                fifthLabel.textColor = UIColor.white
                fifthLabel.text = feature["description5"] as! String?
                fifthLabel.textAlignment = .center
                
                
                
                distanceLabel.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                distanceLabel.backgroundColor = UIColor.clear
                distanceLabel.font = UIFont.boldSystemFont(ofSize: 25)
                distanceLabel.textColor = UIColor.white
                distanceLabel.textAlignment = .center
                
                
                
                ScrollView.addSubview(mainFrameOfView)
                
                
                ScrollView.addSubview(firstViewOfMain)
                ScrollView.addSubview(firstLabel)
                
                
                ScrollView.addSubview(secondViewOfMain)
                ScrollView.addSubview(secondLabel)
                
                
                
                ScrollView.addSubview(thirdViewOfMain)
                ScrollView.addSubview(thirdLabel)
                
                
                ScrollView.addSubview(fourthViewOfMain)
                ScrollView.addSubview(fourthLabel)
                
                ScrollView.addSubview(fifthViewOfMain)
                ScrollView.addSubview(fifthLabel)
                
                
                if (index == 0) {
                    
                    ScrollView.addSubview(timeFromStart)
                    ScrollView.addSubview(thirdData)
                    ScrollView.addSubview(distanceLabel)
                    
                    
                    // First element view constraints
                    _ = firstViewOfMain.anchor(mainFrameOfView.topAnchor, left: mainFrameOfView.leftAnchor, bottom: nil, right: mainFrameOfView.centerXAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = firstLabel.anchor(nil, left: nil, bottom: firstViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    //firstLabel.centerYAnchor.constraint(equalTo: firstViewOfMain.centerYAnchor).isActive = true
                    firstLabel.centerXAnchor.constraint(equalTo: firstViewOfMain.centerXAnchor).isActive = true
                    
                    
                    // Second element view constraints
                    _ = secondViewOfMain.anchor(mainFrameOfView.topAnchor, left: mainFrameOfView.centerXAnchor, bottom: nil, right: mainFrameOfView.rightAnchor, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = secondLabel.anchor(nil, left: nil, bottom: secondViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    secondLabel.centerXAnchor.constraint(equalTo: secondViewOfMain.centerXAnchor).isActive = true
                    
                    _ = timeFromStart.anchor(secondLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    timeFromStart.centerXAnchor.constraint(equalTo: secondViewOfMain.centerXAnchor).isActive = true
                    

                    // Third element view constraints
                    _ = thirdViewOfMain.anchor(secondViewOfMain.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width)-20, heightConstant: (mainFrameOfView.frame.height/3)-10)
                    thirdViewOfMain.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                    
                    _ = thirdLabel.anchor(nil, left: nil, bottom: thirdViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 150, heightConstant: 50)
                    thirdLabel.centerXAnchor.constraint(equalTo: thirdViewOfMain.centerXAnchor).isActive = true
                    
                    _ = thirdData.anchor(thirdLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 50)
                    thirdData.centerXAnchor.constraint(equalTo: thirdViewOfMain.centerXAnchor).isActive = true
                    
                    
                    // Fourth element view constraints
                    _ = fourthViewOfMain.anchor(thirdViewOfMain.bottomAnchor, left: mainFrameOfView.leftAnchor, bottom: nil, right: mainFrameOfView.centerXAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = fourthLabel.anchor(nil, left: nil, bottom: fourthViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    fourthLabel.centerXAnchor.constraint(equalTo: fourthViewOfMain.centerXAnchor).isActive = true
                    
                    
                    // Fifth element view constraints
                    _ = fifthViewOfMain.anchor(thirdViewOfMain.bottomAnchor, left: mainFrameOfView.centerXAnchor, bottom: nil, right: mainFrameOfView.rightAnchor, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = fifthLabel.anchor(nil, left: nil, bottom: fifthViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    fifthLabel.centerXAnchor.constraint(equalTo: fifthViewOfMain.centerXAnchor).isActive = true
                    
                    _ = distanceLabel.anchor(fifthLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    distanceLabel.centerXAnchor.constraint(equalTo: fifthViewOfMain.centerXAnchor).isActive = true
                    
                    
                } else if (index == 1) {
                    
                    ScrollView.addSubview(thirdDataSecond)
                    
                    // First element view constraints
                    _ = firstViewOfMain.anchor(mainFrameOfView.topAnchor, left: mainFrameOfView.leftAnchor, bottom: nil, right: mainFrameOfView.centerXAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = firstLabel.anchor(nil, left: nil, bottom: firstViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    //firstLabel.centerYAnchor.constraint(equalTo: firstViewOfMain.centerYAnchor).isActive = true
                    firstLabel.centerXAnchor.constraint(equalTo: firstViewOfMain.centerXAnchor).isActive = true
                    
                    
                    
                    // Second element view constraints
                    _ = secondViewOfMain.anchor(mainFrameOfView.topAnchor, left: mainFrameOfView.centerXAnchor, bottom: nil, right: mainFrameOfView.rightAnchor, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = secondLabel.anchor(nil, left: nil, bottom: secondViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    secondLabel.centerXAnchor.constraint(equalTo: secondViewOfMain.centerXAnchor).isActive = true
                    
                    
                    
                    // Third element view constraints
                    _ = thirdViewOfMain.anchor(secondViewOfMain.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width)-20, heightConstant: (mainFrameOfView.frame.height/3)-10)
                    thirdViewOfMain.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                    
                    _ = thirdLabel.anchor(nil, left: nil, bottom: thirdViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 150, heightConstant: 50)
                    thirdLabel.centerXAnchor.constraint(equalTo: thirdViewOfMain.centerXAnchor).isActive = true
                    
                    _ = thirdDataSecond.anchor(thirdLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 50)
                    thirdDataSecond.centerXAnchor.constraint(equalTo: thirdViewOfMain.centerXAnchor).isActive = true
                    
                
                    
                    // Fourth element view constraints
                    _ = fourthViewOfMain.anchor(thirdViewOfMain.bottomAnchor, left: mainFrameOfView.leftAnchor, bottom: nil, right: mainFrameOfView.centerXAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = fourthLabel.anchor(nil, left: nil, bottom: fourthViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    fourthLabel.centerXAnchor.constraint(equalTo: fourthViewOfMain.centerXAnchor).isActive = true
                    

                    
                    
                    // Fifth element view constraints
                    _ = fifthViewOfMain.anchor(thirdViewOfMain.bottomAnchor, left: mainFrameOfView.centerXAnchor, bottom: nil, right: mainFrameOfView.rightAnchor, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = fifthLabel.anchor(nil, left: nil, bottom: fifthViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    fifthLabel.centerXAnchor.constraint(equalTo: fifthViewOfMain.centerXAnchor).isActive = true
                    
                    
                    
                } else if (index == 2) {
                    
                    
                    
                    ScrollView.addSubview(thirdDataThird)
                    
                    // First element view constraints
                    _ = firstViewOfMain.anchor(mainFrameOfView.topAnchor, left: mainFrameOfView.leftAnchor, bottom: nil, right: mainFrameOfView.centerXAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = firstLabel.anchor(nil, left: nil, bottom: firstViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    //firstLabel.centerYAnchor.constraint(equalTo: firstViewOfMain.centerYAnchor).isActive = true
                    firstLabel.centerXAnchor.constraint(equalTo: firstViewOfMain.centerXAnchor).isActive = true
                    
                    
                    
                    // Second element view constraints
                    _ = secondViewOfMain.anchor(mainFrameOfView.topAnchor, left: mainFrameOfView.centerXAnchor, bottom: nil, right: mainFrameOfView.rightAnchor, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = secondLabel.anchor(nil, left: nil, bottom: secondViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    secondLabel.centerXAnchor.constraint(equalTo: secondViewOfMain.centerXAnchor).isActive = true
                    
                    
                    
                    
                    // Third element view constraints
                    _ = thirdViewOfMain.anchor(secondViewOfMain.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width)-20, heightConstant: (mainFrameOfView.frame.height/3)-10)
                    thirdViewOfMain.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                    
                    _ = thirdLabel.anchor(nil, left: nil, bottom: thirdViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 150, heightConstant: 50)
                    thirdLabel.centerXAnchor.constraint(equalTo: thirdViewOfMain.centerXAnchor).isActive = true
                    
                    _ = thirdDataThird.anchor(thirdLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 50)
                    thirdDataThird.centerXAnchor.constraint(equalTo: thirdViewOfMain.centerXAnchor).isActive = true
                    
                    // Center button in view
                    /*
                    NSLayoutConstraint.activate([
                        thirdLabel.topAnchor.constraint(equalTo: secondLabel.bottomAnchor),
                        
                        
                        ])
                    */
                    //
                    
                    // Fourth element view constraints
                    _ = fourthViewOfMain.anchor(thirdViewOfMain.bottomAnchor, left: mainFrameOfView.leftAnchor, bottom: nil, right: mainFrameOfView.centerXAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = fourthLabel.anchor(nil, left: nil, bottom: fourthViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    fourthLabel.centerXAnchor.constraint(equalTo: fourthViewOfMain.centerXAnchor).isActive = true
                    
                    
                    
                    
                    
                    // Fifth element view constraints
                    _ = fifthViewOfMain.anchor(thirdViewOfMain.bottomAnchor, left: mainFrameOfView.centerXAnchor, bottom: nil, right: mainFrameOfView.rightAnchor, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (mainFrameOfView.frame.width/2)-15, heightConstant: (mainFrameOfView.frame.height/3)-15)
                    
                    _ = fifthLabel.anchor(nil, left: nil, bottom: fifthViewOfMain.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    fifthLabel.centerXAnchor.constraint(equalTo: fifthViewOfMain.centerXAnchor).isActive = true
                    
                    
                }
            
            }
            
            else if (index == 3){
            
                let mainFrameOfView = UIView()
                mainFrameOfView.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.ScrollView.frame.width, height: 400)
                mainFrameOfView.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
                mainFrameOfView.frame.size.width = self.view.bounds.size.width
                
                
                
                
                ScrollView.addSubview(mainFrameOfView)
                ScrollView.addSubview(mapView)
                mapView.addSubview(myLocationButton)
                mapView.addSubview(mySearchButton)
                mapView.addSubview(coffeSearchButton)
                mapView.addSubview(directionToDestButton)
                
                directionToDestButton.isHidden = true
                
                
                _ = mapView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: mainFrameOfView.frame.width, heightConstant: mainFrameOfView.frame.height - 40)
                mapView.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                mapView.centerYAnchor.constraint(equalTo: mainFrameOfView.centerYAnchor).isActive = true
                
                _ = myLocationButton.anchor(nil, left: nil, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 10, widthConstant: 40, heightConstant: 40)
                
                _ = coffeSearchButton.anchor(mapView.topAnchor, left: nil, bottom: nil, right: mapView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 40, heightConstant: 40)
                
                _ = directionToDestButton.anchor(coffeSearchButton.bottomAnchor, left: nil, bottom: nil, right: mapView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 40, heightConstant: 40)
                
                _ = mySearchButton.anchor(mapView.topAnchor, left: mapView.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
                
            
            }
            else if (index == 4) {
            
                let mainFrameOfView = UIView()
                mainFrameOfView.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.ScrollView.frame.width, height: 400)
                mainFrameOfView.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
                mainFrameOfView.frame.size.width = self.view.bounds.size.width
                
                
                // Middle Circle to show the all the button to extend
                let middleFrameOfView = UIViewX()
                middleFrameOfView.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 340, height: 340)
                middleFrameOfView.cornerRadius = middleFrameOfView.frame.width/2
                middleFrameOfView.borderWidth = 3
                middleFrameOfView.borderColor = UIColor.DTIRed()
                middleFrameOfView.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                
                
                
                
                let speedButton = UIButton()
                speedButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                speedButton.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
                speedButton.layer.cornerRadius = speedButton.frame.width/2
                speedButton.layer.borderColor = UIColor.DTIRed().cgColor
                speedButton.layer.borderWidth = 3
                speedButton.isHighlighted = true
                speedButton.titleLabel?.textAlignment = .center
                speedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                speedButton.setTitle(labelArray[0], for: .normal)
                speedButton.tag = 0
                speedButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                
                let distanceButton = UIButton()
                distanceButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                distanceButton.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
                distanceButton.layer.cornerRadius = speedButton.frame.width/2
                distanceButton.layer.borderColor = UIColor.DTIRed().cgColor
                distanceButton.layer.borderWidth = 3
                distanceButton.isHighlighted = true
                distanceButton.titleLabel?.textAlignment = .center
                distanceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                distanceButton.setTitle(labelArray[2], for: .normal)
                distanceButton.tag = 2
                distanceButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                
                let timeButton = UIButton()
                timeButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                timeButton.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
                timeButton.layer.cornerRadius = speedButton.frame.width/2
                timeButton.layer.borderColor = UIColor.DTIRed().cgColor
                timeButton.layer.borderWidth = 3
                timeButton.isHighlighted = true
                timeButton.titleLabel?.textAlignment = .center
                timeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                timeButton.setTitle(labelArray[3], for: .normal)
                timeButton.tag = 3
                timeButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                
                let firstViewOfMain = UIView()
                firstViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 100)
                firstViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                firstViewOfMain.layer.borderColor = UIColor.white.cgColor
                firstViewOfMain.layer.borderWidth = 2
                firstViewOfMain.backgroundColor = UIColor.DTIBlue()
                
                
                ScrollView.addSubview(mainFrameOfView)
                mainFrameOfView.addSubview(middleFrameOfView)
                ScrollView.addSubview(speedButton)
                ScrollView.addSubview(distanceButton)
                ScrollView.addSubview(timeButton)
            
                
                _ = middleFrameOfView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: mainFrameOfView.frame.width-40, heightConstant: mainFrameOfView.frame.width-40)
                middleFrameOfView.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                middleFrameOfView.centerYAnchor.constraint(equalTo: mainFrameOfView.centerYAnchor).isActive = true
                
                
                _ = speedButton.anchor(middleFrameOfView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
                speedButton.centerXAnchor.constraint(equalTo: middleFrameOfView.centerXAnchor).isActive = true
                
                _ = distanceButton.anchor(nil, left: middleFrameOfView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
                distanceButton.centerYAnchor.constraint(equalTo: middleFrameOfView.centerYAnchor).isActive = true
                
                
                _ = timeButton.anchor(nil, left: nil, bottom: nil, right: middleFrameOfView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 80, heightConstant: 80)
                timeButton.centerYAnchor.constraint(equalTo: middleFrameOfView.centerYAnchor).isActive = true
            
            }
            

            
            
        }
    
    }
    

    
    lazy var closeButton: UIButtonY = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.cornerRadius = button.frame.width/2
        //button.setTitle("Cancel", for: .normal)
        button.setImage(UIImage(named: "cancelButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
        button.titleLabel?.textColor = UIColor.DTIRed()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissPopUp), for: .touchUpInside)
    
        return button
    }()
    
    
    let rideView: UIViewX = {
        let view = UIViewX(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = UIColor.black
        view.alpha = 0.6
        return view
    }()
    
    
    
    let infoView: UIViewX = {
        let view = UIViewX(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
        view.borderColor = UIColor.DTIRed()
        view.borderWidth = 1
        view.cornerRadius = 15
        return view
    
    }()
    
    
    let titleLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    let speedLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    let timeLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    let totalDistanceLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    let addressLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 1
        return label
    }()
    
    
    let totalDistanceToDestination: UILabel = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 1
        return label
    }()
    
    let totalDurationToDestination: UILabel = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 1
        return label
    }()
    
    
    
    let weatherIcon: UIButton = {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        
        //let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        //button.contentMode = .scaleAspectFit
        //button.backgroundColor = UIColor.clear
        //button.tintColor = UIColor.white
        //button.setImage(UIImage(named: "deleteButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        //button.addTarget(self, action: #selector(alertView), for: .touchUpInside)
        
        return button
    
    }()
    
    
    lazy var toolBox: UIToolbar = {
        let box = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        box.backgroundColor = UIColor.black
            //UIColor(red:0.21, green:0.27, blue:0.31, alpha:1.00)
        box.tintColor = UIColor.white
        box.barStyle = .blackTranslucent
        
        let historyButton = UIBarButtonItem(title: "History", style: .plain, target: self, action: #selector(moveToHistory))
        historyButton.tag = 1
        box.setItems([historyButton], animated: true)
        box.isMultipleTouchEnabled = true
    
        return box
    }()
    
    func moveToHistory() {
        performSegue(withIdentifier: .history, sender: nil)
    }
    
    func dismissPopUp(){
        rideView.removeFromSuperview()
        infoView.removeFromSuperview()
    }
    

    
    
    func moveToPopUp(sender: UIButton) {
        

        view.addSubview(rideView)
        view.addSubview(infoView)
        infoView.addSubview(closeButton)
        infoView.addSubview(titleLabel)
        
        _ = rideView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: view.frame.height)
        rideView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rideView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
        
        _ = infoView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 350)
        infoView.centerXAnchor.constraint(equalTo: rideView.centerXAnchor).isActive = true
        infoView.centerYAnchor.constraint(equalTo: rideView.centerYAnchor).isActive = true
        
        
        _ = titleLabel.anchor(nil, left: nil, bottom: infoView.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: 200, heightConstant: 50)
        titleLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        
        
        _ = closeButton.anchor(nil, left: nil, bottom: infoView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        closeButton.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        
        
        if sender.tag == 0 {
            timeLabel.removeFromSuperview()
            totalDistanceLabel.removeFromSuperview()
            infoView.addSubview(speedLabel)
            
            _ = speedLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            speedLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            speedLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
            
        }
        
        if sender.tag == 2{
            timeLabel.removeFromSuperview()
            speedLabel.removeFromSuperview()
            
            infoView.addSubview(totalDistanceLabel)
            
            _ = totalDistanceLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            totalDistanceLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            totalDistanceLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
        
        }
        
        if sender.tag == 3 {
            speedLabel.removeFromSuperview()
            totalDistanceLabel.removeFromSuperview()

            infoView.addSubview(timeLabel)
            
            _ = timeLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            timeLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            timeLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
            
        }
        
        for (index, label) in labelArray.enumerated() {
            if (index == sender.tag) {
                titleLabel.text = label

            }

        }
        
    }
    

    
    // Once the user allowed us to track then we let the system to start updating the the current location and track it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .restricted:
            
            print("Location access was restricted.")
            
        case .denied:
            
            print("User denied access to locaiton.")
            
        case .notDetermined:
            
            print("Location status not determined.")
            
        case .authorizedAlways:
            
            guard CLLocationManager.headingAvailable() else {
                print("Heading is not available right now")
                return }
            locationManager.headingFilter = 5
            locationManager.startUpdatingHeading()
            
        case .authorizedWhenInUse:
            mapView.isMyLocationEnabled = true
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoMarker.map = nil
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        if (gesture) {
            cameraTag = 1
            print(gesture)
        }
    }
    
    // This function is called whenever current location is changed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
            if startLocation == nil {
                startLocation = locations.first
                path.add(startLocation.coordinate)
                locationListWithDistance[0] = [startLocation,0]
                
            } else if let location = locations.last {
                totalTravelDistance += lastLocation.distance(from: location)
                
                // Since we search for the place and set the destination we should start tracking
                if destinationTag == 1 {
                    
                    
                    // FIXIT - I need to fix the Alert View
                    if (totalremainingDistance/1000)*1.61 < 0.05{
                        totalDistanceToDestination.text = "Remaining Distance = \(0.0)mi"
                        destinationTag = 0
                        
                        let destinationAlertView = UIAlertController(title: "Destination!", message: "We are here :)", preferredStyle: .alert)
                        
                        let cancel = UIAlertAction(title: "Alright", style: .default)
                        
                        destinationAlertView.addAction(cancel)
                        
                        present(destinationAlertView, animated: true, completion: nil)
                        
                    } else if (totalremainingDistance/1000)*1.61 > 0.05 {
                    
                        totalremainingDistance -= lastLocation.distance(from: location)
                        totalDistanceToDestination.text = "Remaining Distance = \(String(format: "%.2f",(totalremainingDistance/1000)*1.61))mi"
                    }
                }
                
                locationListWithDistance.append([lastLocation,totalTravelDistance])
                
                print("Traveled Distance:",  totalTravelDistance)
                print("Straight Distance:", startLocation.distance(from: locations.last!))
                print("Elevation:", location.altitude)
                
                let msTomph = ((location.speed as Double)*(1/1000)*(1/1.61)*(3600)).rounded()
                
                if msTomph > 20.0 && speedTag == 0{
                    let alertController = UIAlertController(title: "Warning!", message: "You might want to slow down for your safety", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                    
                    alertController.addAction(cancelAction)
                    alertController.view.tintColor = UIColor.DTIRed()
                    alertController.view.backgroundColor = UIColor.black
                    alertController.view.layer.cornerRadius = 25
                    speedTag = 1
                    
                    present(alertController, animated: true, completion: nil)
                }
                
                if msTomph < 20.0 {
                    speedTag = 0
                }
                
                speedLabel.text = "\(msTomph)/mph"
                thirdData.text = "\(msTomph)/mph"
                thirdDataSecond.text = "\(msTomph)/mph"
                thirdDataThird.text = "\(msTomph)/mph"
                
                
                
                trackingMovingTime(speed: location.speed as Double!)
                
                path.add((locations.last?.coordinate)!)
                
                
                distance = Measurement(value: totalTravelDistance, unit: UnitLength.meters)
                
                let camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 30, viewingAngle: 20)
                
                if cameraTag == 0{
                    mapView.animate(to: camera)
                    reverseGeocodeCoordinate(coordinate: location.coordinate)
                }
            }
        
            lastLocation = locations.last
            locationList.append(lastLocation)
        
            if locationList.count == 1 {
                getWeatherInfo()
            }
        
            drawPath(path: path)
        
    }
    
    
    // draw black line on the map that shows how current object moving
    func drawPath(path: GMSPath) {
    
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.geodesic = true
        polyline.strokeColor = UIColor(red:0.14, green:0.17, blue:0.17, alpha:1.00)
        polyline.map = self.mapView
    }
    
    
    // Get the human readable address
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate){(placemark, error) in
            
            if (error != nil && placemark == nil){
                print("Error occurred = \(error)")
            }
                
            else {
                if (error == nil && placemark != nil) {
                    
                    if let place = placemark?.firstResult() {
                        
                        if place.thoroughfare != nil {
                            self.addressLabel.text = " \(place.lines![0]) \n \(place.lines![1])"
                            
                            if place.locality == nil {
                                self.address.append("\(place.country)")
                            
                            } else if place.locality != nil {
                                self.address.append("\(place.locality!)")
                            }
                            
                        } else {
                            print("There is no thorughfare!")
                        }
                    }
                }
                else if (error == nil && placemark?.results()?.count == 0 || placemark == nil){
                    NSLog("No results were returned.")
                    self.addressLabel.text = "The place is not registered!"
                    
                }
            }
        }
    }
    
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        
        
        placesClient.lookUpPlaceID(placeID, callback:{ (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            
            guard let place = place else {return}
            guard let placeName = place.formattedAddress else {return}
            
            self.infoMarker.snippet = "\(placeName)"
            
        
        })
        
        
        
        
        //infoMarker.snippet = "\(location.latitude), \(location.longitude)"
        infoMarker.layer.cornerRadius = 25
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 1
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        infoMarker.appearAnimation = GMSMarkerAnimation.pop
        infoMarker.isTappable = true
        mapView.selectedMarker = infoMarker
        
        //locationManager.stopUpdatingLocation()
        //let camera = GMSCameraPosition(target: location, zoom: 15, bearing: 0, viewingAngle: 0)
        //mapView.animate(to: camera)
    }
    
    
    func drawCircle(position: CLLocationCoordinate2D){
    
        
        let circle = GMSCircle(position: position, radius: 100)
        circle.strokeColor = UIColor.DTIBlue()
        circle.fillColor = UIColor.cyan
        circle.map = self.mapView
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        statusViewControl.currentPage = Int(page)
    }
    


    // MARK - Specific Info View while riding on the bike

    
    lazy var startButton: UIButtonY = {
    
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("Start", for: .normal)
        button.cornerRadius = button.frame.width/2
        button.borderWidth = 2
        button.borderColor = UIColor.white
        button.tintColor = UIColor.white
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.shadowColor = UIColor.DTIRed()
        button.shadowOffset = CGSize(width: 1, height: -1)
        button.tag = 1
        
        button.addTarget(self, action: #selector(pauseTheRoute), for: .touchUpInside)
        
        return button
    }()
    
    
    func pauseTheRoute(sender: UIButtonY) {
        
        
        if (sender.tag == 1) {
            
            sender.setTitle("Stop", for: .normal)
            sender.tag = 2
            //weatherAlert()
            startEbike()
            
        
        } else if (sender.tag == 2){
            
            alertView(sender: sender)
            
        
        }
        
    }
    
    fileprivate func setWeatherIcon() {
        if let icon = currentWeatherIcon {
            switch icon as String {
            case CurrentWeatherStatus.rain.rawValue:
                weatherIcon.setImage(UIImage(named: "rain")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "rain"
            case CurrentWeatherStatus.clearDay.rawValue:
                weatherIcon.setImage(UIImage(named: "clear")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "clear"
            case CurrentWeatherStatus.clearNight.rawValue:
                weatherIcon.setImage(UIImage(named: "clear")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "clear"
            case CurrentWeatherStatus.someCloudDay.rawValue:
                weatherIcon.setImage(UIImage(named: "cloudy")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "cloudy"
            case CurrentWeatherStatus.someCouldNight.rawValue:
                weatherIcon.setImage(UIImage(named: "cloudy")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "cloudy"
            case CurrentWeatherStatus.sleet.rawValue:
                weatherIcon.setImage(UIImage(named: "sleet")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "sleet"
            case CurrentWeatherStatus.cloudy.rawValue:
                weatherIcon.setImage(UIImage(named: "cloudy")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "cloudy"
            case CurrentWeatherStatus.snow.rawValue:
                weatherIcon.setImage(UIImage(named: "snow")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "snow"
            case CurrentWeatherStatus.wind.rawValue:
                weatherIcon.setImage(UIImage(named: "wind")?.withRenderingMode(.alwaysTemplate), for: .normal)
                iconString = "wind"
            default:
                break
            }
            
        } else {
            print("There is no weather icon")
        }
        weatherIcon.isHidden = false
        
    }
    

    
    fileprivate func weatherAlert() {
        
        
        //setWeatherIcon()
        if let temp = currentTemperature {
            if let summary = currentWeatherSummary {
                let alertController = UIAlertController(title: "Weather", message: "Temperature: \(temp)F° \n Condition: \(summary)", preferredStyle: .alert)
                
                let titleFont: [String:AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
                let messageFont: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
                
                
                let attributedTitle = NSMutableAttributedString(string: "Weather", attributes: titleFont)
                let attributedMessage = NSMutableAttributedString(string: "Temperature: \(temp)F° \n Condition: \(summary)", attributes: messageFont)
                
                alertController.setValue(attributedTitle, forKey: "attributedTitle")
                alertController.setValue(attributedMessage, forKey: "attributedMessage")
                
                guard let icon = iconString else {return}
                
                let image = UIImage(named: icon)
                //imageView.image = image
                
                //imageView.center
                
                

                switch icon {
                case "clear":
                    let action = UIAlertAction(title: "Let's get go wild!", style: .default, handler: nil)
                    action.setValue(image, forKey: "image")
                    alertController.addAction(action)
                case "cloudy":
                    let action = UIAlertAction(title: "Nice weather to ride but becareful", style: .default, handler: nil)
                    action.setValue(image, forKey: "image")
                    alertController.addAction(action)
                case "rain":
                    let action = UIAlertAction(title: "Let's take next round :/", style: .default, handler: nil)
                    action.setValue(image, forKey: "image")
                case "snow":
                    let action = UIAlertAction(title: "Not today... :/", style: .default, handler: nil)
                    action.setValue(image, forKey: "image")
                    alertController.addAction(action)
                case "sun":
                    let action = UIAlertAction(title: "Don't forget a sunblock!! :P", style: .default, handler: nil)
                    action.setValue(image, forKey: "image")
                    alertController.addAction(action)
                    
                case "wind":
                    let action = UIAlertAction(title: "Windy, becareful!", style: .default, handler: nil)
                    action.setValue(image, forKey: "image")
                    alertController.addAction(action)
                default:
                    break
                }
                

            
                
                let cancelButton = UIAlertAction(title: "Got it!", style: .cancel)
                
                alertController.view.tintColor = UIColor.DTIBlue()
                alertController.view.layer.cornerRadius = 25
                alertController.view.backgroundColor = UIColor.darkGray
                
                
                alertController.addAction(cancelButton)
                present(alertController, animated: true, completion: nil)
            }
        } else {
        
            let alertController = UIAlertController(title: "Weather is not available", message: "-° \n -", preferredStyle: .alert)
            
            let cancelButton = UIAlertAction(title: "Got it!", style: .cancel)

            alertController.addAction(cancelButton)
            present(alertController, animated: true, completion: nil)
        
        }
    }

    

    
    fileprivate func startEbike() {
        
        locationManager.startUpdatingLocation()
        
        mySearchButton.isHidden = true
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        
        seconds = 0
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ _ in
            self.seconds += 1
            let formattedDistance = FormatDisplay.distance(self.distance)
            let formattedTime = FormatDisplay.time(self.seconds)
            
            self.timeFromStart.text = "\(formattedTime)"
            self.timeLabel.text = "\(formattedTime)"
            self.distanceLabel.text = "\(formattedDistance)"
            self.totalDistanceLabel.text = "\(formattedDistance)"
        }
    
    }

    
    fileprivate func trackingMovingTime(speed: Double) {
        totalMovingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ _ in
            
            if speed < 0 {
                self.movingSeconds += 0
            }
            else if speed > 0 {
                self.movingSeconds += 1
            }
            else {
                //self.movingSeconds += 1
            }
        }
    }
    
    fileprivate func alertView(sender: UIButtonY) {
        let alertController = UIAlertController(title: "End Ride?", message: "Do you want to end your ride?", preferredStyle: .alert)
        let titleFont: [String:AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        let messageFont: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        
        let attributedTitle = NSMutableAttributedString(string: "End Ride?", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "Do you want to save your ride?", attributes: messageFont)
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let saveButton = UIAlertAction(title: "Save The Route", style: .default) {
            _ in
            sender.setTitle("Start", for: .normal)
            sender.tag = 1
            self.saveNameOfRoute()
        }
        
        let cancelButton = UIAlertAction(title: "Resume", style: .cancel)
        
        
        alertController.view.tintColor = UIColor.DTIBlue()
        alertController.view.layer.cornerRadius = 25
        alertController.view.backgroundColor = UIColor.darkGray
        
        
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
        
    
    }
    
    fileprivate func saveNameOfRoute() {
        
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: .alert)
        
        let saveNameAction = UIAlertAction(title: "Save", style: .default) {
            _ in
            
            let nameTextField = alertController.textFields![0] as UITextField
            self.stopEbike()
            self.saveEbike(name: nameTextField.text!)
            self.performSegue(withIdentifier: .stopAndSave, sender: nil)
        }
        
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = "Enter The Name"
        }
        
        alertController.addAction(saveNameAction)
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    
    fileprivate func stopEbike() {
        mySearchButton.isHidden = false
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        
        
    }

    
    fileprivate func saveEbike(name: String) {
        
        
        let newRide = Ride(context: CoreDataStack.context)
        newRide.distance = distance.value
        newRide.duration = Int16(seconds)
        newRide.timestamp = Date() as NSDate?
        newRide.name = name
        //newRide.movingduration = Int16(movingSeconds)
        
        
        for i in 0..<address.count{
            
            if (i == address.count/2) {
                newRide.address = address[i]
            }
        }
        
        for location in locationList {
            let locationObject = Locations(context: CoreDataStack.context)
            locationObject.elevation = location.altitude as Double
            print(location.altitude)
            locationObject.timestamp = location.timestamp as NSDate?
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRide.addToLocations(locationObject)
        }
        /*
        for i in 0..<locationListWithDistance.count{
            
            let locationObj = Locations(context: CoreDataStack.context)
            for j in 0..<locationListWithDistance[i].count{
                if j == 0 {
                    var locObj = CLLocation()
                    locObj = locationListWithDistance[i][0] as! CLLocation
                    locationObj.elevation = locObj.altitude
                    locationObj.latitude = locObj.coordinate.latitude
                    locationObj.longitude = locObj.coordinate.longitude
                    locationObj.timestamp = locObj.timestamp as NSDate?
                    
                }
                if j == 1 {
                    var locObjDistance = Double()
                    locObjDistance = locationListWithDistance[i][1] as! Double
                    locationObj.distanceFromStart = locObjDistance
                }
                newRide.addToLocations(locationObj)
            }
        }
        */
        CoreDataStack.saveContext()
        ride = newRide
        
    }
    
    
    func moveBack() {
        performSegue(withIdentifier: "menuViewSegue", sender: self)
    }
    
    
    
    // Map Styling
    
    func mapStyle() {
    
        do {
            //Set the map style by passing a valid JSON String.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
                print("Unavle to find the style.json")
            }
            
        } catch {
            
            print("One or more of the map style failed to load. \(error)")
        }
    }
    

    
    
    func getWeatherInfo() {
    
        
        let currentLocationLat: Double?
        let currentLocationLong: Double?
        let forecastService = ForecastService(APIKey: forecastAPIKey)
        //let currentTemperature: Double?
        //var weatherStatus: String?
        
        if let currentLocation = locationList.first {
            
            currentLocationLat = currentLocation.coordinate.latitude
            currentLocationLong = currentLocation.coordinate.longitude
            
            forecastService.getForecast(lat: currentLocationLat!, long: currentLocationLong!) { (currentWeather) in
                
                if let currentWeather = currentWeather {
                    DispatchQueue.main.async {
                        if let temperature = currentWeather.temperature {
                            self.currentTemperature = temperature
                            
                            if let summary = currentWeather.summary {
                                self.currentWeatherSummary = summary
                                
                            }
                            if let icon = currentWeather.weatherStatus{
                                self.currentWeatherIcon = icon
                                self.setWeatherIcon()
                                self.weatherAlert()
                            }
                        }
                    }
                } else {
                
                    self.currentTemperature = 0
                
                }
            }
        } else {
            print("There is no location that is saved!")
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionShowPowerAlertKey: true
            ])
        
        userCurrentLocationMarker.map = mapView
        /*
        
        let authenticaitonContext = LAContext()
        
        var error: NSError?
        if authenticaitonContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
        
            authenticaitonContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verification"){
             (success, error) in
                if success {
                
                    print("User has authenticated!")
                } else {
                    if let err = error {
                        print(err)
                    } else {
                        print("did not authenticated")
                    }
                
                }
            
            
            }
        } else {
        
            print("Device does not have touch id!")
        }
        */
        //locationManager.startUpdatingLocation()

        //locationManager.startUpdatingHeading()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        mapView.delegate = self
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(mainTitle)
        view.addSubview(ScrollView)
        view.addSubview(statusViewControl)
        view.addSubview(addressLabel)
        view.addSubview(totalDistanceToDestination)
        view.addSubview(totalDurationToDestination)
        
        view.addSubview(startButton)
        view.addSubview(weatherIcon)
        weatherIcon.isHidden = true
        view.addSubview(toolBox)
        
        mapStyle()
        featureViewController()
        loadFeatures()
        
        
        _ = mainTitle.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 30)
        mainTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = weatherIcon.anchor(view.topAnchor, left: mainTitle.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 30, heightConstant: 30)
        
        _ = ScrollView.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 60, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 400)
        ScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = statusViewControl.anchor(ScrollView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 20)
        statusViewControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = addressLabel.anchor(statusViewControl.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 30)
        
        _ = totalDistanceToDestination.anchor(addressLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: totalDurationToDestination.leftAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width/2-20, heightConstant: 30)
        
        _ = totalDurationToDestination.anchor(addressLabel.bottomAnchor, left: totalDistanceToDestination.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width/2-20, heightConstant: 30)
        
        _ = startButton.anchor(totalDistanceToDestination.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = toolBox.anchor(startButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 40)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
    }

}


extension RiderStatusViewController: CBCentralManagerDelegate, CBPeripheralDelegate{
    

    
    
    
    /*!
     *  @method centralManagerDidUpdateState:
     *
     *  @param central  The central manager whose state has changed.
     *
     *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
     *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
     *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
     *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
     *                  manager become invalid and must be retrieved or discovered again.
     *
     *  @see            state
     *
     */
    @available(iOS 5.0, *)
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var showAlert = true
        var message = String()
        
        switch central.state {
        case .poweredOn:
            
            showAlert = false
            keepScanning = true
            
            
            message = "Bluetooth LE is turned on and ready for communication."
            print(message)
            
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            
            
            
            // Initiate Scan for Peripherals
            //Option 1: Scan for all devices
            self.centralManager.scanForPeripherals(withServices: ServiceUUID.uuids(enumNames: [.HeartRate]), options: nil)
            
            //let AdvertisingUUID = CBUUID(string:)
            
            
            // Option 2: Scan for devices that have the service you're interested in...
            //let sensorTagAdvertisingUUID = CBUUID(string: Device.SensorTagAdvertisingUUID)
            //print("Scanning for SensorTag adverstising with UUID: \(sensorTagAdvertisingUUID)")
            //centralManager.scanForPeripheralsWithServices([sensorTagAdvertisingUUID], options: nil)
            
        case .poweredOff:
            message = "Bluetooth on this is currently powered off."
        
        case .unsupported:
            message = "This device does not support Bluetooth Low Energy."
            
        case .unauthorized:
            message = "This app is not authorized to use Bluetooth Low Energy."
        
        case .resetting:
            message = "The BLE Manager is resetting; a state update is pending."
            
        case .unknown:
            message = "The state of the BLE Manager is unknown."
        }
        
        
        if showAlert {
            let alertViewController = UIAlertController(title: "Central Manger State", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sure", style: .cancel)
            alertViewController.addAction(okAction)
            present(alertViewController, animated: true, completion: nil)
        }

    }
    
    
    // MARK: - Bluetooth scanning
    
    func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        print("*** PAUSING SCAN...")
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        self.centralManager.stopScan()
        //disconnectButton.enabled = true
    }
    
    func resumeScan() {
        if keepScanning {
            // Start scanning again...
            print("*** RESUMING SCAN!")
            //disconnectButton.enabled = false
            //temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeMessage)
            //temperatureLabel.text = "Searching"
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            self.centralManager.scanForPeripherals(withServices: ServiceUUID.uuids(enumNames: [.HeartRate]), options: nil)
        } else {
            print("You have found device and connected and there will be a button to disconnect bluetooth but it is recommended for your ebike efficiency")
            //disconnectButton.enabled = true
        }
    }
    
    

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        print("Central Manger didDiscoverPeripheral: \(peripheral), \(advertisementData), \(RSSI)")
        
        if let name = peripheral.name {
            if hrSensorName != nil && name != self.hrSensorName{
                return
            }
            
            hrSensorName = name
            
        
        }
        //To be safe we need to use guard let
        
        if let advertisedServiceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]{
            
            print("Servcies \(advertisedServiceUUIDs)")
        }
        
        let deviceName = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        print("NEXT Peripheral name: \(deviceName)")
        print("Next peripheral uuid: \(peripheral.identifier.uuidString)")
        
        
        
        if deviceName?.contains(WahooHeartMonitorSensor) == true {
            print("We found device and connecting now!!")
            // Stop scanning
            keepScanning = false
            //self.centralManager.stopScan()
            
            // Save a refence to the sensor tag
            self.deviceConnectTo = peripheral
            // set the delegate property to point to the view controller
            self.deviceConnectTo?.delegate = self
            
            // Request a conncetion to the peripheral
            centralManager.connect(self.deviceConnectTo!, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Seccessfully connected to the device")
        
        
        // -NOTE: we pass nil to request ALL services be discovered.
        // If there was a subset of services we were interested in, we could pass the UUIDs here.
        // Doing so saves battery life and saves time.
        
        peripheral.discoverServices(ServiceUUID.uuids(enumNames: [.HeartRate, .DeviceInformation]))
    }

    // When bluetooth connection is failed!!
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("CONNECTION to heart rate monitor failed!", error.debugDescription)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Core Bluetooth creates an array of CBService objects
        // one for each service that is discovered on the peripheral
        
        //A026E01D-0A7D-4AB3-97FAF1500F9FEB8B
        
        if let services = peripheral.services {
            
            for service in services {
            
                switch service.uuid {
                case ServiceUUID.uuid(enumName: .HeartRate):
                    print("Discovered heart rate service!")
                    peripheral.discoverCharacteristics(HeartRateCharacteristicUUID.uuids(enumNames: [.HeartRateMeasurement, .BodySensorLocation]), for: service)
                case ServiceUUID.uuid(enumName: .DeviceInformation):
                    print("Discovered device information service!")
                    
                default:
                    print("unrecognized service: \(service.uuid)")
                }
            
            }
            
            /*
            for service in services{
            
                if service.uuid == CBUUID(string: Device.totalServiceUUID){
                    print("We found the specific service we want and now let's find characteristics")
                    peripheral.discoverCharacteristics(nil, for: service)
                
                }
            }
             */
        
        }

    }
    
    
    
    /*
     Invoked when you discover the characteristics of a specified service.
     
     If the characteristics of the specified service are successfully discovered, you can access
     them through the service's characteristics property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            print("Error Discovering Characteristics: \(error?.localizedDescription)")
            return
        
        }
        else {
            guard let characteristics = service.characteristics else { return }
            var enableValue:UInt8 = 1
            let enableBytes = NSData(bytes: &enableValue, length: MemoryLayout<UInt8>.size)
            
            for characteristic in characteristics {
            
                if characteristic.uuid == HeartRateCharacteristicUUID.uuid(enumName: .HeartRateMeasurement){
                
                    
                    if characteristic.properties.contains(.notify){
                        self.deviceConnectTo?.setNotifyValue(true, for: characteristic)
                    
                    } else {
                        print("HR sensor non-compliant with spec. HR measurement not NOTIFY capable")
                    }
                    
                    //self.heartRateMonitorCharacteristic = characteristic
                    //self.deviceConnectTo?.setNotifyValue(true, for: characteristic)
                } else {
                    if characteristic.properties.contains(.read){
                    
                        peripheral.readValue(for: characteristic)
                    }
                
                }
                
            }
            
        
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("Error on updating value for the characteristics: \(error?.localizedDescription)" )
            return
        }
        
        
        guard let dataBytes = characteristic.value else {
            
            print("no value")
            return
        }
        
        print("hear rate measurement value is \(dataBytes)")
        renderHeartRateMeasurement(value: dataBytes as NSData)
        
        if characteristic.uuid == CBUUID(string: Device.characteristicUUID){
            displayHeartRate(data: dataBytes as NSData)
        }
        
    }
    
    
    func renderHeartRateMeasurement(value: NSData){
    
        
    
    }
    
    func displayHeartRate(data: NSData) {
    
        let dataLength = data.length / MemoryLayout<UInt16>.size
    
        var dataArray = [UInt16](repeating: 0, count: dataLength)
        data.getBytes(&dataArray, length: dataLength * MemoryLayout<UInt16>.size)
        
        
        //Output values for debugging/diagnostic purpose
        for i in 0..<dataLength {
        
            let nextInt:UInt16 = dataArray[i]
            print("Next Int: \(nextInt)")
        }
        
        
        
    }
    

}


extension RiderStatusViewController{

    
    func RadiansToDegrees(radians: Double) -> Double {
        return (radians * 190.0/M_PI)
    }
    
    func DegreesToRadians(degrees: Double) -> Double {
    
        return (degrees * M_PI/180.0)
    }
    
    
    /*
    func imageRotatedByDegrees(degrees: CGFloat, image: UIImage) -> UIImage {
    
        var size = image.size
        
        
        UIGraphicsBeginImageContext(size)
        var context = UIGraphicsGetCurrentContext()
        
        //CGAffineTransform(
        
    }
     */
    
    func setLatLongForBearingAngle(userLocation: CLLocation) -> Double {
        let latForCurrentUserLocation = DegreesToRadians(degrees: (mapView.myLocation?.coordinate.latitude)!)
        let longForCurrentUserLocation = DegreesToRadians(degrees: (mapView.myLocation?.coordinate.longitude)!)
        
        let latForHeading = DegreesToRadians(degrees: 37.7833)
        let longForHeading = DegreesToRadians(degrees: -122.4167)
        
        let dLong = longForHeading - longForCurrentUserLocation
        
        let y = sin(dLong) * cos(latForHeading)
        let x = cos(latForCurrentUserLocation) * sin(latForHeading) - sin(latForCurrentUserLocation) * cos(latForHeading) * cos(dLong)
        
        var radianBearing = atan2(y, x)
        
        if (radianBearing < 0.0) {
            radianBearing += 2*M_PI
        }
        
        return radianBearing
    }
    
}



extension RiderStatusViewController {
    enum CurrentWeatherStatus: String {
        case rain = "rain"
        case clearDay = "clear-day"
        case clearNight = "clear-night"
        case snow = "snow"
        case sleet = "sleet"
        case wind = "wind"
        case fog = "fog"
        case cloudy = "cloudy"
        case someCloudDay = "partly-cloudy-day"
        case someCouldNight = "partly-cloudy-night"
        case hail = "hail"
        case thunderstorm = "thunderstorm"
        case tornado = "tornado"
    }
}

extension RiderStatusViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case stopAndSave = "saveViewSegue"
        case history = "historyViewSegue"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .stopAndSave:
            let destination = segue.destination as! EbikeDetailsViewController
            destination.ride = ride
            
        case .history:
            _ = segue.destination as! UINavigationController
        }
    }
}

