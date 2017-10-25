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
import SwiftChart

class EbikeDetailsViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, ChartDelegate, UIScrollViewDelegate{

    // ScrollView for the graph

    //var label = UILabel()
    
    //var stringURL = String()
    
    //var locationsOfElevationSamples = [CLLocation]()
    //var distanceRelateToElevation = [Double]()
    
    var ride: Ride!
    
    
    let userDefault = UserDefaults.standard
    
    fileprivate let path = GMSMutablePath()
    
    // Polyline segment colored lines
    var arrayOfSegementColor = [GMSStyleSpan]()

    //Page of Graph
    var pageOfGraph = 0
    
    
    //Elevation Data Chart
    var elevationGain: Double = 0
    var isThisFirst: Bool = true
    var elevationDataPoints = [Float]()
    var elevationLocationPoints = [CLLocation]()
    var elevationXLabels = [Float]()
    
    //Speed Data Chart
    var speedData = [Double]()
    var speedLocationPoints = [CLLocation]()
    var averageSpeed: Double = 0
    var speedXLabels = [Float]()
    
    
    //Heart Rate Chart
    var heartRateData = [Float]()
    var heartRateLocationPoints = [CLLocation]()
    var averageHeartRate: Double = 0
    var heartRateXLabels = [Float]()
    var isHeartRateDataAvailable: Bool = false
    
    
    /// Scroll view for the three different chart sections: Elevation, Speed, Heart Rate
    let scrollViewPagingControl: UIPageControl = {
        let bar = UIPageControl(frame: CGRect(x: 0, y: 0, width:50, height: 10))
        bar.pageIndicatorTintColor = UIColor.white
        bar.currentPageIndicatorTintColor = UIColor.DTIRed()
        bar.numberOfPages = 3
        return bar
    }()
    
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 180))
        //view.layer.cornerRadius = 5
        view.bounces = false
        view.backgroundColor = UIColor.black
        view.isPagingEnabled = true
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        //ScrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(featureArray.count), height: 400)
        view.contentSize = CGSize(width: self.view.bounds.width * CGFloat(3), height: 180)
        
        return view
        
    }()
    
    // This is main frame view on the top of first scroll view
    lazy var mainFirstFrameView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: self.view.frame.width * CGFloat(0), y: 0, width: self.scrollView.frame.width, height: 180)
        view.backgroundColor = UIColor.black
        view.frame.size.width = self.view.bounds.size.width
        return view
    }()
    
    // This is main frame view on the top of second scroll view
    lazy var mainSecondFrameView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: self.view.frame.width * CGFloat(1), y: 0, width: self.scrollView.frame.width, height: 180)
        view.backgroundColor = UIColor.black
        view.frame.size.width = self.view.bounds.size.width
        return view
    }()
    
    // This is main frame view on the top of third scroll view
    lazy var mainThirdFrameView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: self.view.frame.width * CGFloat(2), y: 0, width: self.scrollView.frame.width, height: 180)
        view.backgroundColor = UIColor.black
        view.frame.size.width = self.view.bounds.size.width
        return view
    }()
    
    
    // Elevation Chart------------------------------------------------------------------------------------------------->
    var elevationLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    lazy var elevationChart: Chart = {
        let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        chart.xLabelsSkipLast = true
        chart.backgroundColor = UIColor.black
        chart.axesColor = UIColor.white
        chart.highlightLineColor = UIColor.white
        chart.highlightLineWidth = 0.5
        chart.labelColor = UIColor.white
        chart.areaAlphaComponent = 0.4
        chart.lineWidth = 1
        return chart
    }()
    // -------------------------------------------------------------------------------------------------------------->
    
    // Speed Chart------------------------------------------------------------------------------------------------->
    var speedLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    lazy var speedChart: Chart = {
        let chart = Chart(frame: CGRect(x:0 , y: 0, width: 300, height: 180))
        chart.xLabelsSkipLast = true
        chart.backgroundColor = UIColor.black
        chart.axesColor = UIColor.white
        chart.highlightLineColor = UIColor.white
        chart.highlightLineWidth = 0.5
        chart.labelColor = UIColor.white
        chart.areaAlphaComponent = 0.4
        chart.lineWidth = 1
        return chart
    }()
    // -------------------------------------------------------------------------------------------------------------->
    
    
    // Heart Rate Chart------------------------------------------------------------------------------------------------->
    var heartRateChartLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    lazy var heartRateChart: Chart = {
        let chart = Chart(frame: CGRect(x:0 , y: 0, width: 300, height: 180))
        chart.xLabelsSkipLast = true
        chart.backgroundColor = UIColor.black
        chart.axesColor = UIColor.white
        chart.highlightLineColor = UIColor.white
        chart.highlightLineWidth = 0.5
        chart.labelColor = UIColor.white
        chart.areaAlphaComponent = 0.4
        chart.lineWidth = 1
        return chart
    }()
    // -------------------------------------------------------------------------------------------------------------->
    
    
    
    
 
    
    
    
    lazy var nameOfTheRoute: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.backgroundColor = UIColor.clear
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTappedLabel))
        label.addGestureRecognizer(tapGesture)
        //label.numberOfLines = 2
        
        return label
    }()
    
    @objc func userTappedLabel(){
        let alertViewController = UIAlertController(title: "Rename Route", message: "", preferredStyle: .alert)
        let saveNameAction = UIAlertAction(title: "Save", style: .default) {
            _ in
            
            let nameTextField = alertViewController.textFields![0] as UITextField
            self.nameOfTheRoute.text = nameTextField.text
            
            self.ride.name = nameTextField.text
            CoreDataStack.saveContext()
        }
        
        alertViewController.addTextField { (textField: UITextField!) in
            textField.placeholder = "Enter The Name"
        }
        
        alertViewController.addAction(saveNameAction)
        self.present(alertViewController, animated: true, completion: nil)
        
    }
    
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
    
    var maxElevationLabel: UILabel = {
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
    
    var gainElevationLabel: UILabel = {
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
    
    @objc func backToPrevious() {
        self.performSegue(withIdentifier: "backToHistoryViewSegue", sender: backButton)
        
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
            let eachSpeed = Double((locationPoints[i].speed as Double)*(1/1000)*(1/1.61)*(3600)).rounded(toPlaces: 2)
            let lat = locationPoints[i].latitude
            let long = locationPoints[i].longitude
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            //print(position)
            
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
            
            
            /*
            //car speed
            if speed < 10 && speed >= 0 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidRed))
            } else if speed >= 10 && speed < 20 {
                
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.redToYellow))
            } else if speed >= 20 && speed < 30 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidYellow))
            } else if speed >= 30 && speed < 40 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.yellowToGreen))
            } else if speed >= 40 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidGreen))
            }
            */
            //bike speed
            
            if eachSpeed < 5 && eachSpeed >= 0 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidRed))
            } else if eachSpeed >= 5 && eachSpeed < 10 {
                
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.redToYellow))
            } else if eachSpeed >= 10 && eachSpeed < 13 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidYellow))
            } else if eachSpeed >= 13 && eachSpeed < 15 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.yellowToGreen))
            } else if eachSpeed >= 15 {
                arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidGreen))
            }
            
        }
        
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets.zero)

        mapView.animate(with: update)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.geodesic = true
        polyline.spans = arrayOfSegementColor
        polyline.map = self.mapView
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
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        scrollViewPagingControl.currentPage = Int(page)
        pageOfGraph = Int(page)
    }
    
    
    func initializedElevationChart() {
        
        elevationChart.delegate = self
        
        var seriesData:[(x: Float, y: Float)] = []
        var cumulativeDistance = 0.0
        var xMilesLabelLength: Int = 0
        
        let locationPoints = ride?.locations?.array as! [Locations]
        
        
        for i in 0..<locationPoints.count{
            if locationPoints[i].elevation >= 0 {
                let elevation = Float(locationPoints[i].elevation)
                let lat = locationPoints[i].latitude
                let long = locationPoints[i].longitude
                let position = CLLocation(latitude: lat, longitude: long)
                // Check the elevation difference between two locations in sequence order
                
                
                
                if elevation.isFinite == true {
                    
                    
                    if i > 0 && abs(locationPoints[i-1].elevation - locationPoints[i].elevation) > 100 {
                        print("What is going on???")
                        //let difference = abs(locationPoints[i-1].elevation*(3.28084) - locationPoints[i].elevation*(3.28084))
                        //print(difference)
                        //print(Float(locationPoints[i-1].elevation*(3.28084)))
                        
                        elevationDataPoints.append(500)
                        
                        elevationLocationPoints.append(position)
                        /*
                         if difference > 0 {
                         //current elevation is droping so fast that the elevation is not correct
                         locationPoints[i].elevation += difference/2
                         } else if difference < 0 {
                         //current elevation is way to high that the elevation is not correct
                         locationPoints[i].elevation -= difference/2
                         }
                         */
                    } else {
                        // Gain elevation calculation
                        if isThisFirst == true {
                            elevationGain = 0
                            isThisFirst = false
                            
                        } else {
                            if locationPoints[i].elevation > locationPoints[i-1].elevation {
                                elevationGain += locationPoints[i].elevation - locationPoints[i-1].elevation
                            }
                        }
                        
                        elevationLocationPoints.append(position)
                        elevationDataPoints.append(elevation)
                    }
                    
                }
            }
            
        }
        
        
        guard let maxElevationPoint = elevationDataPoints.max() else { return }
        maxElevationLabel.text = "Max Elev: \(String(format: "%.1f", maxElevationPoint)) ft"
        gainElevationLabel.text = "Gain Elev: \(String(format: "%.1f", elevationGain)) ft"
        
        
        for i in 0..<elevationDataPoints.count{
            let elevationDataPoint = elevationDataPoints[i]
            
            if i == 0 {
                seriesData.append((x: Float(0.0),y:elevationDataPoint))
                
            } else {
                cumulativeDistance += self.elevationLocationPoints[i].distance(from: self.elevationLocationPoints[i-1])
                let cumulativeDistanceInMiles = ((cumulativeDistance/1000.0)/1.61)
                seriesData.append((x:Float(cumulativeDistanceInMiles), y:elevationDataPoint))
                
            }
        }
        xMilesLabelLength = Int(((cumulativeDistance/1000.0)/1.61))
        
        if xMilesLabelLength <= 10{
            for i in 0...xMilesLabelLength {
                elevationXLabels.append(Float(i))
            }
        } else if xMilesLabelLength > 10 && xMilesLabelLength <= 20 {
            for i in stride(from: 0, to: xMilesLabelLength, by: 3){
                elevationXLabels.append(Float(i))
            }
            
        } else if xMilesLabelLength > 20 && xMilesLabelLength <= 30 {
            for i in stride(from: 0, to: xMilesLabelLength, by: 5){
                elevationXLabels.append(Float(i))
            }
            
        } else if xMilesLabelLength > 30 && xMilesLabelLength <= 40{
            for i in stride(from: 0, to: xMilesLabelLength, by: 7){
                elevationXLabels.append(Float(i))
            }
            
        } else if xMilesLabelLength > 40 {
            for i in stride(from: 0, to: xMilesLabelLength, by: 10){
                elevationXLabels.append(Float(i))
            }
        }
        
        let series = ChartSeries(data: seriesData)
        series.area = true
        elevationChart.xLabels = elevationXLabels
        elevationChart.xLabelsFormatter = { String(Int(round($1))) }
        elevationChart.add(series)
        
    }
    
    
    
    func initializedSpeedChart() {
        speedChart.delegate = self
        
        var seriesData:[(x: Float, y: Float)] = []
        var cumulativeDistance = 0.0
        var xMilesLabelLength: Int = 0
        
        
        let locationPoints = ride?.locations?.array as! [Locations]
        
        for i in 0..<locationPoints.count{
            
            if locationPoints[i].speed >= 0.0 {
                let eachSpeed = Double((locationPoints[i].speed as Double)*(1/1000)*(1/1.61)*(3600)).rounded(toPlaces: 2)
                let lat = locationPoints[i].latitude
                let long = locationPoints[i].longitude
                let position = CLLocation(latitude: lat, longitude: long)
                
                speedData.append(eachSpeed)
                averageSpeed += eachSpeed
                speedLocationPoints.append(position)
                
            }
            
        }
        
        for i in 0..<speedLocationPoints.count{
            let speedEachPoint = Float(speedData[i])
            
            if i == 0 {
                seriesData.append((x: Float(0.0),y:speedEachPoint))
            } else {
                cumulativeDistance += self.speedLocationPoints[i].distance(from: self.speedLocationPoints[i-1])
                let cumulativeDistanceInMiles = ((cumulativeDistance/1000.0)/1.61)
                seriesData.append((x:Float(cumulativeDistanceInMiles), y:speedEachPoint))
                
            }
        }
        
        
        xMilesLabelLength = Int(((cumulativeDistance/1000.0)/1.61))
        
        for i in 0...xMilesLabelLength {
            speedXLabels.append(Float(i))
        }
        
        if xMilesLabelLength > 10 && xMilesLabelLength <= 15{
            speedChart.labelFont = UIFont.systemFont(ofSize: 10)
        } else if xMilesLabelLength > 15 && xMilesLabelLength <= 20 {
            speedChart.labelFont = UIFont.systemFont(ofSize: 8)
        } else if xMilesLabelLength > 20 {
            speedChart.labelFont = UIFont.systemFont(ofSize: 6)
        }
        
        
        let series = ChartSeries(data: seriesData)
        series.area = true
        speedChart.xLabels = elevationXLabels
        speedChart.xLabelsFormatter = { String(Int(round($1))) }
        speedChart.add(series)
        
        
        guard let maxSpeed = speedData.max() else { return }
        print("max speed is \(maxSpeed) mph")
        print("average moving speed is \(averageSpeed/Double(speedData.count))")
        
    }
    
    
    
    
    func initializedHeartRateChart() {
        heartRateChart.delegate = self
        
        var seriesData:[(x: Float, y: Float)] = []
        var cumulativeDistance = 0.0
        var xMilesLabelLength: Int = 0
        
        let locationPoints = ride?.locations?.array as! [Locations]
        
        guard let avgHeartRate = ride?.avgheartrate else { return }
        
        // Check if there is heart rate data available to us
        if avgHeartRate > 0 {
            isHeartRateDataAvailable = true
            for i in 0..<locationPoints.count{
                let lat = locationPoints[i].latitude
                let long = locationPoints[i].longitude
                let position = CLLocation(latitude: lat, longitude: long)
                let h_Rate = locationPoints[i].heartRate
                
                heartRateData.append(Float(h_Rate))
                heartRateLocationPoints.append(position)
            }
            
        } else if avgHeartRate == 0 {
            // No heart rate is available
            let temp = 68
            isHeartRateDataAvailable = false
            for i in 0..<locationPoints.count{
                let lat = locationPoints[i].latitude
                let long = locationPoints[i].longitude
                let position = CLLocation(latitude: lat, longitude: long)
                
                heartRateData.append(Float(temp))
                heartRateLocationPoints.append(position)
                
                
            }
            
        }
        
        
        for i in 0..<heartRateLocationPoints.count{
            let hearRateEachPoint = heartRateData[i]
            
            if i == 0 {
                seriesData.append((x: Float(0.0),y:hearRateEachPoint))
            } else {
                cumulativeDistance += self.heartRateLocationPoints[i].distance(from: self.heartRateLocationPoints[i-1])
                let cumulativeDistanceInMiles = ((cumulativeDistance/1000.0)/1.61)
                seriesData.append((x:Float(cumulativeDistanceInMiles), y:hearRateEachPoint))
                
            }
        }
        
        
        xMilesLabelLength = Int(((cumulativeDistance/1000.0)/1.61))
        
        for i in 0...xMilesLabelLength {
            heartRateXLabels.append(Float(i))
        }
        
        
        if xMilesLabelLength > 10 && xMilesLabelLength <= 15{
            heartRateChart.labelFont = UIFont.systemFont(ofSize: 10)
        } else if xMilesLabelLength > 15 && xMilesLabelLength <= 20 {
            heartRateChart.labelFont = UIFont.systemFont(ofSize: 8)
        } else if xMilesLabelLength > 20 {
            heartRateChart.labelFont = UIFont.systemFont(ofSize: 6)
        }
        
        let series = ChartSeries(data: seriesData)
        series.area = true
        heartRateChart.xLabels = elevationXLabels
        heartRateChart.xLabelsFormatter = { String(Int(round($1))) }
        heartRateChart.add(series)
        
        /*
         if ride?.arrayOfHeartRate != nil {
         
         //heartRateData = heartRateDataFromCoreData as! Array
         print("HERE WE ARE TESTING!!!!")
         //seriesData = Float(heartRateDataFromCoreData)
         } else {
         var i = 0
         while i < 100 {
         seriesData.append(Float(arc4random_uniform(100)))
         i += 1
         }
         }
         let series = ChartSeries(seriesData)
         series.area = true
         
         
         for i in 0...10 {
         heartRateXLabels.append(Float(i))
         }
         
         //heartRateChart.xLabels = heartRateXLabels
         //heartRateChart.xLabelsFormatter = { String(Int(round($1)))}
         heartRateChart.add(series)
         */
        
    }
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Float, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            guard let data = numberFormatter.string(from: NSNumber(value: value)) else { return }
            
            if pageOfGraph == 0 {
                elevationLabel.text = "⛰: \(data) ft"
            } else if pageOfGraph == 1 {
                speedLabel.text = "🚴🏼: \(String(format: "%.0f", value)) mph"
            } else if pageOfGraph == 2 {
                if isHeartRateDataAvailable == true {
                    heartRateChartLabel.text = "❤️: \(String(format: "%.0f", value)) bpm"
                    
                } else {
                    heartRateChartLabel.text = "❤️: No Data Available"
                    
                }
                
            }

        }
    }
    func didFinishTouchingChart(_ chart: Chart) {
        elevationLabel.text = ""
        speedLabel.text = ""
        heartRateChartLabel.text = ""
    }
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        elevationChart.setNeedsDisplay()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        
        // Back Button
        view.addSubview(backButton)
        
        
        // Name of the Route
        view.addSubview(nameOfTheRoute)
        

        // Map View
        view.addSubview(mapView)
 
        
        // Charts of Elevations, Speed, Heart Rate
        view.addSubview(scrollView)
        
        _ = scrollView.anchor(mapView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 180)
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(scrollViewPagingControl)
        
        _ = scrollViewPagingControl.anchor(scrollView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 3, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 10)
        scrollViewPagingControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        scrollView.addSubview(mainFirstFrameView)
        scrollView.addSubview(mainSecondFrameView)
        scrollView.addSubview(mainThirdFrameView)
        
        
        mainFirstFrameView.addSubview(elevationChart)
        mainFirstFrameView.addSubview(elevationLabel)
        
        mainSecondFrameView.addSubview(speedChart)
        mainSecondFrameView.addSubview(speedLabel)
        
        mainThirdFrameView.addSubview(heartRateChart)
        mainThirdFrameView.addSubview(heartRateChartLabel)
        
        
        
        // Elevation Chart ----------------------------------------------------------------------------------------------------------------->
        _ = elevationChart.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width-20, heightConstant: 180)
        elevationChart.centerYAnchor.constraint(equalTo: mainFirstFrameView.centerYAnchor).isActive = true
        elevationChart.centerXAnchor.constraint(equalTo: mainFirstFrameView.centerXAnchor).isActive = true
        
        _ = elevationLabel.anchor(mainFirstFrameView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        elevationLabel.centerXAnchor.constraint(equalTo: elevationChart.centerXAnchor).isActive = true
        
        //---------------------------------------------------------------------------------------------------------------------------------->
        
        
        // Speed Chart ----------------------------------------------------------------------------------------------------------------->
        _ = speedChart.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width-20, heightConstant: 180)
        speedChart.centerXAnchor.constraint(equalTo: mainSecondFrameView.centerXAnchor).isActive = true
        speedChart.centerYAnchor.constraint(equalTo: mainSecondFrameView.centerYAnchor).isActive = true
        
        _ = speedLabel.anchor(mainSecondFrameView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        speedLabel.centerXAnchor.constraint(equalTo: speedChart.centerXAnchor).isActive = true
        //---------------------------------------------------------------------------------------------------------------------------------->
        
        // Heart Rate Chart ---------------------------------------------------------------------------------------------------------------->
        _ = heartRateChart.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width-20, heightConstant: 180)
        heartRateChart.centerYAnchor.constraint(equalTo: mainThirdFrameView.centerYAnchor).isActive = true
        heartRateChart.centerXAnchor.constraint(equalTo: mainThirdFrameView.centerXAnchor).isActive = true
        
        _ = heartRateChartLabel.anchor(mainThirdFrameView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 30)
        heartRateChartLabel.centerXAnchor.constraint(equalTo: heartRateChart.centerXAnchor).isActive = true
        
        //---------------------------------------------------------------------------------------------------------------------------------->
        
        
        
        
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
        
        // Max Elevation Point
        view.addSubview(maxElevationLabel)
        
        
        // Gain Elevation
        view.addSubview(gainElevationLabel)
        
        // Address
        view.addSubview(addressLabel)
        
        _ = backButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 40, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 30)
        
        _ = nameOfTheRoute.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 40)
        nameOfTheRoute.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = mapView.anchor(nameOfTheRoute.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 200)

        
        _ = dateLabel.anchor(scrollViewPagingControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = distanceLabel.anchor(dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        
        _ = averageSpeedLabel.anchor(distanceLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = heartRateLabel.anchor(timeLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = maxElevationLabel.anchor(averageSpeedLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = gainElevationLabel.anchor(heartRateLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = addressLabel.anchor(maxElevationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        
        
        
        // Getting all the core data from previous route that saved in file and assign them to show
        configureView()
        
        
        // Getting polyline of the routes and show on the mapView
        DrawPath()
        
        
        initializedElevationChart()
        initializedSpeedChart()
        initializedHeartRateChart()
        
        // Set the constraints of the scrollview of the graph
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return userDefault.object(forKey: key) != nil
    }
    
    private func configureView() {
        
        let roundDistance = Double(ride.distance).rounded(toPlaces: 2)
        let distance = Measurement(value: roundDistance, unit: UnitLength.meters)
        let seconds = Int(ride.duration)
        //let movingSeconds = Int(ride.movingduration)
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(ride.timestamp as Date?)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: .milesPerHour)
        //let formattedMovingPace = FormatDisplay.pace(distance: distance, seconds: movingSeconds, outputUnit: .milesPerHour)
        let distanceInMiles = ((ride.distance/1000.0)/1.61)
        
        if let name = ride.name {
            nameOfTheRoute.text = name
        }
        // Save the each ride distance to the local Disk to remember the total ride distance in the profile setting
        if isKeyPresentInUserDefaults(key: "totalMilesInYear") == true {
            var currentValue = userDefault.value(forKey: "totalMilesInYear") as! Double
            currentValue += distanceInMiles
            userDefault.set(currentValue, forKey: "totalMilesInYear")
            userDefault.synchronize()
            
        } else {
            userDefault.set((distanceInMiles), forKey: "totalMilesInYear")
            userDefault.synchronize()
            
        }
        
        guard let address = ride.address else { return }
        //guard let avgMovingSpeed = ride.avgMovingSpeed else { return }
        
        
        dateLabel.text = "Date: \(formattedDate)"
        distanceLabel.text = "Distance: \(formattedDistance)"
        timeLabel.text = "Time: \(formattedTime)"
        averageSpeedLabel.text = "Avg 🚴🏼: \(formattedPace) mph"
        heartRateLabel.text = "Avg ❤️ Rate: \(ride.avgheartrate) bpm"
        addressLabel.text = "Region: \(address)"
        
        
        /*
         
         var countForAvgMovingSpeedInstance = 0
         var countForAvgSpeedInstance = 0
         
         if locationObject.speed > 0 {
         avgMovingSpeed += locationObject.speed
         countForAvgMovingSpeedInstance += 1
         } else if locationObject.speed >= 0 {
         avgSpeed += locationObject.speed
         countForAvgSpeedInstance += 1
         }
         
         ride?.avgSpeed = (avgSpeed/Double(countForAvgSpeedInstance))*(1/1000)*(1/1.61)*(3600).rounded()
         ride?.avgMovingSpeed = (avgMovingSpeed/Double(countForAvgMovingSpeedInstance))*(1/1000)*(1/1.61)*(3600).rounded()
         */
    
    }
}
/*
extension EbikeDetailsViewController {
    

    
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
                        
                        //for i in 0..<self.distanceRelateToElevation.count {
                        //self.labels.append(String(format: "%.1f",self.distanceRelateToElevation[i]))
                        //}
                        
                        
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
 
    
}
*/
