//
//  ViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 5/12/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//


import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import SwiftyJSON
import Alamofire



enum Location {
    case startLocation
    case destinationLocation
}


class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate{
    

    
    //MARK: Store the Route of the trip
    
    let routeStore: RouteStore = RouteStore.sharedInstance
    var isTracking: Bool = false
    
    
    
    //MARK: Map container to show the google map
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var currentSpeed: UILabel!
    
    @IBOutlet weak var currentLatitude: UILabel!
    
    @IBOutlet weak var currentLogitude: UILabel!
    
    @IBOutlet weak var currentAddress: UILabel!
    
    
    @IBOutlet weak var startLocationAddress: UITextField!
    
    @IBOutlet weak var endLocationAddress: UITextField!
    //@IBOutlet weak var locationAddress: UILabel!
    


    
    //MARK: Fetching nearby objects
    //let dataProvider = GMSPlace()
    let searchRadius: Double = 1000

    
    /**
     action for search location by address
     
     - sender: button search location
     */
    
    var resizeImage = ResizingImage()
    
    //MARK: GOOGLE AUTO COMPLETE DELEGATE
    var street_number: String = ""
    var route: String = ""
    var neighborhood: String = ""
    var locality: String = ""
    var administrative_area_level_1: String = ""
    var country: String = ""
    var postal_code: String = ""
    var postal_code_suffix: String = ""
    

    
    // MARK: This is for the destination routes
    var destination: Destination?
    //var locationCase: LocationCase
    
    
    
    let locationManager = CLLocationManager()
    
    //MARK: GOOGLE SEARCH BAR
    var searchController: UISearchController?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    var searchBar: UISearchBar?
    var tableDataSource: GMSAutocompleteTableDataSource?
    let addressFilter = GMSAutocompleteFilter()
    //var searchDisplayController: UISearchControllerDelegate?
    
    
    
    var zoomLevel: Float = 15.0
    
    //MARK: GOOGLE MAP USER CURRENT PLACE TO PIN
    var currentLocation = CLLocation?.self
    var placeClient = GMSPlacesClient!.self
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace = GMSPlace?.self
    //let geocoder = GMSGeocoder()
    var addressTitle :String = " "
    var addressSnippet :String = " "
    
    

    
    
    //MARK: This part is for the autocomplete for the search
    //var resultArray = [String]()
    //var searchResultController: SearchResultsController!
    //var gmsFetcher: GMSAutocompleteFetcher!
    
    
    
    //MARK: GOOGLE MAP SHOW ME THE DIRECTION
    
    var locationSelected = Location.startLocation
    
    
    var locStart = CLLocation()
    var locEnd = CLLocation()
    
    
    
    //MARK: Annotation when you pin on the GOOGLE MAP
    let annotation = GMSMapPoint()
    
    
    let navController = UINavigationController()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        
        
        //view.addSubview(navBar)
        

        
        //super.viewDidAppear(true)
        // Do any additional setup after loading the view, typically from a nib.
        
        //mapView.isMyLocationEnabled = true
        
        //placeClient = GMSPlacesClient.shared()
        
        navigationItem.title = "Map"
        
        setupNavBarButtons()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.activityType = .otherNavigation
        
        
        
        mapView.delegate = self
        
        viewWillLayoutSubviews()
        
        
        mapView.mapType = .normal
        //mapView.animate(with: GMSCameraUpdate)
        
        mapView.isTrafficEnabled = true
        mapView.isBuildingsEnabled = true
        mapView.autoresizesSubviews = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.scrollGestures = true
        mapView.settings.tiltGestures = true
        mapView.setMinZoom(10, maxZoom: 18)
        mapView.accessibilityElementsHidden = false
        mapView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        
        do {
            //Set the map style by passing a valid JSON String.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "geojson") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
            
        } catch {
            
            NSLog("One or more of the map style failed to load. \(error)")
        }
        
        /*
        do {
            //Set the map style by passing a valid JSON String.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
            
        } catch {
            
            NSLog("One or more of the map style failed to load. \(error)")
        }
        self.view = mapView
         */
        
        //prefersStatusBarHidden
        
        //resultsViewController = GMSAutocompleteResultsViewController()
        //resultsViewController?.delegate = self
        
