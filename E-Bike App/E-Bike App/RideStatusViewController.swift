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
import CoreLocation
import CoreData

import LocalAuthentication



class RiderStatusViewController: UIViewController, UIScrollViewDelegate, CircleMenuDelegate, CLLocationManagerDelegate, GMSMapViewDelegate{

    
    fileprivate var ride:Ride?
    fileprivate var distance = Measurement(value: 0, unit: UnitLength.miles)
    fileprivate var address: [String] = []
    fileprivate var locationList: [CLLocation] = []
    fileprivate var timer: Timer?
    fileprivate var totalMovingTimer: Timer?
    
    fileprivate let locationManager = LocationManager.shared
    fileprivate var seconds = 0
    fileprivate var startLocation: CLLocation!
    fileprivate var lastLocation: CLLocation!
    fileprivate var totalTravelDistance: Double = 0
    fileprivate var movingSeconds = 0
    
    let path = GMSMutablePath()
    
    var likeltPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    
    let infoMarker = GMSMarker()
    
    var totalMovingTime: Int?
    
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
        
        view.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.31, alpha:1.00)
        
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
        return label
    }()
    
    
    
    
    let mapView: GMSMapView = {
        
        let view = GMSMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        view.mapType = .normal
        view.isMyLocationEnabled = true
        view.isBuildingsEnabled = true
        view.autoresizesSubviews = true
        view.settings.indoorPicker = true
        view.settings.zoomGestures = true
        view.settings.compassButton = true
        view.settings.zoomGestures = true
        view.settings.rotateGestures = true
        view.settings.scrollGestures = true
        view.settings.tiltGestures = true
        view.setMinZoom(10, maxZoom: 18)
        view.accessibilityElementsHidden = false
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        return view
    }()
    
    
    
    func featureViewController() {
        featureArray = [screenOne,screenTwo, screenThree, screenFour, screenFive]
        ScrollView.isPagingEnabled = true
        ScrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(featureArray.count), height: 400)
        statusViewControl.numberOfPages = featureArray.count
        ScrollView.showsHorizontalScrollIndicator = false
        ScrollView.delegate = self
    }
    
    
    var indexForFeature: Int!
    
    
    
    var thirdData = UILabel()
    var thirdDataSecond = UILabel()
    var thirdDataThird = UILabel()
    var timeFromStart = UILabel()
    var distanceLabel = UILabel()
    

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
                
                
                _ = mapView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: mainFrameOfView.frame.width, heightConstant: mainFrameOfView.frame.height - 50)
                mapView.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                mapView.centerYAnchor.constraint(equalTo: mainFrameOfView.centerYAnchor).isActive = true
                
                
            
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
                speedButton.backgroundColor = UIColor.darkGray
                speedButton.layer.cornerRadius = speedButton.frame.width/2
                speedButton.layer.borderColor = UIColor.DTIRed().cgColor
                speedButton.layer.borderWidth = 3
                speedButton.isHighlighted = true
                speedButton.titleLabel?.textAlignment = .center
                speedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                speedButton.setTitle(labelArray[0], for: .normal)
                speedButton.tag = 0
                speedButton.addTarget(self, action: #selector(moveToPopUp), for: .touchUpInside)
                
                
                
                let timeButton = UIButton()
                timeButton.frame = CGRect(x: mainFrameOfView.frame.width * CGFloat(index), y: 0, width: 80, height: 80)
                timeButton.backgroundColor = UIColor.darkGray
                timeButton.layer.cornerRadius = speedButton.frame.width/2
                timeButton.layer.borderColor = UIColor.DTIRed().cgColor
                timeButton.layer.borderWidth = 3
                timeButton.isHighlighted = true
                timeButton.titleLabel?.textAlignment = .center
                timeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
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
                ScrollView.addSubview(timeButton)
            
                
                _ = middleFrameOfView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: mainFrameOfView.frame.width-40, heightConstant: mainFrameOfView.frame.width-40)
                middleFrameOfView.centerXAnchor.constraint(equalTo: mainFrameOfView.centerXAnchor).isActive = true
                middleFrameOfView.centerYAnchor.constraint(equalTo: mainFrameOfView.centerYAnchor).isActive = true
                
                
                _ = speedButton.anchor(middleFrameOfView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
                speedButton.centerXAnchor.constraint(equalTo: middleFrameOfView.centerXAnchor).isActive = true
                
                
                _ = timeButton.anchor(nil, left: nil, bottom: nil, right: middleFrameOfView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 80, heightConstant: 80)
                timeButton.centerYAnchor.constraint(equalTo: middleFrameOfView.centerYAnchor).isActive = true
            
            }
            

            
            
        }
    
    }
    

    
    lazy var closeButton: UIButtonY = {
        
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.cornerRadius = button.frame.width/2
        button.setTitle("Cancel", for: .normal)
        button.tintColor = UIColor.black
        button.borderWidth = 1
        button.borderColor = UIColor.darkGray
        button.backgroundColor = UIColor.white
        button.alpha = 0.7
        button.titleLabel?.textColor = UIColor.DTIRed()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
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
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    let speedLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    let timeLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    let addressLabel: UILabelX = {
        let label = UILabelX(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        return label
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
        
        //box.items = [historyButton]
    
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
        
        
        _ = titleLabel.anchor(nil, left: nil, bottom: infoView.centerYAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: 150, heightConstant: 50)
        titleLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        
        
        _ = closeButton.anchor(nil, left: nil, bottom: infoView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        closeButton.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        
        
        if sender.tag == 0 {
            timeLabel.removeFromSuperview()
            infoView.addSubview(speedLabel)
            
            _ = speedLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
            speedLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            speedLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
            
        }
        
        if sender.tag == 3 {
            speedLabel.removeFromSuperview()
            
            
            //timeLabel.text = "\(0):\(0):\(0)"
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

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
            if startLocation == nil {
                startLocation = locations.first
                path.add(startLocation.coordinate)
                
            } else if let location = locations.last {
                totalTravelDistance += lastLocation.distance(from: location)
                print("Traveled Distance:",  totalTravelDistance)
                print("Straight Distance:", startLocation.distance(from: locations.last!))
                
                
                let msTomph = ((location.speed as Double)*(1/1000)*(1/1.61)*(3600)).rounded()
                speedLabel.text = "\(msTomph)/mph"
                thirdData.text = "\(msTomph)/mph"
                thirdDataSecond.text = "\(msTomph)/mph"
                thirdDataThird.text = "\(msTomph)/mph"
                
                
                
                trackingMovingTime(speed: location.speed as Double!)
                
                path.add((locations.last?.coordinate)!)
                
                
                distance = Measurement(value: totalTravelDistance, unit: UnitLength.meters)
                
                let camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                
                mapView.animate(to: camera)
                reverseGeocodeCoordinate(coordinate: location.coordinate)
            }
        
            lastLocation = locations.last
            locationList.append(lastLocation)
        
            drawPath(path: path)
        
    }
    
    
    func drawPath(path: GMSPath) {
    
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.geodesic = true
        polyline.strokeColor = UIColor(red:0.14, green:0.17, blue:0.17, alpha:1.00)
        polyline.map = self.mapView
    }
    
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
    
    
    // Handle location manger errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = "\(location.latitude), \(location.longitude)"
        infoMarker.layer.cornerRadius = 25
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0.7
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        infoMarker.appearAnimation = GMSMarkerAnimation.pop
        infoMarker.isTappable = true
        mapView.selectedMarker = infoMarker
        
        locationManager.stopUpdatingLocation()
        let camera = GMSCameraPosition(target: location, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animate(to: camera)
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

    
    let backButton: UIButtonY = {
    
        let cancelButton: UIImage = resizeImage.resizeImageWith(image: (UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate))!, newSize: CGSize(width: 30, height: 30))
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        
        button.setImage(cancelButton, for: .normal)
        button.tintColor = UIColor.white
       
        return button
    }()
    

    
    
    lazy var startButton: UIButtonY = {
    
        let button = UIButtonY(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
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
            startEbike()
            
        
        } else if (sender.tag == 2){
            
            alertView()
            sender.setTitle("Start", for: .normal)
            sender.tag = 1
        
        }
        
    }

    fileprivate func startEbike() {
    
        
        
        locationManager.startUpdatingLocation()
        
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
    
    fileprivate func alertView() {
        let alertController = UIAlertController(title: "End Ride?", message: "Do you want to end your ride?", preferredStyle: .alert)
        let titleFont: [String:AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        let messageFont: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        
        let attributedTitle = NSMutableAttributedString(string: "End Ride?", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "Do you want to save your ride?", attributes: messageFont)
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let saveButton = UIAlertAction(title: "Save The Route", style: .default) {
            _ in
            self.saveNameOfRoute()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) {
            _ in
            
        
        }
        
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
        
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func saveEbike(name: String) {
        
        
        let newRide = Ride(context: CoreDataStack.context)
        newRide.distance = distance.value
        newRide.duration = Int16(seconds)
        newRide.timestamp = Date() as NSDate?
        newRide.name = name
        newRide.movingduration = Int16(movingSeconds)
        
        
        for i in 0..<address.count{
            
            if (i == address.count/2) {
                newRide.address = address[i]
            }
        }
        
        for location in locationList {
            let locationObject = Locations(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp as NSDate?
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRide.addToLocations(locationObject)
        }
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
            
            NSLog("One or more of the map style failed to load. \(error)")
            print("One or more of the map style failed to load. \(error)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
        
        
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        mapView.delegate = self
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(mainTitle)
        //view.addSubview(backButton)
        view.addSubview(ScrollView)
        view.addSubview(statusViewControl)
        view.addSubview(addressLabel)
        view.addSubview(startButton)
        view.addSubview(toolBox)
        

        
        mapStyle()
        featureViewController()
        loadFeatures()
        
        
        _ = mainTitle.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 30)
        mainTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //_ = backButton.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: ScrollView.topAnchor, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        _ = ScrollView.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 400)
        ScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = statusViewControl.anchor(ScrollView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 20)
        statusViewControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = addressLabel.anchor(statusViewControl.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 50)
        
        _ = startButton.anchor(addressLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = toolBox.anchor(startButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 50)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
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
            let destionation = segue.destination as! UINavigationController
            //destionation.ride = ride
        }
        
        
    }

}

