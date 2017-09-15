//
//  EbikeDetailsViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 7/19/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class EbikeDetailsViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    
    // ScrollView for the graph
    
    lazy var graphView: ScrollableGraphView = {
        var view = ScrollableGraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var label = UILabel()
    
    var stringURL = String()
    
    
    
    // Data
    
    lazy var elevationData = [Double]()
    lazy var elevationTempLabels = [CLLocation]()
    lazy var elevationLabels = [String]()
    
    
    var locationsOfElevationSamples = [CLLocation]()
    var distanceRelateToElevation = [Double]()
    
    var ride: Ride!
    
    fileprivate let path = GMSMutablePath()
    
    
    let nameOfTheRoute: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.backgroundColor = UIColor.clear
        //label.numberOfLines = 2
        
        return label
    }()
    
    let mapView: GMSMapView = {
        
        let view = GMSMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.mapType = .normal
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 5
        view.settings.zoomGestures = true
        view.settings.rotateGestures = true
        view.settings.scrollGestures = true
        view.setMinZoom(5, maxZoom: 18)
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return view
    }()
    
    
    var graphLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        label.text = "Elevation"
        
        return label
    }()
    
    let x_axisLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 4)
        
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        //label.layer.borderWidth = 0.5
        //label.layer.borderColor = UIColor.DTIRed().cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    var distanceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        //label.layer.borderWidth = 0.5
        //label.layer.borderColor = UIColor.DTIRed().cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        //label.layer.borderWidth = 0.5
        //label.layer.borderColor = UIColor.DTIRed().cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    var averageSpeedLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        //label.layer.borderWidth = 0.5
        //label.layer.borderColor = UIColor.DTIRed().cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    var heartRateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        //label.layer.borderWidth = 0.5
        //label.layer.borderColor = UIColor.DTIRed().cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    var addressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        //label.layer.borderWidth = 0.5
        //label.layer.borderColor = UIColor.DTIRed().cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        
        return label
    }()
    
    
    
    lazy var backButton: UIButtonY = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("<Back", for: .normal)
        button.tintColor = UIColor.white
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.shadowColor = UIColor.DTIRed()
        button.shadowOffset = CGSize(width: 1, height: -1)
        
        button.addTarget(self, action: #selector(backToPrevious), for: .touchUpInside)
        
        return button
    }()
    
    func backToPrevious() {
        self.performSegue(withIdentifier: "rideStatusViewSegue", sender: backButton)
        
    }
    
    
    func DrawPath(){
        
        
        var bounds = GMSCoordinateBounds()
        
        guard let locations = ride.locations,
            locations.count > 0
            else {
                let alert = UIAlertController(title: "Error", message: "Sorry, this run has no locations saved", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }
        
        let locationPoints = ride.locations?.array as! [Locations]
        
        
        //print(locations.array as! [Locations])
        
        for i in 0..<locationPoints.count{
            let lat = locationPoints[i].latitude
            let long = locationPoints[i].longitude
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            if i == 1{
                
                let startPointMapPin = GMSMarker()
                
                let markerImage = UIImage(named: "startPin")
                //!.withRenderingMode(.alwaysTemplate)
                
                //creating a marker view
                let markerView = UIImageView(image: markerImage)
         
                startPointMapPin.iconView = markerView
                
                startPointMapPin.layer.cornerRadius = 25
                startPointMapPin.position = position
                startPointMapPin.title = "Start"
                startPointMapPin.opacity = 1
                startPointMapPin.infoWindowAnchor.y = 1
                startPointMapPin.map = mapView
                startPointMapPin.appearAnimation = GMSMarkerAnimation.pop
                startPointMapPin.isTappable = true
                
            } else if i == locationPoints.count - 2{
                
                let endPointMapPin = GMSMarker()
                
                
                let markerImage = UIImage(named: "endPin")
                //!.withRenderingMode(.alwaysTemplate)
                
                //creating a marker view
                let markerView = UIImageView(image: markerImage)
                
                
                endPointMapPin.iconView = markerView
                endPointMapPin.layer.cornerRadius = 25
                endPointMapPin.position = position
                endPointMapPin.title = "end"
                endPointMapPin.opacity = 1
                endPointMapPin.infoWindowAnchor.y = 1
                endPointMapPin.map = mapView
                endPointMapPin.appearAnimation = GMSMarkerAnimation.pop
                endPointMapPin.isTappable = true
            }
            
            path.add(position)
            bounds = bounds.includingPath(path)
            
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 4)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.geodesic = true
        polyline.strokeColor = UIColor(red:0.14, green:0.17, blue:0.17, alpha:1.00)
        polyline.map = self.mapView
        
        
        mapView.animate(with: update)
        
    }
    
    
    
    
    
    
    
    
    // functions for the graph scrollView
    
    fileprivate func createDarkGraph(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame)
        graphView.layer.cornerRadius = 5
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        graphView.lineWidth = 2
        graphView.lineColor = UIColor.colorFromHex(hexString: "#777777")
        graphView.lineStyle = ScrollableGraphViewLineStyle.straight
        
        graphView.shouldFill = true
        graphView.fillType = ScrollableGraphViewFillType.gradient
        graphView.fillColor = UIColor(red:0.99, green:0.42, blue:0.80, alpha:1.0)
        
        //UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientType = ScrollableGraphViewGradientType.radial
        graphView.fillGradientStartColor = UIColor(red:0.99, green:0.42, blue:0.80, alpha:1.0)
        //UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientEndColor = UIColor(red:0.99, green:0.42, blue:0.80, alpha:1.0)
        //UIColor.colorFromHex(hexString: "#444444")
        
        graphView.dataPointSpacing = 25
        graphView.dataPointSize = 4
        graphView.dataPointFillColor = UIColor(red:0.99, green:0.10, blue:0.56, alpha:1.00)
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphView.referenceLineLabelColor = UIColor.white
        graphView.numberOfIntermediateReferenceLines = 5
        graphView.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = false
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        graphView.animationDuration = 0.5
        graphView.rangeMax = 100
        graphView.shouldRangeAlwaysStartAtZero = true
        graphView.showsVerticalScrollIndicator = true
        graphView.showsHorizontalScrollIndicator = true
        //graphView.shouldAutomaticallyDetectRange = true
        
        graphView.shouldShowLabels = true
        
        return graphView
    }
    
    
    
    
    // Adding and updating the graph switching label in the top right corner of the screen.
    
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        label.text = text
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 8)
        
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        
        return label
    }
    
    
    func getElevationInfo() {
        
        //let basedURL = "https://maps.googleapis.com/maps/api/elevation/json?path=37.33165083,-122.03029752%7C37.3304353,-122.02993796&samples=3&key=AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA"
        
        
        /*
         let request = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/elevation/json?path=37.33165083%2C-122.03029752%7C37.3304353%2C-122.02993796&samples=3&key=AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA")! as URL,
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0)
         */
        
        
        
        //var trackingIndexNumber = 0
        //var indexIntervalForElevationDevision = 0
        /*
         if locationPoints.count%2 == 0 {
         indexIntervalForElevationDevision = locationPoints.count/4
         }
         if locationPoints.count%3 == 0 {
         indexIntervalForElevationDevision = locationPoints.count/3
         }
         
         for i in 0..<locationPoints.count {
         locationAltitude.append(locationPoints[i].elevation)
         
         
         if i == trackingIndexNumber {
         if i == locationPoints.count - 1{
         stringURL += "\(locationPoints[i].latitude),\(locationPoints[i].longitude)"
         break
         } else {
         stringURL += "\(locationPoints[i].latitude),\(locationPoints[i].longitude)%7C"
         trackingIndexNumber += indexIntervalForElevationDevision
         }
         }
         }
         */
        
        
        
        guard let locations = ride.locations, locations.count > 0 else { return }
        
        let locationPoints = locations.array as! [Locations]
        
        
        
        
        
        let basedURL = "https://maps.googleapis.com/maps/api/elevation/json?path="
        stringURL += basedURL
        
        
        guard let firstLat = locationPoints.first?.latitude else { return }
        guard let firstLong = locationPoints.first?.longitude else { return }
        guard let lastLat = locationPoints.last?.latitude else { return }
        guard let lastLong = locationPoints.last?.longitude else { return }
        
        
        stringURL += "\(firstLat)%2C\(firstLong)%7C\(locationPoints[locationPoints.count/2].latitude)%2C\(locationPoints[locationPoints.count/2].longitude)%7C\(lastLat)%2C\(lastLong)"
        
        stringURL += "&samples=50&key=AIzaSyAkxIRJ2cr4CkY8wz6iPLyfIxc01x4yuOA"
        
        
        //print(stringURL)
        guard let urlString = URL(string: stringURL) else {
            
            print("Error: Cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: urlString)
        
        //let config = URLSessionConfiguration.default
        
        
        let session = URLSession.shared
        
        ProgressHUD.show("Data Patching...", interaction: false)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            switch httpResponse.statusCode {
            case 200:
                do{
                    
                    
                    guard let data = data else {
                        print("Error there is no data")
                        return
                    }
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary else {
                        print("the json rawvalue can not be convert to human readable format!")
                        
                        return
                    }
                    print(json)
                    
                    DispatchQueue.global(qos: .background).async {
                        let arrayElevations = json["results"] as! NSArray
                        //print(arrayElevations)
                        
                        for i in 0..<arrayElevations.count {
                            
                            let arrayForElevation = (arrayElevations[i] as! NSDictionary).object(forKey: "elevation") as! Double
                            self.elevationData.append(arrayForElevation)
                            
                            let lat = ((arrayElevations[i] as! NSDictionary).object(forKey: "location") as! NSDictionary).object(forKey: "lat") as! Double
                            let long = ((arrayElevations[i] as! NSDictionary).object(forKey: "location") as! NSDictionary).object(forKey: "lng") as! Double
                            let location = CLLocation(latitude: lat, longitude: long)
                            
                            self.locationsOfElevationSamples.append(location)
                        }
                        
                        //print(self.elevationData)
                        
                        var dist = 0.0
                        for i in 0..<self.locationsOfElevationSamples.count {
                            if i == 0 {
                                self.distanceRelateToElevation.append(0.0)
                            } else {
                                dist += self.locationsOfElevationSamples[i].distance(from: self.locationsOfElevationSamples[i-1])
                                dist = dist*(1/1000)*(1/1.61)
                                self.distanceRelateToElevation.append(dist)
                            }
                        }
                        
                        
                        //print(self.distanceRelateToElevation)
                        //self.labels.removeAll()
                        
                        for i in 0..<self.distanceRelateToElevation.count {
                            //self.labels.append(String(format: "%.1f",self.distanceRelateToElevation[i]))
                        }
                        
                        
                        DispatchQueue.main.async {
                            // Graph View
                            
                            //self.graphView.set(data: self.elevationData, withLabels: self.labels)
                            ProgressHUD.showSuccess("Success")
                        }
                        
                    }
                    
                } catch let error as NSError{
                    ProgressHUD.showError(error.localizedDescription)
                    print(error.debugDescription)
                }
                
            default:
                print("HTTP Response Code: \(httpResponse.statusCode)")
                
            }
            
        }
        task.resume()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //getElevationInfo()
        
        graphView = createDarkGraph(CGRect(x: 0, y: 0, width: view.frame.width-20, height: 200))
        
        
        
        view.backgroundColor = UIColor.black
        
        
        // Back Button
        view.addSubview(backButton)
        
        
        // Name of the Route
        view.addSubview(nameOfTheRoute)
        
        
        // Graph Label
        view.addSubview(graphLabel)
        
        
        // Map View
        view.addSubview(mapView)
        
        
        // Elevation Graph View
        view.addSubview(graphView)
        
        // Elevation Graph x-axis Label
        graphView.addSubview(x_axisLabel)
        
        // Date
        view.addSubview(dateLabel)
        
        
        // Distance
        view.addSubview(distanceLabel)
        
        
        // Time
        view.addSubview(timeLabel)
        
        // Average Speed
        view.addSubview(averageSpeedLabel)
        
        
        // Average Moving Speed
        view.addSubview(heartRateLabel)
        
        // Address
        view.addSubview(addressLabel)
        
        _ = backButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 40)
        
        _ = nameOfTheRoute.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 40)
        
        _ = mapView.anchor(nameOfTheRoute.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 200)
        
        _ = x_axisLabel.anchor(nil, left: graphView.leftAnchor, bottom: graphView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 3, bottomConstant: 3, rightConstant: 0, widthConstant: 10, heightConstant: 5)
        
        _ = graphLabel.anchor(mapView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        graphLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = graphView.anchor(graphLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 180)
        
        
        _ = dateLabel.anchor(graphView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = distanceLabel.anchor(dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        
        _ = averageSpeedLabel.anchor(distanceLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = heartRateLabel.anchor(timeLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        
        _ = addressLabel.anchor(averageSpeedLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        
        
        
        // Getting all the core data from previous route that saved in file and assign them to show
        configureView()
        
        
        // Getting polyline of the routes and show on the mapView
        DrawPath()
        
        
        // Set the constraints of the scrollview of the graph
        
    }
    
    private func configureView() {
        
        let distance = Measurement(value: ride.distance, unit: UnitLength.meters)
        let seconds = Int(ride.duration)
        //let movingSeconds = Int(ride.movingduration)
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(ride.timestamp as Date?)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: .milesPerHour)
        //let formattedMovingPace = FormatDisplay.pace(distance: distance, seconds: movingSeconds, outputUnit: .milesPerHour)
        
        
        if let name = ride.name {
            nameOfTheRoute.text = name
        }
        
        guard let address = ride.address else { return }
        
        
        
        dateLabel.text = "Date: \(formattedDate)"
        distanceLabel.text = "Distance: \(formattedDistance)"
        timeLabel.text = "Time: \(formattedTime)"
        averageSpeedLabel.text = "Avg 🚴🏼: \(formattedPace)"
        heartRateLabel.text = "Avg ❤️ Rate: \(ride.heartrate) bpm"
        addressLabel.text = "Region: \(address)"
        
        guard let locations = ride.locations,
            locations.count > 0
            else {
                let alert = UIAlertController(title: "Error", message: "Sorry, this run has no locations saved", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }
        
        
        
        
        
        let locationPoints = ride?.locations?.array as! [Locations]
        
        for i in 0..<locationPoints.count{
            if locationPoints[i].elevation > 0 {
                let elevation = locationPoints[i].elevation
                let lat = locationPoints[i].latitude
                let long = locationPoints[i].longitude
                let position = CLLocation(latitude: lat, longitude: long)
                
                print(elevation)
                elevationTempLabels.append(position)
                
                elevationData.append(elevation)
            }
            
        }
        
        var cumulativeDistance = 0.0
        
        
        for i in 0..<elevationTempLabels.count {
            if i == 0 {
                self.elevationLabels.append(String(format: "%.1f", 0.0))
                
            } else {
                cumulativeDistance += self.elevationTempLabels[i].distance(from: self.elevationTempLabels[i-1])
                let cumulativeDistanceInMiles = ((cumulativeDistance/1000.0)/1.61)
                //self.elevationLabels.append(String(format: "%.1f", cumulativeDistance))
                self.elevationLabels.append(String(format: "%.1f", cumulativeDistanceInMiles))
            }
            
        }
        
        graphView.set(data: elevationData, withLabels: elevationLabels)
        
        
    }
    
    
}

