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
import CoreMotion
import MapKit
import LocalAuthentication
import CoreBluetooth
import FirebaseAuth



class RiderStatusViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, MKMapViewDelegate{
    
    // Access to the window size
    let windowSize = UIApplication.shared.keyWindow
    
    // Access to User Defaults 
    let userDefault = UserDefaults.standard
    
    // Kalma Filter Algorithm
    var resetKalmanFilter: Bool = true
    var hcKalmanFilter: HCKalmanAlgorithm?
    
    
    // JSON format for the get direction between two points
    
    
    enum JSONError: String, Error {
        case NoData = "Error: No Data"
        case ConversionFailed = "Error: Conversion from JSON failed"
    }
    
    
    
    // MARK: - Location Tracking Accuracy Variables Declaration
    /******************************************************************************************************/
    
    var userAnnotationImage: UIImage?
    var accuracyRangeCircle: GMSCircle?
    var isZooming: Bool?
    var isBlockingAutoZoom: Bool?
    var zoomBlockingTimer: Timer?
    var didInitialZoom: Bool?
    
    /******************************************************************************************************/
    
    
    
    
    /******************************************************************************************************/
    
    // MARK: - Bluetooth Delegate
    
    var centralManager: CBCentralManager!
    var deviceConnectTo: CBPeripheral?
    
    // Bluetooth status
    var keepScanning = false
    
    // define our scanning interval times
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0
    
    //Temporary UUID or name
    // FIXIT - We need to find the right devices to integrate with
    let WahooHeartMonitorSensor = "TICKR B20E"
    var hrSensorName: String?
    
    
    let BEAN_SCRATCH_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    
    
    // Core Bluetooth properties
    
    var heartRateMonitorCharacteristic: CBCharacteristic?
    
    
    
    // Store Heart Rate Data
    var cumulativeSumOfHeartRateData = 0
    fileprivate var heartRateList: [Int] = []
    fileprivate var currentHeartRate = 0
    var heartRateTag = 0
    
    /******************************************************************************************************/
    
    
    
    // Changing the current location dot with our own icon or something!
    lazy var userCurrentLocationMarker: GMSMarker = {
        let marker = GMSMarker()
        
        let markerImage = UIImage(named: "headingDirection")
            //?.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: markerImage)
        
        marker.tracksViewChanges = true
        marker.iconView = markerView
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        return marker
    }()
    
    
    
    // marker Tapped Position
    /******************************************************************************************************/
    var markerTappedPosition = CLLocationCoordinate2D()
    /******************************************************************************************************/
    
    
    
    // Google API info between two points
    // Direction to Destination
    fileprivate var didTapTheDestination = false
    fileprivate var didTapTheDestinationPlacePosition = CLLocation()
    fileprivate var destinationTag = 0
    fileprivate var totalremainingDistance = Double()
    fileprivate var totalremainingDuration = Double()
    
    var totalRemainingDistanceInMiles = Double()
    
    
    // Core Data stack infomation variables
    fileprivate var rideStatusTag: Bool = false
    fileprivate var ride:Ride?
    fileprivate var distance = Measurement(value: 0, unit: UnitLength.miles)
    fileprivate var address: [String] = []
    fileprivate var defaultAddressTag: Bool = true
    fileprivate var defaultAddress: String?
    fileprivate var locationList: [CLLocation] = []
    fileprivate var elevationList: [CLLocationDistance] = []
    fileprivate var locationListWithDistance = [[CLLocation(),Double()]]
    
    fileprivate var timer: Timer?
    fileprivate var isPaused: Bool = false
    fileprivate var countdownTimer: Timer?
    fileprivate var countdownNumber: Float = 3.0
    fileprivate var totalMovingTimer: Timer?
    
    fileprivate let locationManager = LocationManager.shared
    fileprivate var seconds = 0
    fileprivate var startLocation: CLLocation!
    fileprivate var lastLocation: CLLocation!
    fileprivate var totalTravelDistance: Double = 0
    fileprivate var movingSeconds = 0
    fileprivate var avgSpeed: Double = 0
    fileprivate var avgMovingSpeed: Double = 0
    fileprivate var speedTag = 0
    
    // MARK: - Altemeter & Pedometer & Barometer will be used for distance and altitude.
    fileprivate var trackingElevationData: Double = 0
    fileprivate var trackingPressureData: Double = 0
    
    var elevationDataTag: Bool = false
    fileprivate var elevationDataArray = [Double]()
    fileprivate var pressureDataArray = [Double]()
    let dataProcessingQueue = OperationQueue()
    let pedometer = CMPedometer()
    let altimeter = CMAltimeter()
    let activityManager = CMMotionActivityManager()
    //********************************************************************************
    
    
    // Weather Infomation Variables
    fileprivate var weatherEnableSwitchOn: Bool?
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
    
    var polylineSegementIndex = Double()
    
    
    let placesClient = GMSPlacesClient.shared()
    
    
    
    // Camera Tag
    var cameraTag = 0
    var cameraBearing = CLLocationDirection()
    
    
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
    var heartRate = UILabel()
    var distanceLabel = UILabel()
    
    
    
    // Labels of Display dock
    
    let labelArray = ["Speed", "Consumption", "Distance", "Time", "Heart Rate", "Heart Rate", "Battery Life"]
    
    
    let descriptionArray = ["Rider Power(W)","Motor Power(W)","Speed(mph)","Heart Rate(bpm)", "Distance(mi)","Cadence(rpm)","Time From Start","Elevation Gain(ft)", "Battery Level(%)", "Calories(KCal)", "Heart Monitoring(bpm)", "Goal"]
    
    var screenOne = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Time From Start","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Heart Rate(bpm)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenTwo = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenThree = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenFour = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    var screenFive = ["image1": "1", "label1": Double.self, "description1": "Rider Power(W)","image2": "1", "label2": Double.self, "description2": "Motor Power(W)","image3": "1", "label3": Double.self, "description3": "Speed(mph)", "image4": "1", "label4": Double.self, "description4": "Consumption(Wh/mi)","image5": "1", "label5": Double.self, "description5": "Distance(mi)"] as [String : Any]
    
    
    
    var featureArray = [Dictionary<String, Any>]()
    
    
    // Overall structure layout
    
    lazy var entireScrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        view.backgroundColor = UIColor.black
        view.isPagingEnabled = false
        view.bounces = false
        view.contentSize = CGSize(width: self.view.bounds.width * CGFloat(2), height: 180)
        //view.layer.zPosition = 5
        view.isScrollEnabled = false
        view.alwaysBounceHorizontal = true
        view.isUserInteractionEnabled = true
        view.delegate = self
        return view
    }()
    
    
    // Main two frames on the entire scroll view
    
    // This is main frame view on the top of first scroll view
    lazy var mainFirstFrameView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: self.view.frame.width * CGFloat(0), y: 0, width: self.entireScrollView.frame.width, height: self.view.frame.height-110)
        view.backgroundColor = UIColor.black
        view.frame.size.width = self.view.bounds.size.width
        return view
    }()
    
    // This is main frame view on the top of second scroll view
    lazy var mainSecondFrameView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: self.view.frame.width * CGFloat(1), y: 0, width: self.entireScrollView.frame.width, height: self.view.frame.height-110)
        view.backgroundColor = UIColor.black
        view.frame.size.width = self.view.bounds.size.width
        return view
    }()
    
    
    
    
    lazy var navItemBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    lazy var ScrollView: UIScrollView = {
        
        let view = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        
        view.backgroundColor = UIColor.black
        //UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
        
        return view
        
    }()
    
    
    let statusViewControl: UIPageControl = {
        let bar = UIPageControl(frame: CGRect(x: 0, y: 0, width:50, height: 30))
        bar.pageIndicatorTintColor = UIColor.white
        bar.currentPageIndicatorTintColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00)
        return bar
    }()
    
    let mainTitle: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width:120, height: 30))
        label.textAlignment = .center
        label.text = "Map"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.layer.zPosition = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    
    
    
    // MARK: - GOOGLE MAP DIRECTION HANDLING FUNCTIONS
    //************************************************************************************************************************************//
    
    let mapView: GMSMapView = {
        
        let view = GMSMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        //view.layer.cornerRadius = 25
        view.mapType = .normal
        view.settings.setAllGesturesEnabled(true)
        view.tintColor = UIColor.DTIBlue()
        view.isMyLocationEnabled = true
        
        view.setMinZoom(5, maxZoom: 20)
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        let mapInsets = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)
        view.padding = mapInsets
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return view
    }()
    
    lazy var mapMenuSlideView: UIView = {
        let view = UIView(frame: CGRect(x: -((self.windowSize?.frame.width)!), y: 0, width: self.view.frame.width, height: 55))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        
        return view
    }()
    
    lazy var mapMenuSlideButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.layer.cornerRadius = button.frame.width/2
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        button.layer.zPosition = 2
        
        button.setImage(UIImage(named: "slideMapMenuOut"), for: .normal)
        button.addTarget(self, action: #selector(slideMapMenu), for: .touchUpInside)
        return button
    }()
    
    
    @objc func slideMapMenu(sender: UIButton) {
        
        // hide map menu
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage(named: "slideMapMenuOut"), for: .normal)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.mapMenuSlideView.frame = CGRect(x: -((self.windowSize?.frame.width)!), y: 0, width: self.view.frame.width, height: 50)
            }, completion: nil)
        } else if sender.tag == 1 {
            sender.tag = 0
            //show the map menu
            sender.setImage(UIImage(named: "slideMapMenuIn"), for: .normal)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.mapMenuSlideView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
            }, completion: nil)
            
        }
        
    }
    
    lazy var myLocationButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.layer.cornerRadius = button.frame.width/2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(named: "myLocation"), for: .normal)
        button.addTarget(self, action: #selector(zoomToMyLocation), for: .touchUpInside)
        
        return button
    }()
    
    
    lazy var mySearchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.layer.cornerRadius = button.frame.width/2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(named: "searchButton"), for: .normal)
        button.addTarget(self, action: #selector(searchAddressForDirection), for: .touchUpInside)
        
        return button
    }()
    
    
    lazy var coffeSearchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.layer.cornerRadius = button.frame.width/2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        
        button.setImage(UIImage(named: "coffeePlaces"), for: .normal)
        button.addTarget(self, action: #selector(POIForPlaces), for: .touchUpInside)
        
        return button
    }()
    
    lazy var restaurantSearchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.layer.cornerRadius = button.frame.width/2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        
        button.setImage(UIImage(named: "foodPlaces"), for: .normal)
        button.addTarget(self, action: #selector(POIForPlaces), for: .touchUpInside)
        
        return button
    }()
    
