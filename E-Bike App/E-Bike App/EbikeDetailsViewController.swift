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

class EbikeDetailsViewController: UIViewController, GMSMapViewDelegate {
    
    
    // ScrollView for the graph
    
    lazy var graphView: ScrollableGraphView = {
        var view = ScrollableGraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))

        return view
    }()
    
    
    
    var graphConstraints = [NSLayoutConstraint]()
    
    var label = UILabel()
    var labelConstraints = [NSLayoutConstraint]()
    
    
    
    // Data
    let numberOfDataItems = 20
    
    lazy var data: [Double] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,14,15,15,15,20]
        //self.generateRandomData(self.numberOfDataItems, max: 50)
    //[29.9, 30, 30, 30, 30, 30, 30, 30, 30]
    lazy var labels: [String] = self.generateSequentialLabels(self.numberOfDataItems, text: "Elev.")
    //["1", "2", "3", "4", "5", "6", "7", "8", "9"]

    
    
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
        label.text = "<Elevation>"
        
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        label.text = "Date"
        
        return label
    }()
    
    var distanceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.text = "Distance"
        
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.text = "Time: "
        
        return label
    }()
    
    
    var averageSpeedLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.text = "Time: "
        
        return label
    }()
    
    
    var averageMovingSpeedLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.text = "Time: "
        
        return label
    }()

    var addressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.text = "Address: "
        label.numberOfLines = 2
        
        return label
    }()
    

    
    lazy var backButton: UIButtonY = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("<Back", for: .normal)
        //button.cornerRadius = button.frame.width/2
        //button.borderWidth = 2
        //button.borderColor = UIColor.white
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
        

        print(locations.array as! [Locations])
        
        for i in 0..<locationPoints.count{
            let lat = locationPoints[i].latitude
            let long = locationPoints[i].longitude
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
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
        
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        graphView.lineWidth = 2
        graphView.lineColor = UIColor.colorFromHex(hexString: "#777777")
        graphView.lineStyle = ScrollableGraphViewLineStyle.straight
        
        graphView.shouldFill = true
        graphView.fillType = ScrollableGraphViewFillType.gradient
        graphView.fillColor = UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientType = ScrollableGraphViewGradientType.linear
        graphView.fillGradientStartColor = UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientEndColor = UIColor.colorFromHex(hexString: "#444444")
        
        graphView.dataPointSpacing = 50
        graphView.dataPointSize = 4
        graphView.dataPointFillColor = UIColor.white
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphView.referenceLineLabelColor = UIColor.white
        graphView.numberOfIntermediateReferenceLines = 5
        graphView.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        graphView.animationDuration = 1.5
        graphView.rangeMax = 50
        graphView.shouldRangeAlwaysStartAtZero = true
        
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
    
    // Data Generation
    private func generateRandomData(_ numberOfItems: Int, max: Double) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(arc4random()).truncatingRemainder(dividingBy: max)
            
            if(arc4random() % 100 < 10) {
                randomNumber *= 3
            }
            
            data.append(randomNumber)
        }
        return data
    }
    
    private func generateSequentialLabels(_ numberOfItems: Int, text: String) -> [String] {
        var labels = [String]()
        for i in 0 ..< numberOfItems {
            labels.append("\(text) \(i+1)")
        }
        return labels
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        graphView = createDarkGraph(CGRect(x: 0, y: 0, width: view.frame.width-20, height: 200))
        
        view.backgroundColor = UIColor.black
        
        mapView.delegate = self
        
        
        // Back Button
        view.addSubview(backButton)
        
        
        // Name of the Route
        view.addSubview(nameOfTheRoute)
        
        
        // Graph Label
        view.addSubview(graphLabel)
        
        
        // Map View
        view.addSubview(mapView)
        
        
        // Graph View
        view.addSubview(graphView)
        
        
        // Date
        view.addSubview(dateLabel)
        
        
        // Distance
        view.addSubview(distanceLabel)
        
        
        // Time
        view.addSubview(timeLabel)
        
        // Average Speed
        view.addSubview(averageSpeedLabel)
        
        
        // Average Moving Speed
        view.addSubview(averageMovingSpeedLabel)
        
        // Address
        view.addSubview(addressLabel)
        
        _ = backButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        _ = nameOfTheRoute.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 60)
        
        
        _ = mapView.anchor(nameOfTheRoute.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 200)
        
        _ = graphLabel.anchor(mapView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        graphLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = graphView.anchor(graphLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 200)
        
        
        _ = dateLabel.anchor(graphView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 20)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = distanceLabel.anchor(dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: timeLabel.leftAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/2, heightConstant: 15)
        
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: distanceLabel.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/2, heightConstant: 15)
        
        
        _ = averageSpeedLabel.anchor(distanceLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: averageMovingSpeedLabel.leftAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/2, heightConstant: 15)
        
        _ = averageMovingSpeedLabel.anchor(timeLabel.bottomAnchor, left: averageSpeedLabel.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/2, heightConstant: 15)
        
        
        _ = addressLabel.anchor(averageSpeedLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 15)
        
        
        
        // Getting all the core data from previous route that saved in file and assign them to show
        configureView()
        
        
        // Getting polyline of the routes and show on the mapView
        DrawPath()
        
        
        // Set the constraints of the scrollview of the graph
        //setupConstraints()
        
    }
    
    private func configureView() {
        
        let distance = Measurement(value: ride.distance, unit: UnitLength.meters)
        let seconds = Int(ride.duration)
        let movingSeconds = Int(ride.movingduration)
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(ride.timestamp as Date?)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: .milesPerHour)
        let formattedMovingPace = FormatDisplay.pace(distance: distance, seconds: movingSeconds, outputUnit: .milesPerHour)
        
        
        if let name = ride.name {
            nameOfTheRoute.text = name
        }
        
        if let address = ride.address {
            addressLabel.text = address
        }
        
        distanceLabel.text = "Distance:  \(formattedDistance)"
        dateLabel.text = formattedDate
        timeLabel.text = "Time:  \(formattedTime)"
        averageSpeedLabel.text = "A.Speed: \(formattedPace)"
        averageMovingSpeedLabel.text = "A.M.Speed: \(formattedMovingPace)"
        

        
        graphView.set(data: data, withLabels: labels)
        
    }


}