        //addressFilter.type = .address
        //resultsViewController?.autocompleteFilter = addressFilter
        //present(resultsViewController!, animated: true, completion: nil)
        // TODO: We need to find the way out connecting the resultsViewController to be the searchBar
        
        
        //searchController = UISearchController(searchResultsController: resultsViewController)
        //searchController?.searchResultsUpdater = resultsViewController
        
        
        //let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
        
        //subView.addSubview((searchController?.searchBar)!)
        //view.addSubview(subView)
        //searchController?.searchBar.sizeToFit()
        //navigationItem.titleView = searchController?.searchBar
        
        
        
        
        //searchController?.hidesNavigationBarDuringPresentation = false
        //definesPresentationContext = true
        
        
        //searchDisplayController = UISearchController(searchResultsController: searchBar!)
        
        
        
        //setSearchBar()
        
        //placeClient = GMSPlacesClient.shared()
        //let myCurrentLocation = mapView.myLocation
        
        //let camera = GMSCameraPosition.camera(withLatitude: 33.667231, longitude: -117.750568, zoom: 20.0)
        //let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //view = mapView
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override var prefersStatusBarHidden: Bool {
    
        return true
    }
    
    //MARK: Function to create a marker or pin on the GOOGLE MAP
    func createMarker(latitude: CLLocationDegrees, logitude: CLLocationDegrees) {
        
        DispatchQueue.main.async {
            
            let position = CLLocationCoordinate2D(latitude: latitude, longitude: logitude)
            let marker = GMSMarker(position: position)
            
            //let iconColor = UIColor(red: 0.02, green: 0.16, blue: 0.47, alpha: 1)
            
            marker.icon = GMSMarker.markerImage(with: UIColor.DTIBlue())
            marker.opacity = 0.8
            marker.isFlat = true
            marker.appearAnimation = GMSMarkerAnimation.pop
            //marker.title = titleMarker
            marker.tracksInfoWindowChanges = true
            
            //marker.title = place.lines?[0]
            //marker.snippet = place.lines?[1]
            marker.map = self.mapView
        }
    }
    

    
    
    /**
     action for search location by address
     
     - lon: Longitude location
     - latitude: latitude location
     - title: address of location
     
     */
    
    /*
    func locateWithLongitude(_ longitude: Double, latitude: Double, title: String) {
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
            
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
            self.mapView.camera = camera
            
            
            let marker = GMSMarker(position: position)
            marker.title = "Address : \(title)"
            marker.map = self.mapView
        }
        
    }*/
    
    
    

    
    /**
     
     SearchBar when text change
     - searchBar: SearchBar Description
     - searchText: SearchText Description
     
     */
    
    /*
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let placeClient = GMSPlacesClient()
        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil, callback: {(results, error) -> Void in
            
            
            if results == nil {
                
                return
            }
            
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    self.resultArray.append(result.attributedFullText.string)
                }
            }
            
            self.searchResultController.reloadDataWithArray(self.resultArray)
            self.resultArray.removeAll()
            self.gmsFetcher?.sourceTextHasChanged(searchText)
        })
        
    }
    
    
    */
    
    override func viewWillLayoutSubviews() {
        mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 15, 0, self.bottomLayoutGuide.length + 3, 0)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .restricted:
            
            print("Location access was restricted.")
            
        case .denied:
            
            print("User denied access to locaiton.")
            mapView.isHidden = false
            
        case .notDetermined:
            
            print("Location status not determined.")
            
        case .authorizedAlways: fallthrough
            
        case .authorizedWhenInUse:
            
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true

        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first{
            print("Location: \(location)")
            
            //locationManager.startUpdatingLocation()
            //let locationTujuan = CLLocation(latitude: 37.784023631590777, longitude: -122.40486681461333)
            self.currentSpeed.text = "Current Speed is \(location.speed) mpb"
            self.currentLatitude.text = "Latitude is \(location.coordinate.latitude)"
            self.currentLogitude.text = "Longitude is \(location.coordinate.longitude)"

            let camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
                
            } else {
                
                mapView.animate(to: camera)
            }
            
            
            
            createMarker(latitude: location.coordinate.latitude, logitude: location.coordinate.longitude)
            
            //drawPath(startLocation: location, endLocation: locationTujuan)
            