/*
    lazy var directionToDestButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.layer.cornerRadius = button.frame.width/2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.black
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        
        button.setImage(UIImage(named: "bike"), for: .normal)//?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(directionToDest), for: .touchUpInside)
        
        return button
    }()
    
    
    

    
    
    
    // MARK: - Direction to Destination
    @objc func directionToDest(sender: UIButton) {
        
        let lat = latDirection
        let long = longDirection
        let position = CLLocationCoordinate2DMake(lat, long)
        
        
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage(named: "direction"), for: .normal)
            drawRouteBetweenTwoPoints(coordinate: position)
        }
        if sender.tag == 1 {
            sender.tag = 0
            
            // TODO: We need to fix here!
            //sender.setImage(UIImage(named: "coffeePlaces"), for: .normal)
            
            startButton.setTitleColor(UIColor.DTIRed(), for: .normal)
            startButton.setTitle("Stop", for: .normal)
            startButton.tag = 2
            
            
            // clear the map first and just direction between start to destination point
            
            mapView.clear()
            
            // starting point
            /******************************************************************************************************/
            
            let startPointMapPin = GMSMarker()
            
            let startMarkerImage = UIImage(named: "startPin")
            //!.withRenderingMode(.alwaysTemplate)
            
            //creating a marker view
            let startMarkerView = UIImageView(image: startMarkerImage)
            
            startPointMapPin.iconView = startMarkerView
            
            startPointMapPin.layer.cornerRadius = 25
            startPointMapPin.position = (mapView.myLocation?.coordinate)!
            startPointMapPin.title = "Start"
            startPointMapPin.opacity = 1
            startPointMapPin.infoWindowAnchor.y = 1
            startPointMapPin.map = mapView
            startPointMapPin.appearAnimation = GMSMarkerAnimation.pop
            startPointMapPin.isTappable = true
            
            /******************************************************************************************************/
            
            
            
            // destination
            /******************************************************************************************************/
            let endPointMapPin = GMSMarker()
            
            
            let endMarkerImage = UIImage(named: "endPin")
            let endMarkerView = UIImageView(image: endMarkerImage)
            
            
            endPointMapPin.iconView = endMarkerView
            endPointMapPin.layer.cornerRadius = 25
            endPointMapPin.position = markerTappedPosition
            endPointMapPin.title = "end"
            endPointMapPin.opacity = 1
            endPointMapPin.infoWindowAnchor.y = 1
            endPointMapPin.map = mapView
            endPointMapPin.appearAnimation = GMSMarkerAnimation.pop
            endPointMapPin.isTappable = true
            
            /******************************************************************************************************/
            
            let camera = GMSCameraPosition.camera(withTarget: (mapView.myLocation?.coordinate)!, zoom:15, bearing: (mapView.myLocation?.course)!, viewingAngle: 35)
            self.mapView.animate(to: camera)
            startEbike()
        }
        
    }
     */
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        latDirection = marker.position.latitude
        longDirection = marker.position.longitude
        
        let position = CLLocation(latitude: latDirection, longitude: longDirection)
        didTapTheDestinationPlacePosition = position
        
        print("wow")
        //directionToDestButton.setImage(UIImage(named: "bike"), for: .normal)
        //directionToDestButton.isHidden = false
        
        startButton.setImage(UIImage(named: "bikeButton"), for: .normal)
        didTapTheDestination = true
        
        
        markerTappedPosition = marker.position
        return false
    }
    
    // TODO: TRUE HEADING & MAGNETIC HEADING
    //************************************************************************************************************************************//
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        
        //let theHeading = (newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading
        
        if newHeading.headingAccuracy > 0 {
            let trueHeading = newHeading.trueHeading
            //let heading = trueHeading*Double.pi/180
            
            _ = locationManager.location?.course ?? 0
            self.cameraBearing = trueHeading
            //userCurrentLocationMarker.rotation = trueHeading
            //userCurrentLocationMarker.map = mapView
            
            
            if cameraTag == 0 {
                //let camera = GMSCameraUpdate.
                //mapView.animate(toBearing: trueHeading)
            }
            
        } else {
        
            return
        }
        
    }
    
    
    //************************************************************************************************************************************//

    @objc fileprivate func zoomToMyLocation(sender: UIButton) {
        guard let position = self.mapView.myLocation?.coordinate else { return }
        
        self.cameraTag = 0
        
        let camera = GMSCameraPosition.camera(withTarget: position, zoom: 15, bearing: (mapView.myLocation?.course)!, viewingAngle: 35)
        self.mapView.animate(to: camera)
        
    }

    // Auto SearchBar for the google places
    fileprivate let controller = GooglePlacesSearchController(
        apiKey: Config.GOOGLE_API_KEY,
        placeType: PlaceType.address,
        radius: 1000
    )
    
    
    @objc fileprivate func searchAddressForDirection(sender: UIButton) {
        infoMarker.map = nil
        
        controller.didSelectGooglePlace{(place) -> Void in
            //print(place.description)
            
            //self.infoMarker = GMSMarker(position: position)
            //self.infoMarker.title = place.name
            //self.infoMarker.snippet = place.formattedAddress
            //self.infoMarker.map = self.mapView
            self.mapView.clear()
            
            self.setStartAndEndPin(destination: place.coordinate)
            
            //let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 10)
            //self.mapView.animate(to: camera)
            let bounds = GMSCoordinateBounds(coordinate: place.coordinate, coordinate: (self.mapView.myLocation?.coordinate)!)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
            
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
        print(DrivingMode.DRIVING)
        
        let url = "http://maps.googleapis.com/maps/api/directions/json?origin=\(aPointCoordinate)&destination=\(bPointCoordinate)&sensor=false&mode=\(DrivingMode.DRIVING)"
        
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
                    print("Error: \(String(describing: error?.localizedDescription))")
                    
                } else {
                    
                    guard let data = data else {
                        throw JSONError.NoData
                    }
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                        throw JSONError.ConversionFailed
                    }
                    
                    
                    
                    let arrayRoutes = json["routes"] as! NSArray
                    let arrayLegs = (arrayRoutes[0] as! NSDictionary).object(forKey: "legs") as! NSArray
                    let arraySteps = arrayLegs[0] as! NSDictionary
                    
                    
                    let dicDistance = arraySteps["distance"] as! NSDictionary
                    let totalDistance = dicDistance["text"] as! String
                    self.totalremainingDistance = (dicDistance["value"] as! Double)*(1/1000)*(1.61)
                    
                    
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
                        //print(points)
                        
                        DispatchQueue.main.async {
                            
                            //self.totalDistanceToDestination.text = "Remaining Distance \n \(totalDistance)"
                            //self.totalDurationToDestination.text = "Duration \n \(totalDuration)"
                            
                            let path = GMSPath(fromEncodedPath: points)
                            self.polyPath.map = nil
                            self.polyPath = GMSPolyline(path: path)
                            self.polyPath.strokeWidth = 4
                            self.polyPath.strokeColor = UIColor.DTIRed()
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
    
    
    
    
    //************************************************************************************************************************************//
    
    
    
    // MARK: - SCROLL VIEW PAGE SECTION
    
    //************************************************************************************************************************************//
    
    func featureViewController() {
        featureArray = [screenOne, screenTwo, screenThree, screenFour]
        ScrollView.bounces = false
        ScrollView.isPagingEnabled = true
        ScrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(featureArray.count), height: 480)
        statusViewControl.numberOfPages = featureArray.count
        ScrollView.showsHorizontalScrollIndicator = false
        ScrollView.delegate = self
    }
    
    
    
    
    func loadFeatures() {
        
        for (index,feature) in featureArray.enumerated() {
            
            if (index < 3) {
                
                // Main Frame of the each scroll view
                let mainFrameOfView = UIView()
                mainFrameOfView.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.ScrollView.frame.width, height: 480)
                mainFrameOfView.backgroundColor = UIColor.black
                //UIColor(red:0.02, green:0.19, blue:0.38, alpha:1.00)
                mainFrameOfView.frame.size.width = self.view.bounds.size.width
                
                
                // First view frame of the main view (Left Side)
                let firstViewOfMain = UIView()
                firstViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                firstViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                firstViewOfMain.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                firstViewOfMain.layer.borderWidth = 3
                firstViewOfMain.backgroundColor = UIColor.black
                
                //UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                
                
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
                secondViewOfMain.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                secondViewOfMain.layer.borderWidth = 3
                secondViewOfMain.backgroundColor = UIColor.black
                
                //UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
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
                timeFromStart.textAlignment = .center
                
                
                // Third view frame of the main view(Middle)
                
                let thirdViewOfMain = UIView()
                thirdViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                thirdViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                thirdViewOfMain.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                thirdViewOfMain.layer.borderWidth = 3
                thirdViewOfMain.backgroundColor = UIColor.black
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
                fourthViewOfMain.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                fourthViewOfMain.layer.borderWidth = 3
                fourthViewOfMain.backgroundColor = UIColor.black
                //UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                //UIColor(red:0.66, green:0.46, blue:0.83, alpha:1.00)
                
                
                let fourthLabel = UILabel()
                fourthLabel.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                fourthLabel.backgroundColor = UIColor.clear
                fourthLabel.font = UIFont.boldSystemFont(ofSize: 15)
                fourthLabel.textColor = UIColor.white
                fourthLabel.text = feature["description4"] as! String?
                fourthLabel.textAlignment = .center
                
                
                // Heart Rate Monitor
                heartRate.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 50)
                heartRate.backgroundColor = UIColor.clear
                heartRate.font = UIFont.boldSystemFont(ofSize: 25)
                heartRate.textColor = UIColor.white
                heartRate.textAlignment = .center
                //heartRate.text = "0 bpm"
                
                
                
                // Fifth view frame of the main view (bottom right)
                
                let fifthViewOfMain = UIView()
                fifthViewOfMain.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 100, height: 150)
                fifthViewOfMain.layer.cornerRadius = firstViewOfMain.frame.width/2
                fifthViewOfMain.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                fifthViewOfMain.layer.borderWidth = 3
                fifthViewOfMain.backgroundColor = UIColor.black
                //UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                
                
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
                    ScrollView.addSubview(heartRate)
                    
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
                    
                    _ = heartRate.anchor(fourthLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 50)
                    heartRate.centerXAnchor.constraint(equalTo: fourthViewOfMain.centerXAnchor).isActive = true
                    
                    
                    
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

            else if (index == 3) {
                
                
                // MARK - LAST SCROLL VIEW WITH BIGGER DASH BOARD
                
                let mainFrameOfView = UIView()
                mainFrameOfView.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.ScrollView.frame.width, height: 480)
                mainFrameOfView.backgroundColor = UIColor.black
                //UIColor(red:0.06, green:0.08, blue:0.15, alpha:1.00)
                mainFrameOfView.frame.size.width = self.view.bounds.size.width
                
                
                // Middle Circle to show the all the button to extend
                let middleFrameOfView = UIViewX()
                middleFrameOfView.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 340, height: 340)
                middleFrameOfView.cornerRadius = middleFrameOfView.frame.width/2
                middleFrameOfView.borderWidth = 3
                middleFrameOfView.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00)
                middleFrameOfView.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                middleFrameOfView.translatesAutoresizingMaskIntoConstraints = false
                
                
                
                // SPEED BUTTON
                let speedButton = UIButton()
                speedButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                speedButton.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                speedButton.layer.cornerRadius = speedButton.frame.width/2
                speedButton.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                speedButton.layer.borderWidth = 3
                speedButton.isHighlighted = true
                speedButton.titleLabel?.textAlignment = .center
                speedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                speedButton.setTitle(labelArray[0], for: .normal)
                speedButton.tag = 0
                speedButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                // DISTANCE BUTTON
                let distanceButton = UIButton()
                distanceButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                distanceButton.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                distanceButton.layer.cornerRadius = speedButton.frame.width/2
                distanceButton.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                distanceButton.layer.borderWidth = 3
                distanceButton.isHighlighted = true
                distanceButton.titleLabel?.textAlignment = .center
                distanceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                distanceButton.setTitle(labelArray[2], for: .normal)
                distanceButton.tag = 2
                distanceButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                // TOTAL TIME TRAVEL BUTTON
                let timeButton = UIButton()
                timeButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                timeButton.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                timeButton.layer.cornerRadius = speedButton.frame.width/2
                timeButton.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                timeButton.layer.borderWidth = 3
                timeButton.isHighlighted = true
                timeButton.titleLabel?.textAlignment = .center
                timeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                timeButton.setTitle(labelArray[3], for: .normal)
                timeButton.tag = 3
                timeButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                
                // CURRENT HEART RATE BUTTON
                let heartRateButton = UIButton()
                heartRateButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                heartRateButton.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
                heartRateButton.layer.cornerRadius = speedButton.frame.width/2
                heartRateButton.layer.borderColor = UIColor(red:0.56, green:0.04, blue:0.22, alpha:1.00).cgColor
                heartRateButton.layer.borderWidth = 3
                heartRateButton.isHighlighted = true
                heartRateButton.titleLabel?.numberOfLines = 2
                heartRateButton.titleLabel?.textAlignment = .center
                heartRateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                heartRateButton.setTitle(labelArray[5], for: .normal)
                heartRateButton.tag = 4
                heartRateButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                
                
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
                ScrollView.addSubview(heartRateButton)
                
                
                _ = middleFrameOfView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: mainFrameOfView.frame.width-40, heightConstant: mainFrameOfView.frame.width-40)
                middleFrameOfView.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                middleFrameOfView.centerYAnchor.constraint(equalTo: mainFrameOfView.centerYAnchor).isActive = true
                
                
                _ = speedButton.anchor(middleFrameOfView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
                speedButton.centerXAnchor.constraint(equalTo: middleFrameOfView.centerXAnchor).isActive = true
                
                _ = distanceButton.anchor(nil, left: middleFrameOfView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
                distanceButton.centerYAnchor.constraint(equalTo: middleFrameOfView.centerYAnchor).isActive = true
                
                
                _ = timeButton.anchor(nil, left: nil, bottom: nil, right: middleFrameOfView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 80, heightConstant: 80)
                timeButton.centerYAnchor.constraint(equalTo: middleFrameOfView.centerYAnchor).isActive = true
                
                
                _ = heartRateButton.anchor(nil, left: nil, bottom: middleFrameOfView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 80, heightConstant: 80)
                heartRateButton.centerXAnchor.constraint(equalTo: middleFrameOfView.centerXAnchor).isActive = true
            }
            
            
            
            
        }
        
    }
    

    
    
    let totalDistanceLabel: UILabel = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    lazy var addressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: -((self.windowSize?.frame.width)!), y: mainFirstFrameView.frame.height-50, width: self.view.frame.width, height: 50))
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(red:0.95, green:1.00, blue:1.00, alpha:1.00)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        label.numberOfLines = 2
        label.alpha = 0.9
        return label
    }()
    
    
    let totalDistanceToDestination: UILabel = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        return label
    }()
    
    let totalDurationToDestination: UILabel = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        return label
    }()
    
    
    
    let weatherIcon: UIButton = {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.isHidden = true
        return button
        
    }()
    
    // MARK: - TOOLBAR AT THE BOTTOM OF THE VIEW TO NAVIGATE TO HISTORY VIEW
    
    //************************************************************************************************************************************//

    // History Tag for sort by Distance -> 0
    // History Tag for sort by Data(Time) -> 1
    
    var historySortingTag: Bool = true
    

    
    lazy var toolBox: UIToolbar = {
        let box = UIToolbar(frame: CGRect(x: 0, y: (self.windowSize?.frame.height)!-40, width: (self.windowSize?.frame.width)!, height: 40))
        box.backgroundColor = UIColor.black
        //UIColor(red:0.21, green:0.27, blue:0.31, alpha:1.00)
        box.tintColor = UIColor.white
        box.isTranslucent = false
        box.barTintColor = UIColor.black
        
        
        let historyButton = UIBarButtonItem(title: "History", style: .plain, target: self, action: #selector(moveToHistory))
        historyButton.tag = 1
        box.setItems([historyButton], animated: true)
        //box.isMultipleTouchEnabled = true
        
        
        return box
    }()
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return userDefault.object(forKey: key) != nil
    }
    
    
    @objc func moveToHistory() {
        //userDefault.set(nil, forKey: "historyListSortTypeTag")
        
        if isKeyPresentInUserDefaults(key: "historyListSortTypeTag") == true {
            performSegue(withIdentifier: .history, sender: nil)
            
        } else if isKeyPresentInUserDefaults(key: "historyListSortTypeTag") == false {
            userDefault.set(true, forKey: "historyListSortTypeTag")
            
            let alertViewController = UIAlertController(title: "History by distance? or History by date?", message: "You can change it in the user setting later on", preferredStyle: .alert)
            
            let distance = UIAlertAction(title: "Distance", style: .default) {
                _ in
                
                self.userDefault.set("Distance", forKey: "historyListSortType")
                self.performSegue(withIdentifier: .history, sender: nil)
            }
            let date = UIAlertAction(title: "Date", style: .default, handler: {
                _ in
                
                self.userDefault.set("Date", forKey: "historyListSortType")
                self.performSegue(withIdentifier: .history, sender: nil)
                
            })
            
            alertViewController.addAction(distance)
            alertViewController.addAction(date)
            present(alertViewController, animated: true, completion: nil)
            
            
        }
        
        
        
        
        
        
        
    }
    
    
    //************************************************************************************************************************************//

    
    
    // MARK: - POP UP DASH BOARD
    //************************************************************************************************************************************//

    lazy var closeButton: UIButtonY = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.cornerRadius = button.frame.width/2
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
    
    let heartRateLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()

    
    
    @objc func dismissPopUp(){
        rideView.removeFromSuperview()
        infoView.removeFromSuperview()
    }
    
    
    
    
    @objc func moveToPopUp(sender: UIButton) {
        
        
        mainSecondFrameView.addSubview(rideView)
        mainSecondFrameView.addSubview(infoView)
        infoView.addSubview(closeButton)
        infoView.addSubview(titleLabel)
        
        _ = rideView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: view.frame.height)
        rideView.centerXAnchor.constraint(equalTo: mainSecondFrameView.centerXAnchor).isActive = true
        rideView.centerYAnchor.constraint(equalTo: mainSecondFrameView.centerYAnchor).isActive = true
        
        
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
            heartRateLabel.removeFromSuperview()
            
            infoView.addSubview(speedLabel)
            
            _ = speedLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            speedLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            speedLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
            
        }
        
        if sender.tag == 2{
            timeLabel.removeFromSuperview()
            speedLabel.removeFromSuperview()
            heartRateLabel.removeFromSuperview()
            
            infoView.addSubview(totalDistanceLabel)
            
            _ = totalDistanceLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            totalDistanceLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            totalDistanceLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
            
        }
        
        if sender.tag == 3 {
            speedLabel.removeFromSuperview()
            totalDistanceLabel.removeFromSuperview()
            heartRateLabel.removeFromSuperview()
            
            infoView.addSubview(timeLabel)
            
            _ = timeLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            timeLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            timeLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
            
        }
        
        if sender.tag == 4 {
            totalDistanceLabel.removeFromSuperview()
            speedLabel.removeFromSuperview()
            timeLabel.removeFromSuperview()
        
            infoView.addSubview(heartRateLabel)
            
            _ = heartRateLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            heartRateLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            heartRateLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
            
        }
        
        for (index, label) in labelArray.enumerated() {
            if (index == sender.tag) {
                titleLabel.text = label
                
            }
            
        }
        
    }
    
    //************************************************************************************************************************************//

    
    //*******************************************************************************************************************************//
    
    
    
    
    
    
    
    // MARK: - GOOGLE MAP HANDLING SECTION!!
    //*******************************************************************************************************************************//
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
            
        case .authorizedWhenInUse:
            mapView.isMyLocationEnabled = true
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoMarker.map = nil
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        if gesture {
            UIScreen.main.brightness = CGFloat(1)
            cameraTag = 1
            print(gesture)
        }
    }
    
    // MARK: - This function is called whenever current location is changed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        

        /*
        if resetKalmanFilter == true {
            hcKalmanFilter?.resetKalman(newStartLocation: locations.first!)
            resetKalmanFilter = false
        }
        */
        if startLocation == nil {
            //self.hcKalmanFilter = HCKalmanAlgorithm(initialLocation: locations.first!)
            
            startLocation = locations.first
            path.add(startLocation.coordinate)
            lastLocation = locations.first
            userCurrentLocationMarker.position = startLocation.coordinate
            userCurrentLocationMarker.map = mapView
            //locationListWithDistance[0] = [startLocation,0]
            
        } else if let location = locations.last {
            
            
            let age = -location.timestamp.timeIntervalSinceNow
            
            if age > 10 {
                print("Location is old")
            }
            if location.horizontalAccuracy < 0 {
                print("Lat and Long values are invalid")
            }
            if location.horizontalAccuracy > 100 {
                print("Accuracy is too low")
            }
            
            
            // Filter out invalid location and takes only when horizontal accuracy is reasonable range
            if age < 10 && location.horizontalAccuracy > 0 && location.horizontalAccuracy <= 50 {
                print("Location quality is good enough")
                
                //if let kalmanLocation = hcKalmanFilter?.processState(currentLocation: location) {
                
                    totalTravelDistance += lastLocation.distance(from: location)
                    
                    
                    userCurrentLocationMarker.position = location.coordinate
                    userCurrentLocationMarker.map = mapView
                    
                    
                    // Since we search for the place and set the destination we should start tracking
                    if destinationTag == 1 {
                        //totalRemainingDistanceInMiles = (totalremainingDistance/1000)*1.61
                        // FIXIT - I need to fix the Alert View
                        if totalremainingDistance < 0.05 && totalremainingDistance > 0.00{
                            //totalDistanceToDestination.text = "Remaining Distance = \(0.0)mi"
                            destinationTag = 0
                            
                            let destinationAlertView = UIAlertController(title: "Destination!", message: "We are here :)", preferredStyle: .alert)
                            
                            let cancel = UIAlertAction(title: "Alright", style: .default)
                            
                            destinationAlertView.addAction(cancel)
                            
                            present(destinationAlertView, animated: true, completion: nil)
                            
                        } else if totalremainingDistance > 0.05 {
                            
                            if lastLocation.distance(from: location) < 10{
                                let distanceSegnment = (lastLocation.distance(from: location))*(1/1000)*(1.61)
                                totalremainingDistance -= distanceSegnment
                                
                                print("*******************************************************************************************************")
                                print(totalremainingDistance)
                                print("*******************************************************************************************************")
                                print(distanceSegnment)
                                print("********************************************************************************************************")
                                
                                //totalDistanceToDestination.text = "Remaining Distance \n \(String(format: "%.2f", totalremainingDistance))mi"
                            }
                            
                        } else if totalremainingDistance < 0.00{
                            //totalDistanceToDestination.text = "Distance = There is something wrong with total remaining distance"
                            
                        }
                    }
                
                    
                    print("Traveled Distance:",  totalTravelDistance)
                    print("Straight Distance:", startLocation.distance(from: location))
                    print("Elevation:", location.altitude)
                    print("Relative Elevation:", trackingElevationData)
                    print("Speed:", location.speed)
                    
                    let msTomph = Double((location.speed as Double)*(1/1000)*(1/1.61)*(3600)).rounded(toPlaces: 2)
                
                
                    // whenever customer goes beyond 70mph then we will notify him to slow down
                    if msTomph > 70.0 && speedTag == 0{
                        speedTag = 1
                        let alertController = UIAlertController(title: "Warning!", message: "You might want to slow down for your safety", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                        
                        alertController.addAction(cancelAction)
                        alertController.view.tintColor = UIColor.DTIRed()
                        alertController.view.backgroundColor = UIColor.black
                        alertController.view.layer.cornerRadius = 25
                        
                        present(alertController, animated: true, completion: nil)
                    }
                    
                    if msTomph < 20.0 {
                        speedTag = 0
                    }
                    
                    speedLabel.text = "\(msTomph)/mph"
                    thirdData.text = "\(msTomph)/mph"
                    thirdDataSecond.text = "\(msTomph)/mph"
                    thirdDataThird.text = "\(msTomph)/mph"
                    
                
                    
                    // store the latest location for different purposes
                    lastLocation = location
                
                    // keep updating the cumulative distance from the start
                    distance = Measurement(value: totalTravelDistance, unit: UnitLength.meters)
                    
                    // when map is not moved by customer, when customer move the map or pinch it then camera will not update the camera
                    if cameraTag == 0{
                        
                        /***
                         When navigation start and the arrow icon need to direct where the device is moving towards, bearing angel is the main role of the heading
                         location.course will return degree or bearing where the device is heading toward
                         ***/
                        
                        let heading = location.course
                        let camera1 = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16, bearing: heading, viewingAngle: 35)
                        mapView.animate(to: camera1)
                        
                        
                    }
                    
                    
                
                
                    // Just keep adding all the heart rate data to get the average heart rate in the saved
                    cumulativeSumOfHeartRateData += currentHeartRate
                    heartRateList.append(currentHeartRate)
                
                    // The valid location should be store in the array
                    locationList.append(location)
                
                
                    // Look for the address
                    reverseGeocodeCoordinate(coordinate: location.coordinate)
                
                    // whenever location changes in which every 3 meters then we pick up the relative altitude and air pressure around device
                    elevationDataArray.append(trackingElevationData)
                    pressureDataArray.append(trackingPressureData)
                
                    // add every coordinate to the mutable path to draw polyline as you go along
                    path.add(location.coordinate)
                    drawPath(path: path, speed: msTomph)

            }
        }
        
        // TODO: I need to think about some other way to show the weather info --> This is hard coded
        if locationList.count == 1{
            weatherSwitchCheck()
        }
        
        
        
    }
    
    func weatherSwitchCheck() {
        if userDefault.value(forKey: "switchOn") != nil {
            let switchOn:Bool = userDefault.value(forKey: "switchOn") as! Bool
            if switchOn == true {
                getWeatherInfo()
            } else {
                print("You need to go to settings to turn on the weather switch on")
            }
        }
    }
    

    
    
    // draw black line on the map that shows how current object moving
    func drawPath(path: GMSPath, speed: Double) {
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.geodesic = true
        
        polyline.strokeColor = UIColor.black
        //polyline.strokeColor = UIColor(red:0.14, green:0.17, blue:0.17, alpha:1.00)
        polyline.map = self.mapView
    }
    
    
    // Get the human readable address
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate){(placemark, error) in
            
            if (error != nil && placemark == nil){
                print("Error occurred = \(String(describing: error))")
            }
                
            else {
                if (error == nil && placemark != nil) {
                    
                    if let place = placemark?.firstResult() {
                        
                        if place.thoroughfare != nil {
                            self.addressLabel.text = " \(place.lines![0])"
                            
                            if place.locality == nil {
                                self.address.append("\(String(describing: place.country))")
                                
                            } else if place.locality != nil {
                                guard let locality = place.locality else { return }
                                guard let administrativeArea = place.administrativeArea else { return }
                                guard let country = place.country else { return }
                                if self.defaultAddressTag == true {
                                    self.defaultAddress = "\(locality)"
                                    self.defaultAddressTag = false
                                }
                                self.address.append("\(locality) \(administrativeArea) \(country)")
                                
                                
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
        if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == CLError.Code.denied.rawValue{
            // User denied your app to access your location information
            showTurnOnLocationServiceAlert()
            
        }
    }
    
    func showTurnOnLocationServiceAlert() {
        NotificationCenter.default.post(name: Notification.Name(rawValue:"showTurnOnLocationServiceAlert"), object: nil)
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
        infoMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        infoMarker.layer.cornerRadius = 25
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 1
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        infoMarker.appearAnimation = GMSMarkerAnimation.pop
        infoMarker.isTappable = true
        mapView.selectedMarker = infoMarker

    }
    /*
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    
    }
    */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if entireScrollView.contentOffset.x == view.frame.width {
            if rideStatusTag == true {
                rideStatusTag = false
                statusViewControl.currentPage = Int(0)
            } else {
                let page = scrollView.contentOffset.x / scrollView.frame.size.width
                statusViewControl.currentPage = Int(page)
            }
            
        } else {
            statusViewControl.currentPage = Int(0)
            
        }
        
        
    }
    
    //************************************************************************************************************************************//
    
    
    
    
    // MARK: - Sliding left menu
    
    //************************************************************************************************************************************//
    
    lazy var slideMenuButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "menu-1"), for: .normal)
        //button.tintColor = UIColor.DTIRed()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleSideMenuButton), for: .touchUpInside)
        return button
        
    }()
    
    lazy var settingMenu: SettingMenuSlide = {
        let menu = SettingMenuSlide()
        menu.rideStatusView = self
        return menu
    }()
    
    
    @objc func handleSideMenuButton() {
        
        //Show Menu
        settingMenu.handleSideMenuButton()
        
    }
    
    
    func showControllerWithMyHistoryButton() {
        moveToHistory()
    }
    
    
    func showControllerWithMyStatsButton() {
        
        self.performSegue(withIdentifier: .myStats, sender: nil)
    }
    
    func showControllerWithBikeTypesButton() {
        
        self.performSegue(withIdentifier: .bikeTypes, sender: nil)
    }
    
    
    func connectToDevice() {
        
        print("START LOOKING FOR THE BLUETOOTH SIGNAL!!!")
        
        // MARK: - Bluetooth Delegate Searching DEVICE
        //********************************************************************************************************************************//
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: [
            CBCentralManagerOptionShowPowerAlertKey: true
        ])
        //********************************************************************************************************************************//
        
        
    }
    
    func showControllerWithTermsAndPrivacyButton() {
        self.performSegue(withIdentifier: .termsAndPrivacy, sender: nil)
    }
    
    
    func showControllerWithSettingButton() {
        self.performSegue(withIdentifier: .setting, sender: nil)
    }
    
    func showControllerWithLogoutButton() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginAndOutViewController")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    
    //************************************************************************************************************************************//
    
    
    
    // MARK: - PAGE CONTROL ARROW TO SWIPE THROUGH SCROLL VIEW
    //************************************************************************************************************************************//
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.leftArrowButton.isHidden = false
            self.rightArrowButton.isHidden = false
            UIScreen.main.brightness = CGFloat(1)
        
        }, completion: nil)
        
    }
    

    
    
    lazy var leftArrowButton: UIButtonY = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 40, height: 45))
        button.setImage(UIImage(named: "arrowLeftKey")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.contentMode = .scaleAspectFit
        button.isHighlighted = true
        button.isHidden = true
        button.addTarget(self, action: #selector(leftScrollView), for: .touchUpInside)
        
        return button
    }()
    
    @objc func leftScrollView() {
        
        if statusViewControl.currentPage != Int(0) {
            let position = CGPoint(x: ScrollView.contentOffset.x - view.frame.width, y: ScrollView.contentOffset.y)
            ScrollView.setContentOffset(position, animated: true)
        } else {
            let position = CGPoint(x: ScrollView.contentOffset.x + (view.frame.width*3), y: ScrollView.contentOffset.y)
            ScrollView.setContentOffset(position, animated: true)
            
        }
        
    }
    
    
    
    lazy var rightArrowButton: UIButtonY = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 40, height: 45))
        button.setImage(UIImage(named: "arrowRightKey")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.contentMode = .scaleAspectFit
        button.isHighlighted = true
        button.isHidden = true
        button.addTarget(self, action: #selector(rightScrollView), for: .touchUpInside)
        
        return button
    }()
    
    @objc func rightScrollView() {
        
        if statusViewControl.currentPage != Int(3) {
            let position = CGPoint(x: ScrollView.contentOffset.x + view.frame.width, y: ScrollView.contentOffset.y)
            ScrollView.setContentOffset(position, animated: true)
        } else {
            let position = CGPoint(x: 0, y: ScrollView.contentOffset.y)
            ScrollView.setContentOffset(position, animated: true)
            
        }
        
    }
    
    
    
    //************************************************************************************************************************************//
    
    
    
    
    // MARK: - Specific Info View while riding on the bike
    
    //************************************************************************************************************************************//
    
   
    
    
    lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        //view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DismissMenuBar)))
        
        return view
    }()
    
    lazy var countdownLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 100)
        label.isHidden = true
        label.center = self.view.center
        
        return label
    }()
    
    let mapButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
    
        return view
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton()
        
        
        //button.setTitle("Map", for: .normal)
        button.setImage(UIImage(named:"mapGlow"), for: .normal)
        button.backgroundColor = UIColor.clear
        //button.setTitleColor(UIColor.DTIRed(), for: .normal)
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.shadowColor = UIColor.DTIRed().cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: -1)
        button.titleLabel?.layer.shadowColor = UIColor.white.cgColor
        button.titleLabel?.layer.shadowRadius = 4.0
        button.titleLabel?.layer.shadowOffset = CGSize.zero
        
        
        button.addTarget(self, action: #selector(moveToMapView), for: .touchUpInside)
        return button
    }()
    
    @objc func moveToMapView(){
        
        mainTitle.text = "Map"
        let position = CGPoint(x: 0, y: 0)
        entireScrollView.setContentOffset(position, animated: true)

        mapButton.setImage(UIImage(named:"mapGlow"), for: .normal)
        rideStatusButton.setImage(UIImage(named:"ridestatus"), for: .normal)
        
    }
    
    let rideStatusButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    lazy var rideStatusButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textAlignment = .center
        //button.setTitle("Status", for: .normal)
        button.setImage(UIImage(named: "ridestatus"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        //button.setTitleColor(UIColor.white, for: .normal)
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.shadowColor = UIColor.DTIRed().cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: -1)
        //button.isHighlighted = true
        //button.isSelected = false
        button.addTarget(self, action: #selector(moveToRideStatusView), for: .touchUpInside)
        return button
    }()
    
    
    @objc func moveToRideStatusView(){
        
        mainTitle.text = "Status"
        
        let position = CGPoint(x: 0 + view.frame.width, y: entireScrollView.contentOffset.y)
        entireScrollView.setContentOffset(position, animated: true)
        rideStatusTag = true

        mapButton.setImage(UIImage(named:"map"), for: .normal)
        rideStatusButton.setImage(UIImage(named:"ridestatusGlow"), for: .normal)
        
        
    }
    
    let startButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    lazy var startButton: UIButton = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "startButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        //button.setTitle("Start", for: .normal)
        button.cornerRadius = button.frame.width/2
        button.borderWidth = 0.5
        button.borderColor = UIColor.black
        button.backgroundColor = UIColor.black
        //button.tintColor = UIColor.white
        //button.titleLabel?.textColor = UIColor.white
        //button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        //button.shadowColor = UIColor.DTIRed()
        //button.shadowOffset = CGSize(width: 1, height: -1)
        button.tag = 1
        
        button.addTarget(self, action: #selector(startAndStop), for: .touchUpInside)
        
        return button
    }()
    
    
    
    
    @objc func startAndStop(sender: UIButton) {
        
        if didTapTheDestination == true {
            sender.setImage(UIImage(named: "startButton"), for: .normal)
            didTapTheDestination = false
            
            let position = didTapTheDestinationPlacePosition
            
            
            // clear the map first and just direction between start to destination point
            
            mapView.clear()
            
            self.setStartAndEndPin(destination: position.coordinate)
            
            
            //let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 10)
            //self.mapView.animate(to: camera)
            let bounds = GMSCoordinateBounds(coordinate: position.coordinate, coordinate: (self.mapView.myLocation?.coordinate)!)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
            
            self.drawRouteBetweenTwoPoints(coordinate: position.coordinate)
            
        } else {
            
            if let window = UIApplication.shared.keyWindow {
                window.addSubview(blackView)
                window.addSubview(countdownLabel)
                
                blackView.frame = window.frame
                blackView.alpha = 0
            }
            
            
            if (sender.tag == 1) {
                
                //sender.setTitleColor(UIColor.DTIRed(), for: .normal)
                
                sender.tag = 2
                
                countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                    _ in
                    
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        
                        self.blackView.alpha = 1
                        self.countdownLabel.isHidden = false
                        
                    }, completion: nil)
                    
                    self.countdownLabel.text = "\(Int(self.countdownNumber))"
                    // TODO: show the time count with some text
                    if self.countdownNumber == 0 {
                        self.countdownLabel.textColor = UIColor(red:0.76, green:0.18, blue:0.76, alpha:1.00)
                        self.countdownLabel.text = "Go!"
                    }
                    
                    
                    print(self.countdownNumber)
                    if self.countdownNumber == -1 {
                        // Reset the kalman filter algorithm to store new data
                        self.resetKalmanFilter = true
                        
                        
                        
                        
                        // Don't go to sleep mode while app is running or when start button is clicked
                        UIApplication.shared.isIdleTimerDisabled = true
                        //UIScreen.main.brightness = CGFloat(0.7)
                        
                        // Heart Rate Tag Change to 1 to append data to array
                        
                        
                        
                        // MARK - Disappear the History tool bar when start button clicked
                        /*
                         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                         self.toolBox.frame = CGRect(x: 0, y: (self.windowSize?.frame.height)!+40, width: (self.windowSize?.frame.width)!, height: 40)
                         
                         }, completion: nil)
                         */
                        
                        
                        
                        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            
                            self.blackView.alpha = 0
                            self.countdownLabel.isHidden = true
                            sender.setImage(UIImage(named: "stopButton"), for: .normal)
                            
                        }, completion: nil)
                        
                        
                        self.startEbike()
                        
                        self.countdownTimer?.invalidate()
                        self.countdownNumber = 3
                    }
                    
                    self.countdownNumber -= 1
                }
                
            } else if (sender.tag == 2){
                
                // Can be go to sleep mode after your ride is done and play with apps
                UIApplication.shared.isIdleTimerDisabled = false
                //UIScreen.main.brightness = CGFloat(1.0)
                
                
                //The pause should be occured here!!!!!
                self.isPaused = true
                self.locationManager.stopUpdatingLocation()
                self.locationManager.stopUpdatingHeading()
                //altimeter.stopRelativeAltitudeUpdates()

                alertView(sender: sender)
                
            }
            
            
        }

        
    }
    
    
    
    
    
    
    fileprivate func startEbike() {
        
        // Start store the heart rate data to the array
        heartRateTag = 1
        
        // Start store the relative elevation data from altimeter to the queue
        elevationDataTag = true
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: dataProcessingQueue, withHandler: {(data, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                } else {
                    DispatchQueue.main.async{
                        print(data?.relativeAltitude as! Double)
                        self.trackingElevationData = data?.relativeAltitude as! Double
                        self.trackingPressureData = data?.pressure as! Double
                    }
                }
                
            })
            
        }
        
        // MARK - Destination tag should be on in order to keep track remaining distance and time
        destinationTag = 1
        
        
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 5
            locationManager.startUpdatingHeading()
        }
        locationManager.startUpdatingLocation()
        
        
        let camera = GMSCameraPosition(target: (self.mapView.myLocation?.coordinate)!, zoom: 15, bearing: (self.mapView.myLocation?.course)!, viewingAngle: 35)
        mapView.animate(to: camera)
        
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.addressLabel.frame = CGRect(x: 0, y: self.mainFirstFrameView.frame.height-50, width: self.view.frame.width, height: 50)
            
        }, completion: nil)
        
        
        
        
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        
        seconds = 0
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ _ in
            if self.isPaused == false {
                self.seconds += 1
                let formattedDistance = FormatDisplay.distance(self.distance)
                let formattedTime = FormatDisplay.time(self.seconds)
                
                self.timeFromStart.text = "\(formattedTime)"
                self.timeLabel.text = "\(formattedTime)"
                self.distanceLabel.text = "\(formattedDistance)"
                self.totalDistanceLabel.text = "\(formattedDistance)"
            }
            
        }
        
    }
    
    
    fileprivate func alertView(sender: UIButton) {
        
        
        if locationList.count > 1 {
            let alertController = UIAlertController(title: "End Ride?", message: "Do you want to end your ride?", preferredStyle: .alert)
            let titleFont: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.boldSystemFont(ofSize: 20)]
            let messageFont: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 18)]
            
            let attributedTitle = NSMutableAttributedString(string: "End Ride?", attributes: titleFont)
            let attributedMessage = NSMutableAttributedString(string: "Do you want to save your ride?", attributes: messageFont)
            
            alertController.setValue(attributedTitle, forKey: "attributedTitle")
            alertController.setValue(attributedMessage, forKey: "attributedMessage")
            
            let saveButton = UIAlertAction(title: "Save", style: .default) {
                _ in
                
                // Stop storing the heart rate data to the array
                self.heartRateTag = 2
                //sender.setTitleColor(UIColor.white, for: .normal)
                sender.setImage(UIImage(named: "startButton"), for: .normal)
                sender.tag = 1
                
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.addressLabel.frame = CGRect(x: -(self.windowSize?.frame.width)!, y: self.mainFirstFrameView.frame.height-50, width: self.view.frame.width, height: 50)
                    
                }, completion: nil)
                
                self.saveAsItIsRoute()
            }
            
            let changeNameButton = UIAlertAction(title: "New Route", style: .default) {
                _ in
                
                self.heartRateTag = 2
                //sender.setTitleColor(UIColor.white, for: .normal)
                sender.setImage(UIImage(named: "startButton"), for: .normal)
                sender.tag = 1
                
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.addressLabel.frame = CGRect(x: -(self.windowSize?.frame.width)!, y: self.mainFirstFrameView.frame.height-50, width: self.view.frame.width, height: 50)
                    
                }, completion: nil)
                
                self.saveNameOfRoute()
                
            }
            
            let cancelButton = UIAlertAction(title: "Resume", style: .cancel) {
                _ in
                self.locationManager.startUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                self.isPaused = false
            }
            
            
            alertController.view.tintColor = UIColor.DTIBlue()
            alertController.view.layer.cornerRadius = 25
            alertController.view.backgroundColor = UIColor.darkGray
            
            
            alertController.addAction(saveButton)
            alertController.addAction(changeNameButton)
            alertController.addAction(cancelButton)
            present(alertController, animated: true, completion: nil)
            
        } else {
            let alertController = UIAlertController(title: "Go take some ride!", message: "We need to have at least few location points in order to analyze your data", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Okay", style: .cancel)
            
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
            
        }

        
        
    }
    
    fileprivate func saveAsItIsRoute() {
        self.stopEbike()
        
        // We might have no address is stored so we need to save default name as i assignment
        
        if let defaultName = self.defaultAddress {
            self.saveEbike(name: "\(defaultName) Ride")
            
        } else {
            self.saveEbike(name: "Perfect Ride")
        }
        self.performSegue(withIdentifier: .stopAndSave, sender: nil)
        
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
        
        // stop timer for this ride
        timer?.invalidate()
        
        // stop update altemeter altidue update and press
        altimeter.stopRelativeAltitudeUpdates()
        
        // stop update the location
        locationManager.stopUpdatingLocation()
        
        // stop update the heading of the device
        locationManager.stopUpdatingHeading()
        defaultAddressTag = true
        
    }
    
    
    // MARK: - CORE DATA SECTION TO STORE DATA!
    
    //************************************************************************************************************************************//
    
    
    fileprivate func saveEbike(name: String) {
        
        // Each ride has a set of locations and each location has to be only one instance not multiple
        
        let newRide = Ride(context: CoreDataStack.context)
        newRide.distance = distance.value
        newRide.duration = Int16(seconds)
        newRide.timestamp = Date()
        newRide.name = name
        
        
        // Get the average heart rate to store in core data
        if heartRateList.count > 0 {
            newRide.avgheartrate = Int16(cumulativeSumOfHeartRateData/heartRateList.count)
        } else {
            newRide.avgheartrate = 0
        }
        
        
        //
        if address.count > 0 {
            newRide.address = address[2]
        } else {
            newRide.address = "No address is registered"
        }

        
        // This is absolute elevation
        let initialAbsoluteElevation = (locationList[1].altitude*(3.28084))
        
        // This is relative elevation
        for i in 0..<locationList.count {
            let locationObject = Locations(context: CoreDataStack.context)
            
                
            //locationList[i].altitude as Double
            locationObject.timestamp = locationList[i].timestamp as Date
            
            
            if elevationDataArray[i] < 0 {
                locationObject.elevation = (initialAbsoluteElevation-(elevationDataArray[i]*(3.28084)))
            } else {
                locationObject.elevation = (initialAbsoluteElevation+(elevationDataArray[i]*(3.28084)))
                locationObject.pressure = pressureDataArray[i]
            }
            
            
            if locationList[i].speed < 0 {
                locationObject.speed = 0
            }
            else {
                locationObject.speed = locationList[i].speed as Double
                
            }
            locationObject.latitude = locationList[i].coordinate.latitude
            locationObject.longitude = locationList[i].coordinate.longitude
            locationObject.heartRate = Int16(heartRateList[i])
            newRide.addToLocations(locationObject)
        }
        
        // Save the context
        CoreDataStack.saveContext()
        ride = newRide
            
    }
    
    
    
    //MARK: - Weather Info Section ************************************************************************************************************************************//
    
    fileprivate func setWeatherIcon() {
        if let icon = currentWeatherIcon {
            switch icon as String {
            case CurrentWeatherStatus.rain.rawValue:
                weatherIcon.setImage(UIImage(named: "rain"), for: .normal)
                iconString = "rain"
            case CurrentWeatherStatus.clearDay.rawValue:
                weatherIcon.setImage(UIImage(named: "clear"), for: .normal)
                iconString = "clear"
            case CurrentWeatherStatus.clearNight.rawValue:
                weatherIcon.setImage(UIImage(named: "clear"), for: .normal)
                iconString = "clear"
            case CurrentWeatherStatus.someCloudDay.rawValue:
                weatherIcon.setImage(UIImage(named: "cloudy"), for: .normal)
                iconString = "cloudy"
            case CurrentWeatherStatus.someCouldNight.rawValue:
                weatherIcon.setImage(UIImage(named: "cloudy"), for: .normal)
                iconString = "cloudy"
            case CurrentWeatherStatus.sleet.rawValue:
                weatherIcon.setImage(UIImage(named: "sleet"), for: .normal)
                iconString = "sleet"
            case CurrentWeatherStatus.cloudy.rawValue:
                weatherIcon.setImage(UIImage(named: "cloudy"), for: .normal)
                iconString = "cloudy"
            case CurrentWeatherStatus.snow.rawValue:
                weatherIcon.setImage(UIImage(named: "snow"), for: .normal)
                iconString = "snow"
            case CurrentWeatherStatus.wind.rawValue:
                weatherIcon.setImage(UIImage(named: "wind"), for: .normal)
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
        
        if let temp = currentTemperature {
            if let summary = currentWeatherSummary {
                let alertController = UIAlertController(title: "Weather", message: "Temperature: \(temp)F° \n Condition: \(summary)", preferredStyle: .alert)
                
                let titleFont: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.boldSystemFont(ofSize: 18)]
                let messageFont: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 16)]
                
                
                let attributedTitle = NSMutableAttributedString(string: "Weather", attributes: titleFont)
                let attributedMessage = NSMutableAttributedString(string: "Temperature: \(temp)F° \n Condition: \(summary)", attributes: messageFont)
                
                alertController.setValue(attributedTitle, forKey: "attributedTitle")
                alertController.setValue(attributedMessage, forKey: "attributedMessage")
                
                guard let icon = iconString else {return}
                
                let image = UIImage(named: icon)

                
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
    
    
    
    
    func getWeatherInfo() {
        
        
        let currentLocationLat: Double?
        let currentLocationLong: Double?
        let forecastService = ForecastService(APIKey: Config.FORECAST_API_KEY)
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
    
    
    //************************************************************************************************************************************//
    
    
    // ************************************************************************************************************************************//
    

    @objc func showTurnOnLocationServiceAlert(_ notification: NSNotification){
        let alert = UIAlertController(title: "Turn on Location Service", message: "To use location tracking feature of the app, please turn on the location service from the Settings app.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    //************************************************************************************************************************************//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        userCurrentLocationMarker.map = mapView
        
        OperationQueue.main.addOperation {
            self.locationManager.delegate = self
            self.mapView.delegate = self
        }
        
        /******************************************************************************************************/
        // Testing for location accuracy
        //self.didInitialZoom = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTurnOnLocationServiceAlert(_:)), name: Notification.Name(rawValue:"showTurnOnLocationServiceAlert"), object: nil)
        
        /******************************************************************************************************/
        
        
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        view.backgroundColor = UIColor.black
        
        
        
        // TOP LEFT
        view.addSubview(slideMenuButton)
        
        // TOP MIDDLE
        view.addSubview(mainTitle)
        
        // TOP RIGHT
        view.addSubview(weatherIcon)
        
        
        // The entire scroll view
        view.addSubview(entireScrollView)
        
        // MAP Section
        entireScrollView.addSubview(mainFirstFrameView)
        // MAP
        mainFirstFrameView.addSubview(mapView)
        
        
        
        // Map Menu Slide View
        mapView.addSubview(mapMenuSlideView)
        
        
        // Map Menu Toggle Button
        mapView.addSubview(mapMenuSlideButton)
        
        
        
    
        
        // BELOW PAGE CONTROL
        mapView.addSubview(addressLabel)
        
        // find my location
        mapView.addSubview(myLocationButton)
        
        
        // place search
        mapMenuSlideView.addSubview(mySearchButton)
        
        // find restaurant place
        mapMenuSlideView.addSubview(restaurantSearchButton)
        
        // find coffee places
        mapMenuSlideView.addSubview(coffeSearchButton)
        // direct A to B point (navigation)
        //mapMenuSlideView.addSubview(directionToDestButton)
        
        
        
        
        // Ride Status Section
        entireScrollView.addSubview(mainSecondFrameView)
        
        // Scroll View in Second Main Frame View
        mainSecondFrameView.addSubview(ScrollView)
        
        
        // LEFT ARROW
        mainSecondFrameView.addSubview(leftArrowButton)
        
        // RIGHT ARROW
        mainSecondFrameView.addSubview(rightArrowButton)
        
        // BELOW MAP VIEW
        mainSecondFrameView.addSubview(statusViewControl)
        
        
        
        mainSecondFrameView.addSubview(totalDistanceToDestination)
        
        mainSecondFrameView.addSubview(totalDurationToDestination)
        
        
        
        view.addSubview(navItemBarView)
        
        navItemBarView.addSubview(mapButtonContainer)
        
        mapButtonContainer.addSubview(mapButton)
        
        
        //navItemBarView.addSubview(startButtonContainer)
        
        navItemBarView.addSubview(startButton)
        
        
        navItemBarView.addSubview(rideStatusButtonContainer)
        
        rideStatusButtonContainer.addSubview(rideStatusButton)
        
        // BOTTOM
        //view.addSubview(toolBox)
        
        
        
        // MARK: - Constraints ********************************************************************************************************************************************************//
        
        // MAIN RIDE STATUS VIEW
        _ = mainTitle.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 30)
        mainTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // PROFILE SETTING VIEW
        
        _ = slideMenuButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 23, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 25, heightConstant: 25)
        
        // WEATHER ICON ON THE RIGHT TOP OF THE VIEW
        
        _ = weatherIcon.anchor(view.topAnchor, left: mainTitle.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 30, heightConstant: 30)
        
        
        _ = entireScrollView.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 60, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: view.frame.height-110)
        entireScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        // MAP
        _ = mapView.anchor(mainFirstFrameView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: mainFirstFrameView.frame.width, heightConstant: mainFirstFrameView.frame.height)
        mapView.centerXAnchor.constraint(equalTo: mainFirstFrameView.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: mainFirstFrameView.centerYAnchor).isActive = true
        
        _ = mapMenuSlideButton.anchor(mapView.topAnchor, left: mapView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        _ = mySearchButton.anchor(mapMenuSlideView.topAnchor, left: mapMenuSlideView.leftAnchor, bottom: mapMenuSlideView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 55, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        mySearchButton.centerYAnchor.constraint(equalTo: mapMenuSlideView.centerYAnchor).isActive = true
        
        _ = coffeSearchButton.anchor(mapMenuSlideView.topAnchor, left: mySearchButton.rightAnchor, bottom: mapMenuSlideView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        coffeSearchButton.centerYAnchor.constraint(equalTo: mapMenuSlideView.centerYAnchor).isActive = true
        
        _ = restaurantSearchButton.anchor(mapMenuSlideView.topAnchor, left: coffeSearchButton.rightAnchor, bottom: mapMenuSlideView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        restaurantSearchButton.centerYAnchor.constraint(equalTo: mapMenuSlideView.centerYAnchor).isActive = true
        
        //_ = directionToDestButton.anchor(mapMenuSlideView.topAnchor, left: nil, bottom: mapMenuSlideView.bottomAnchor, right: mapMenuSlideView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 50, heightConstant: 50)
        //directionToDestButton.centerYAnchor.constraint(equalTo: mapMenuSlideView.centerYAnchor).isActive = true
        
        
        _ = myLocationButton.anchor(nil, left: nil, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 25, rightConstant: 5, widthConstant: 50, heightConstant: 50)
        
        
        // MAIN SCROLL VIEW OF THE DASHBOARD & GOOGLE MAP
        
        _ = ScrollView.anchor(mainSecondFrameView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 480)
        ScrollView.centerXAnchor.constraint(equalTo: mainSecondFrameView.centerXAnchor).isActive = true
        
        
        // RIGHT & LEFT ARROW TO NAVIGATE SCROLL VIEW
        
        _ = leftArrowButton.anchor(ScrollView.bottomAnchor, left: mainSecondFrameView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 40)
        
        _ = rightArrowButton.anchor(ScrollView.bottomAnchor, left: nil, bottom: nil, right: mainSecondFrameView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 40)
        
        
        // PAGING CONTROL VIEW SHOWS WHICH PAGE YOU ARE ON
        _ = statusViewControl.anchor(ScrollView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 20)
        statusViewControl.centerXAnchor.constraint(equalTo: mainSecondFrameView.centerXAnchor).isActive = true
        
        
        // STREET NAME CORRESPONDING TO CURRENT LOCATION
        //_ = addressLabel.anchor(nil, left: nil, bottom: mapView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 50)
        //addressLabel.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        
        
        // TOTAL TRAVEL DISTANCE LABEL
        _ = totalDistanceToDestination.anchor(nil, left: mainSecondFrameView.leftAnchor, bottom: mainSecondFrameView.bottomAnchor, right: startButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 40, rightConstant: 0, widthConstant: (view.frame.width/2)-25, heightConstant: 40)
        
        
        
        // TOTAL TIME LABEL
        _ = totalDurationToDestination.anchor(nil, left: startButton.rightAnchor, bottom: mainSecondFrameView.bottomAnchor, right: mainSecondFrameView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 40, rightConstant: 0, widthConstant: view.frame.width/2-25, heightConstant: 40)
        
        
        
        // Map view Button
        
        _ = mapButtonContainer.anchor(navItemBarView.topAnchor, left: navItemBarView.leftAnchor, bottom: navItemBarView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/3, heightConstant: 50)
        
        _ = mapButton.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 45, heightConstant: 45)
        mapButton.centerXAnchor.constraint(equalTo: mapButtonContainer.centerXAnchor).isActive = true
        mapButton.centerYAnchor.constraint(equalTo: mapButtonContainer.centerYAnchor).isActive = true
        
        
        _ = rideStatusButtonContainer.anchor(navItemBarView.topAnchor, left: nil, bottom: navItemBarView.bottomAnchor, right: navItemBarView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/3, heightConstant: 50)
        
        
        _ = rideStatusButton.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 45, heightConstant: 45)
        rideStatusButton.centerXAnchor.constraint(equalTo: rideStatusButtonContainer.centerXAnchor).isActive = true
        rideStatusButton.centerYAnchor.constraint(equalTo: rideStatusButtonContainer.centerYAnchor).isActive = true
        
        
        
        // TRIGER BUTTON TO START JOURNEY
        
        
        _ = startButton.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        startButton.centerXAnchor.constraint(equalTo: navItemBarView.centerXAnchor).isActive = true
        startButton.centerYAnchor.constraint(equalTo: navItemBarView.centerYAnchor).isActive = true
        
        
        _ = navItemBarView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 50)
        // ********************************************************************************************************************************************************//
        
        // MAP STYLE FUNC
        mapStyle()
        
        // BASIC CONFIGURATION OF THE SCROLL VIEW SUCH THAT NUMBER OF PAGES AND ETC...
        featureViewController()
        
        // ALL THE LABELS AND MAP IN THE SCROLL VIEW
        loadFeatures()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.isMyLocationEnabled = true
        guard let target = mapView.myLocation?.coordinate else { return }
        
        let camera = GMSCameraPosition(target: target, zoom: 12, bearing: 0, viewingAngle: 0)
        mapView.animate(to: camera)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - POI Search Function
//*************************************************************************************************************************************//

extension RiderStatusViewController {
    
    
    func setStartAndEndPin(destination: CLLocationCoordinate2D) {
        // starting point
        /******************************************************************************************************/
        
        let startPointMapPin = GMSMarker()
        
        let startMarkerImage = UIImage(named: "startPin")
        //!.withRenderingMode(.alwaysTemplate)
        
        //creating a marker view
        let startMarkerView = UIImageView(image: startMarkerImage)
        
        startPointMapPin.iconView = startMarkerView
        
        startPointMapPin.layer.cornerRadius = 25
        startPointMapPin.position = (mapView.myLocation?.coordinate)!
        startPointMapPin.title = "Start"
        startPointMapPin.opacity = 1
        startPointMapPin.infoWindowAnchor.y = 1
        startPointMapPin.map = mapView
        startPointMapPin.appearAnimation = GMSMarkerAnimation.pop
        startPointMapPin.isTappable = true
        
        /******************************************************************************************************/
        
        
        
        // destination
        /******************************************************************************************************/
        let endPointMapPin = GMSMarker()
        
        
        let endMarkerImage = UIImage(named: "endPin")
        let endMarkerView = UIImageView(image: endMarkerImage)
        
        
        endPointMapPin.iconView = endMarkerView
        endPointMapPin.layer.cornerRadius = 25
        endPointMapPin.position = destination
        endPointMapPin.title = "end"
        endPointMapPin.opacity = 1
        endPointMapPin.infoWindowAnchor.y = 1
        endPointMapPin.map = mapView
        endPointMapPin.appearAnimation = GMSMarkerAnimation.pop
        endPointMapPin.isTappable = true
        
        /******************************************************************************************************/
        
    }
    
    
    @objc func POIForPlaces(sender: UIButton) {
        print("I am here~~~")
        var typeOfPlace = String()
        
        var markerImage = UIImage()
        
        
        switch sender.tag {
        case 0:
            typeOfPlace = "cafe"
            markerImage = UIImage(named: "cafe")!
        case 1:
            typeOfPlace = "restaurant"
            markerImage = UIImage(named: "restaurant")!
        default:
            break
        }
        let markerView = UIImageView(image: markerImage)
        print(typeOfPlace)
        
        
        guard let lat = mapView.myLocation?.coordinate.latitude else {return}
        guard let long = mapView.myLocation?.coordinate.longitude else {return}
        
        
        var arrayOfLocations = [[Double(),Double()]]
        var arrayOfNames = [String()]
        var arrayOfAddress = [String()]
        var arrayOfRating = [Double()]
        
        var name = String()
        
        var latitude = CLLocationDegrees()
        var longitude = CLLocationDegrees()

        print("What is going on?")
        let jsonURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&maxprice=3&radius=3200&opennow&type=\(typeOfPlace)&key=\(Config.GOOGLE_API_KEY)"
        //"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=3200&opennow&maxprice=3&type=\(typeOfPlace)&key=\(Config.GOOGLE_API_KEY)"
        
        print(jsonURLString)
        
        
        guard let urlString = URL(string: jsonURLString) else {
            print("Error: Cannot create URL")
            return
        }
        
        
        //markerView.tintColor = UIColor.DTIBlue()
        
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
                            
                            if let arrayForRating = (arrayPlaces[i] as! NSDictionary).object(forKey: "rating") as? NSNumber {
                                arrayOfRating.append(Double(truncating: arrayForRating).rounded(toPlaces: 1))
                            } else {
                                arrayOfRating.append(0.0)
                            }
                            
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
                                nearbyMarker.tracksViewChanges = true
                                nearbyMarker.title = name
                                
                                
                                nearbyMarker.snippet = "Rating = \(arrayOfRating[i]) \(self.ratingSystem(rating: arrayOfRating[i]))\n Address = \(arrayOfAddress[i])"
                                
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
    
    func ratingSystem(rating: Double) -> String {
        
        var stars = ""
        
        if rating >= 1.0 && rating < 2.0 {
            stars = "*"
        } else if rating >= 2.0 && rating < 3.0 {
            stars = "**"
        } else if rating >= 3.0 && rating < 4.0{
            stars = "***"
        } else if rating >= 4.0 && rating < 5.0{
            stars = "****"
        } else if rating == 5.0 {
            stars = "*****"
        }
        return stars
    }
    
}



//*************************************************************************************************************************************//






// MARK: - BLUETOOTH HANDLING PROTOCOL TO FIND AND CONNECT TO BLUETOOTH DEVICES
//*************************************************************************************************************************************//

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
            //keepScanning = true
            message = "BLUETOOTH LE IS TURNED ON AND READY FOR THE COMMUNICATION"
            print(message)
            
            //_ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            
            
            /*
             let HeartRate          = "0x180D"
             let DeviceInformation  = "0x180A"
             let heartRateServiceUUID = CBUUID(string: HeartRate)
             let deviceInfoServiceUUID = CBUUID(string: DeviceInformation)
             let services = [heartRateServiceUUID,deviceInfoServiceUUID]
             */
            
            let serviceUUID: [AnyObject] = [CBUUID(string: Device.HEART_RATE_DEVICE)]
            let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUID as! [CBUUID])
            
            if lastPeripherals.count > 0 {
                let device = lastPeripherals.last! as CBPeripheral
                deviceConnectTo = device
                centralManager.connect(deviceConnectTo!, options: nil)
                
            } else {
                centralManager.scanForPeripherals(withServices: serviceUUID as? [CBUUID], options: nil)
                
            }
            //CBUUID(string: enumName.rawValue)
            
            // Initiate Scan for Peripherals
            //Option 1: Scan for all devices
            //ServiceUUID.uuids(enumNames: [.HeartRate])
            //self.centralManager.scanForPeripherals(withServices: , options: nil)
            
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
    /*
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
    
    */
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("CENTRAL MANGER DID DISCOVERED PERIPHERAL: \(peripheral), \(advertisementData), \(RSSI)")
        
        if let name = peripheral.name {
            if hrSensorName != nil && name != self.hrSensorName{
                return
            }
            
            hrSensorName = name
            print(hrSensorName as Any)
            
        }
        //To be safe we need to use guard let
        
        if let advertisedServiceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]{
            
            print("SERVICES ARE SUCH THAT: \(advertisedServiceUUIDs)")
        }
        
        let deviceName = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        print("PERIPHERAL NAME: \(String(describing: deviceName))")
        print("PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
        
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("WE FOUND THE DEVICE THAT WE ARE LOOKING FOR!!!")
            // Stop scanning
            
            print("PERIPHERAL NAME: \(String(describing: localName))")
            
            self.centralManager.stopScan()
            //keepScanning = false
            //self.centralManager.stopScan()
            
            // Save a refence to the sensor tag
            self.deviceConnectTo = peripheral
            // set the delegate property to point to the view controller
            self.deviceConnectTo?.delegate = self
            
            print("REQUEST A CONNECTION TO THE PERIPHERAL")
            centralManager.connect(self.deviceConnectTo!, options: nil)
            
        } else {
            
            print("Can't not unwrap advertisementData[CBAdvertisementDataLocalNameKey]")
        }
        /*
         if deviceName?.contains(WahooHeartMonitorSensor) == true {
         print("We found device and connecting now!!")
         // Stop scanning
         
         self.centralManager.stopScan()
         //keepScanning = false
         //self.centralManager.stopScan()
         
         // Save a refence to the sensor tag
         self.deviceConnectTo = peripheral
         // set the delegate property to point to the view controller
         self.deviceConnectTo?.delegate = self
         
         print("Request a conncetion to the peripheral")
         centralManager.connect(self.deviceConnectTo!, options: nil)
         }
         */
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("WE ARE NOW SUCCESSFULLY CONNECTED TO THE DEVICE")
        
        
        // -NOTE: we pass nil to request ALL services be discovered.
        // If there was a subset of services we were interested in, we could pass the UUIDs here.
        // Doing so saves battery life and saves time.
        
        peripheral.discoverServices(nil)
        print("---- PERIPHERAL STATE IS \(peripheral.state)")
    }
    
    // When bluetooth connection is failed!!
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("CONNECTION TO HEART RATE MONITOR IS FAILED!", error.debugDescription)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Core Bluetooth creates an array of CBService objects
        // one for each service that is discovered on the peripheral
        
        if error != nil {
            print("!!! --- ERROR IN DID DISCOVER SERVICES: \(String(describing: error?.localizedDescription))")
            
        }
        
        if let services = peripheral.services {
            
            for service in services {
                
                peripheral.discoverCharacteristics(nil, for: service)
                /*
                 switch service.uuid {
                 case ServiceUUID.uuid(enumName: .HeartRate):
                 print("Discovered heart rate service!")
                 peripheral.discoverCharacteristics(HeartRateCharacteristicUUID.uuids(enumNames: [.HeartRateMeasurement, .BodySensorLocation]), for: service)
                 case ServiceUUID.uuid(enumName: .DeviceInformation):
                 print("Discovered device information service!")
                 
                 default:
                 print("unrecognized service: \(service.uuid)")
                 }
                 */
                
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
            print("ERROR IN DID DISCOVER CHARACTERISTICS: \(String(describing: error?.localizedDescription))")
            return
            
        }
        else {
            
            if service.uuid == CBUUID(string: Device.HEART_RATE_DEVICE){
                for characteristic in service.characteristics! as [CBCharacteristic]{
                    switch characteristic.uuid.uuidString {
                    case Characteristic.HEART_RATE_MEASUREMENT:
                        // Set notification on heart rate measurement
                        print("Found a Heart Rate Measurement Characteristic")
                        peripheral.setNotifyValue(true, for: characteristic)
                        
                    case Characteristic.BODY_SENSOR_LOCATION:
                        // Read body sensor location
                        print("Found a Body Sensor Location Characteristic")
                        peripheral.readValue(for: characteristic)
                        
                    case Characteristic.HRM_MANUFACTURER_NAME:
                        //Read body sensor location
                        print("Found a HRM manufacturer name Characteristic")
                        peripheral.readValue(for: characteristic)
                        
                    case Characteristic.HEART_RATE_CONTROL_POINT:
                        print("Found a Heart Rate Control Point Characteristic")
                        var rawArray:[UInt8] = [0x01]
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                        
                    default:
                        print("default")
                    }
                    
                }
                
            }
            
            
            /*
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
             */
        }
        
    }
    

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("---- didUpdateValueForCharacteristic")
        
        if error != nil {
            print("Error on updating value for the characteristics: \(String(describing: error?.localizedDescription))" )
            return
        } else {
            switch characteristic.uuid.uuidString {
            case "2A37":
                update(heartRateData: characteristic.value!)
            default:
                print("--- something other than 2A37 uuid characteristic")
            }
            
        }
        
    }
    
    func update(heartRateData:Data){
        print("--- UPDATING ..")
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm{
            print(actualBpm)
            self.heartRate.text = "\(actualBpm) bpm"
            if heartRateTag == 1 {
                heartRateLabel.text = "\(actualBpm) bpm"
                currentHeartRate = Int(actualBpm)
                //heartRateList.append(Int(actualBpm))
            }
            
            
        }else {
            print(bpm!)
        }
    }
    
    
    
    /*
     
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
     */
    
}

