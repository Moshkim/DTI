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
    
    lazy var data: [Double] = self.generateRandomData(self.numberOfDataItems, max: 50)
    //[29.9, 30, 30, 30, 30, 30, 30, 30, 30]
    lazy var labels: [String] = self.generateSequentialLabels(self.numberOfDataItems, text: "Distance")
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

    
    var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.backgroundColor = UIColor.clear
        label.text = "Date"
        
        return label
    }()
    
    var distanceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = UIColor.clear
        label.text = "Distance"
        
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = UIColor.clear
        label.text = "Time: "
        
        return label
    }()

    var addressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = UIColor.clear
        label.text = "Address: "
        label.numberOfLines = 2
        
        return label
    }()
    
    
    func DrawPath(){
        
        
        
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
        graphView.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        graphView.shouldFill = true
        graphView.fillType = ScrollableGraphViewFillType.gradient
        graphView.fillColor = UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientType = ScrollableGraphViewGradientType.linear
        graphView.fillGradientStartColor = UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientEndColor = UIColor.colorFromHex(hexString: "#444444")
        
        graphView.dataPointSpacing = 80
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
        
        
        graphView = createDarkGraph(CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        
        

        
        view.backgroundColor = UIColor.black
        
        mapView.delegate = self
        
        // Name of the Route
        view.addSubview(nameOfTheRoute)
        
        
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
        
        
        // Address
        view.addSubview(addressLabel)
        
        
        _ = nameOfTheRoute.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 60)
        
        
        _ = mapView.anchor(nameOfTheRoute.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 300)
        
        _ = graphView.anchor(mapView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 150)
        
        _ = dateLabel.anchor(graphView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = distanceLabel.anchor(dateLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
        distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = timeLabel.anchor(distanceLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
        timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = addressLabel.anchor(timeLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 50)
        addressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        
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
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(ride.timestamp as Date?)
        let formattedTime = FormatDisplay.time(seconds)
        
        
        if let name = ride.name {
            nameOfTheRoute.text = name
        }
        
        if let address = ride.address {
            addressLabel.text = address
        }
        
        distanceLabel.text = "Distance:  \(formattedDistance)"
        dateLabel.text = formattedDate
        timeLabel.text = "Time:  \(formattedTime)"
        

        
        graphView.set(data: data, withLabels: labels)
        
    }


}