            //MARK: Only main thread will perform the UI icon(Google Map Marker) asyncronized way(by itself)
            mapView.animate(to: camera)
            reverseGeocodeCoordinate(coordinate: location.coordinate)
            
            //locationManager.stopUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location" + error.localizedDescription)
    }
    

    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(coordinate: position.target)
        self.mapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        //currentAddress.lock()
        
        self.mapView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Coordinate \(coordinate)") //When you tapped coordinate print it out to console
        mapView.clear()
        reverseGeocodeCoordinate(coordinate: coordinate)
        
        //TODO: - if there are stores or any other places that are official then show the name and address
    }
    
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        //When you LongPress the Map
        //mapView.clear()
        reverseGeocodeCoordinate(coordinate: coordinate)
        createMarker(latitude: coordinate.latitude, logitude: coordinate.longitude)
        
        //mapView.animate(toLocation: coordinate)
    }
    
    func didTapLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        //let nameOfPlace: String
        currentLatitude.text = "Latitude is \(coordinate.latitude)"
        currentLogitude.text = "Longitude is \(coordinate.longitude)"
    
        geocoder.reverseGeocodeCoordinate(coordinate){(placemark, error) in
            
            if error != nil {
                
                print("There was an Error")
                return
            }
                
            else {
                if ((placemark?.results()?.count)! > 0) {
                    
                    if let place = placemark?.firstResult() {
                        
                        if place.country != nil {
                            self.currentAddress.text = " \(place.lines![0]) \n \(place.lines![1]) \(place.country!)"
                            UIView.animate(withDuration: 0.25, animations: {
                                self.view.layoutIfNeeded()
                            })
                        } else {
                            print("There is no thorughfare!")
                        }
                    }
                }
                else {
                    print("Error")
                
                }
            }
        }
    
    
    
    }
    /*
    func setSearchBar() {
        searchBar?.tintColor = UIColor .black
    }
    */
    
    
    
    @IBAction func openStartLocation(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        
        locationSelected = .startLocation
        
        
        UISearchBar.appearance().setTextColor(color: UIColor.DTIBlue())
        
        self.locationManager.stopUpdatingLocation()
        self.present(autocompleteController, animated: true, completion: nil)
        
        
    }
    
    
    
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.DTIBlue())
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func showDirection(_ sender: UIButton) {
        self.drawPath(startLocation: locStart, endLocation: locEnd)
    }
    
    
    @IBAction func mapModeSwitch(_ sender: UIButton) {
        print("First")
        
        if mapView.mapType == .satellite {
            mapView.mapType = .normal
        } else {
            mapView.mapType = . satellite
        }
        print("Second")
    }
    
    

    
    
    func setupNavBarButtons() {
        
            
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 50))
            
        
        
        let settingBarImg: UIImage = resizeImage.resizeImageWith(image: UIImage(named: "navbar")!,newSize: CGSize(width: 25, height: 25))
        
        
        
        
        
        let navItem = UINavigationItem(title: "Map")
        let settingBar = UIBarButtonItem(image: settingBarImg, style: .plain, target: self, action: #selector(handleNav))
        
        
        
        
        navItem.leftBarButtonItem = settingBar
        navBar.setItems([navItem], animated: true)
        
        self.view.addSubview(navBar)
        
        
        _ = navBar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        
        //navBar.setItems([navItem], animated: false)
        
        //navBar.navigationItem.setLeftBarButtonItems([settingBar], animated: true)
        
    
    }
    
    lazy var settingLauncher: SettingLauncher = {
        let launcher = SettingLauncher()
        launcher.mapViewController = self
        return launcher
        
    }()
    
    func handleNav() {
        
        //show setting menu
        //settingLauncher.mapViewController = self
        settingLauncher.showSetting()
        

    }

    func showControllerForSetting(setting: Settings) {
        let settingViewController = UIViewController()
        
        settingViewController.view.backgroundColor = UIColor.white
        settingViewController.navigationItem.title = setting.name.rawValue
        
        navController.navigationController?.navigationBar.tintColor = UIColor.DTIBlue()
        navController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.DTIBlue()]
        navController.navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    private func setMapCam() {
    
        CATransaction.begin()
        CATransition.setValue(1, forKey: kCATransactionAnimationDuration)
        //mapView?.animate(to: GMSCameraPosition.camera(withTarget: , zoom: 15))
        CATransaction.commit()
        /*
        let iconColor = UIColor(red: 0.02, green: 0.16, blue: 0.47, alpha: 1)
        let mapMarker = GMSMarker(position: position)
        mapMarker.icon = GMSMarker.markerImage(with: iconColor)
        mapMarker.opacity = 0.8
        mapMarker.isFlat = true
        mapMarker.tracksInfoWindowChanges = true
        mapMarker.map = mapView
         */
    
    }
}