//*************************************************************************************************************************************//




// MARK - DIRECTION HEADING HANDLING EXTENSION FUNCTION
//*************************************************************************************************************************************//
extension RiderStatusViewController{
    
    
    func RadiansToDegrees(radians: Double) -> Double {
        return (radians * 190.0/Double.pi)
    }
    
    func DegreesToRadians(degrees: Double) -> Double {
        
        return (degrees * Double.pi/180.0)
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
            radianBearing += 2*Double.pi
        }
        
        return radianBearing
    }
    
}
//*************************************************************************************************************************************//





// MARK - WEATHER STATUS HELPER ENUM
//*************************************************************************************************************************************//
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
//*************************************************************************************************************************************//



// MARK - SEGUE HANDLER

//*************************************************************************************************************************************//

extension RiderStatusViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case stopAndSave = "saveViewSegue"
        case history = "historyViewSegue"
        case setting = "MenuToSettingViewSegue"
        case termsAndPrivacy = "MenuToTermsViewSegue"
        case bikeTypes = "MenuToBikeTypesViewSegue"
        case myStats = "MenuToMyStatsViewSegue"
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .stopAndSave:
            let destination = segue.destination as! EbikeDetailsViewController
            destination.ride = ride
            
        case .history:
            _ = segue.destination as! UINavigationController
            
        case .setting:
            _ = segue.destination as! SettingViewController
            
        case .termsAndPrivacy:
            _ = segue.destination as! TermsAndPrivacyViewController
            
        case .bikeTypes:
            _ = segue.destination as! BikeTypesViewController
            
        case .myStats:
            _ = segue.destination as! MyStatsViewController
            
        }
    }
}
//*************************************************************************************************************************************//