extension MapViewController: GMSAutocompleteViewControllerDelegate {

    
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        

        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0, bearing: 20, viewingAngle: 5)
        
        if locationSelected == .startLocation {
            startLocationAddress.text = "\(place.name)"
            locStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(latitude: place.coordinate.latitude, logitude: place.coordinate.longitude)
        } else {
            endLocationAddress.text = "\(place.name)"
            locEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(latitude: place.coordinate.latitude, logitude: place.coordinate.longitude)
            
        }
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        self.mapView.camera = camera
        dismiss(animated: true, completion: nil)
    }

        
        
        // TODO: Add code to get address components from the selected place
        
        /*
        if let addressLines = place.addressComponents {
        
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypeStreetNumber:
                    street_number = field.name
                case kGMSPlaceTypeRoute:
                    route = field.name
                case kGMSPlaceTypeNeighborhood:
                    neighborhood = field.name
                case kGMSPlaceTypeLocality:
                    locality = field.name
                case kGMSPlaceTypeAdministrativeAreaLevel1:
                    administrative_area_level_1 = field.name
                case kGMSPlaceTypeCountry:
                    country = field.name
                case kGMSPlaceTypePostalCode:
                    postal_code = field.name
                case kGMSPlaceTypePostalCodeSuffix:
                    postal_code_suffix = field.name
                    
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        */
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //TODO: Error Handling
        print("Erro Auto Complete", error.localizedDescription)
    }
    

    // User Canceled the operation of search
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    
    
    // Turn the network activity indicator on and off again in the navigation bar
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}

extension MapViewController {

    @IBAction func pickPlace(_ sender: UIButton) {
        /*
        let center = CLLocationCoordinate2D(latitude: 37.788204, longitude: -122.411937)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        */
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePicker(config: config)
        //present(placePicker, animated: true, completion: nil)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Wrong Place \(error.localizedDescription)")
                return
            }
            if let place = place {
                //self.createMarker(titleMarker: "\(place.name)", latitude: center.latitude, logitude: center.longitude)
                self.currentAddress.text = "\(place.name) \n \(place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n"))"
                self.currentLatitude.text = "\(place.coordinate.latitude)"
                self.currentLogitude.text = "\(place.coordinate.longitude)"
            } else {
                self.currentAddress.text = "No Such Place Selected"
            }
            
        })
        
        
        //present(placePicker, animated: true, completion: nil)
        
    }

}

//MARK: - This is function for create direction path, from start location to destination
extension MapViewController {
    


    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)&destination=\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)&sensor=false&mode=bicycling")!
        
        
        let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let json: [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] {
                        
                        let routes = json["routes"] as? [Any]
                        let overview_polyline = routes?[0] as? [String:Any]
                        let polyString = overview_polyline?["points"] as? String
                        
                        let path = GMSPath(fromEncodedPath: (polyString)!)
                        let polyline = GMSPolyline(path: path)
                        polyline.geodesic = true
                        polyline.strokeColor = UIColor.DTIRed()
                        polyline.strokeWidth = 4.0
                        polyline.map = self.mapView
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            
            }
            
        })
        task.resume()
    }
    
        
        //let origin = "\(startLocation.coordinate.latitude), \(startLocation.coordinate.longitude)"
        
        //MARK: - This will be the pin point where you add second destinations and so on
        //let middlePoint = middleLocation.coordinate
        
        //let destination = "\(endLocation.coordinate.latitude), \(endLocation.coordinate.longitude)"
        
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        /*
         MODE:
            - bicycling
            - driving
            - walking
            etc...
         */
        /*
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.DTIRed()
                polyline.map = self.mapView
            }
            
        }*/
        
}

public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}



