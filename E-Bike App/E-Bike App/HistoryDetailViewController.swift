//
//  HistoryDetailViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/4/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import SwiftChart


class HistoryDetailViewController: UIViewController, GMSMapViewDelegate, UIScrollViewDelegate, ChartDelegate, iCarouselDelegate, iCarouselDataSource{
    
    

    
    //Timer for the map maximize and minimize
    let timer = Timer()
    
    // Draw The Route on the Map
    fileprivate let path = GMSMutablePath()
    // Polyline segment colored lines
    var arrayOfSegementColor = [GMSStyleSpan]()
    
    //@IBOutlet weak var carouselView: iCarousel!
    
    // Index of Photo
    var arrayOfIndexPhoto = [String]()
    
    
    // Map Touch To Maximum
    var mapTouched = true
    
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
                            elevationGain += 0
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
        
        
        
        
        
        /*
        if xMilesLabelLength > 10 && xMilesLabelLength <= 15{
            elevationChart.labelFont = UIFont.systemFont(ofSize: 10)
        } else if xMilesLabelLength > 15 && xMilesLabelLength <= 20 {
            elevationChart.labelFont = UIFont.systemFont(ofSize: 8)
        } else if xMilesLabelLength > 20 {
            elevationChart.labelFont = UIFont.systemFont(ofSize: 6)
        }
        */
        
        
        let series = ChartSeries(data: seriesData)
        series.area = true
        series.colors.above = UIColor.DTIRed()
        series.colors.below = UIColor(red:0.91, green:0.71, blue:0.70, alpha:1.00)
        series.colors.zeroLevel = 50
        
        elevationChart.xLabels = elevationXLabels
        elevationChart.xLabelsFormatter = { String(Int64(round($1)))}
        elevationChart.add(series)
        
    }
    
    
    
    func initializedSpeedChart() {
        speedChart.delegate = self
        
        var seriesData:[(x: Float, y: Float)] = []
        var cumulativeDistance = 0.0
        //var xMilesLabelLength: Int = 0
        
    
        let locationPoints = ride?.locations?.array as! [Locations]
        
        
        
        
        for i in 0..<locationPoints.count{
            
            
            if locationPoints[i].speed >= 0.0 {
                let eachSpeed = Double((locationPoints[i].speed as Double)*(1/1000)*(1/1.61)*(3600)).rounded(toPlaces: 2)
                print(eachSpeed)
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
        
        
        //xMilesLabelLength = Int(((cumulativeDistance/1000.0)/1.61))
        /*
        for i in 0...xMilesLabelLength {
            speedXLabels.append(Float(i))
        }
        */
        /*
        if xMilesLabelLength > 10 && xMilesLabelLength <= 15{
            speedChart.labelFont = UIFont.systemFont(ofSize: 10)
        } else if xMilesLabelLength > 15 && xMilesLabelLength <= 20 {
            speedChart.labelFont = UIFont.systemFont(ofSize: 8)
        } else if xMilesLabelLength > 20 {
            speedChart.labelFont = UIFont.systemFont(ofSize: 6)
        }
        */
        let series = ChartSeries(data: seriesData)
        series.area = true
        series.color = UIColor(red:0.91, green:0.71, blue:0.70, alpha:1.00)
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
        //var xMilesLabelLength: Int = 0
        
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
        
        /*
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
        */
        
        let series = ChartSeries(data: seriesData)
        series.area = true
        series.color = UIColor.DTIRed()
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
    

    
    
    var ride: Ride? {
        didSet{
            nameOfTheRoute.text = ride?.name
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
            let roundDistance = Double((ride?.distance)!).rounded(toPlaces: 2)
            
            let distance = Measurement(value: roundDistance, unit: UnitLength.meters)
            let seconds = Int((ride?.duration)!)
            let formattedDistance = FormatDisplay.distance(distance)
            let formattedDate = FormatDisplay.date(ride?.timestamp as Date?)
            let formattedTime = FormatDisplay.time(seconds)
            let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: .milesPerHour)
            
            guard let address = ride?.address else { return }
            guard let heartRate = ride?.avgheartrate else { return }
            //guard let avgMovingSpeed = ride?.avgMovingSpeed else { return }
                        
            dateLabel.text = "Date: \(formattedDate)"
            distanceLabel.text = "Distance: \(formattedDistance)"
            timeLabel.text = "Time: \(formattedTime)"
            averageSpeedLabel.text = "Avg 🚴🏼: \(formattedPace) mph"
            heartRateLabel.text = "Avg ❤️ Rate: \(heartRate) bpm"
            addressLabel.text = "Region: \(address)"
            
            //DrawPath()
            
        }
    }

    
    lazy var nameOfTheRoute: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = UIColor.clear
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTappedLabel))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    @objc func userTappedLabel(){
        let alertViewController = UIAlertController(title: "Rename Route", message: "", preferredStyle: .alert)
        let saveNameAction = UIAlertAction(title: "Save", style: .default) {
            _ in
            
            let nameTextField = alertViewController.textFields![0] as UITextField
            self.nameOfTheRoute.text = nameTextField.text
            
            self.ride?.name = nameTextField.text
            CoreDataStack.saveContext()
        }
        
        alertViewController.addTextField { (textField: UITextField!) in
            textField.placeholder = "Enter The Name"
        }
        
        alertViewController.addAction(saveNameAction)
        self.present(alertViewController, animated: true, completion: nil)
        
    }
    
    lazy var graphView: ScrollableGraphView = {
        var view = ScrollableGraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.white
        return view
    }()
    
    
    lazy var mapView: GMSMapView = {
        let view = GMSMapView(frame: CGRect(x: 10, y: 80, width: self.view.frame.width-20, height: 250))
        view.mapType = .normal
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 5
        view.setMinZoom(5, maxZoom: 18)
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.delegate = self
        return view
    }()
    
    lazy var maximizeMapButton: UIButton = {
        let button = UIButton(frame: CGRect(x: self.mapView.frame.width-35, y: 5, width: 30, height: 30))
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = button.frame.width/2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        button.tag = 0
        button.addTarget(self, action: #selector(maximizeMap), for: .touchUpInside)
        return button
    }()
    @objc func maximizeMap(sender: UIButton) {
        
        if sender.tag == 0 {
            sender.tag = 1
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.mapView.frame = CGRect(x: 0, y: 70, width: self.view.frame.width, height: self.view.frame.height-50)
                
                self.maximizeMapButton.setTitle("X", for: .normal)
                self.maximizeMapButton.frame = CGRect(x: self.mapView.frame.width-35, y: 5, width: 30, height: 30)
            }, completion: nil)
        } else {
            sender.tag = 0
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.mapView.frame = CGRect(x: 10, y: 80, width: self.view.frame.width-20, height: 250)
                self.maximizeMapButton.setTitle("+", for: .normal)
                self.maximizeMapButton.frame = CGRect(x: self.mapView.frame.width-35, y: 5, width: 30, height: 30)
            }, completion: nil)
        }
        
        
    }

    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        button.setTitle("<Back", for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(goBackToMain), for: .touchUpInside)
        return button
    }()
    
    
    @objc func goBackToMain() {
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "deleteButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(alertView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "shareButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(shareInfoAndExport), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    var distanceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    var averageSpeedLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    
    var heartRateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    var maxElevationLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
        
    }()
    
    
    var gainElevationLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.layer.cornerRadius = 5
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        return label
        
    }()
    
    var addressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        
        return label
    }()
    
    
    
    
    @objc func shareInfoAndExport() {
        
        let exportString = createExportString()
        
        saveAndExport(exportString: exportString)
        
    }
    
    func saveAndExport(exportString: String) {
        
        var name: String?
        if let titleName = ride?.name{
            name = titleName
        }
        //NSTemporaryDirectory()
        //"/Users/Moses/Desktop/"
        //Temporary I save csv file to the desktop to see if it is really export
        let exportFilePath = NSTemporaryDirectory() + "\(name!).csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        //FileManager.default.createFile(atPath: exportFilePath, contents: Data?, attributes: nil)
        
        
        do {
            
            try exportString.write(to: exportFileURL as URL, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [exportFileURL], applicationActivities: nil)
            
            vc.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToVimeo,
                UIActivityType.postToWeibo,
                UIActivityType.postToFlickr,
                UIActivityType.postToTwitter,
                UIActivityType.postToTencentWeibo
            ]
            
            self.present(vc, animated: true, completion: nil)
            
        } catch {
            print("Failed to create file \(LocalizedError.self)")
            
        }
    }
    
    
    func createExportString() -> String {
        
        let name: String?
        let address: String?
        let averageSpeed: String?
        let date: String?
        let duration: String?
        let totalDistance: String?
        
        
        var export: String = NSLocalizedString("Name, Date, Address, Duration, Total Distance, Average Speed \n", comment: "")
        
        if let nameOptional = ride?.name {
            name = "\(nameOptional)"
            export += name! + ","
            
        }
        if let dateOptional = ride?.timestamp {
            date = "\(dateOptional as NSDate)"
            export += date! + ","
            
        }
        if let addressOptional = ride?.address {
            address = "\(addressOptional)"
            export += address! + ","
        }
        if let durationOptional = ride?.duration {
            duration = "\(FormatDisplay.time(Int((durationOptional))))"
            export += duration! + ","
        }
        if let totalDistanceOptional = ride?.distance {
            totalDistance = "\(FormatDisplay.distance(Measurement(value: totalDistanceOptional, unit: UnitLength.meters)))"
            export += totalDistance! + ","
            
        }
        
        if let averageSpeedOptional = ride?.duration {
            if let averageSpeedOptional_1 = ride?.distance {
                averageSpeed = "\(FormatDisplay.pace(distance: Measurement(value: averageSpeedOptional_1, unit: UnitLength.meters), seconds: Int(averageSpeedOptional), outputUnit: .milesPerHour))"
                export += averageSpeed! + "\n"
            }
        }
        
        return export
    }
    
    @objc func alertView() {
        
        let alertController = UIAlertController(title: "Delete this route?", message: "Are you sure?", preferredStyle: .alert)
        let titleFont: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.boldSystemFont(ofSize: 20)]
        let messageFont: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 18)]
        
        let attributedTitle = NSMutableAttributedString(string: "Delete this route?", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "Are you sure?", attributes: messageFont)
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let deleteButton = UIAlertAction(title: "Delete", style: .default) {
            _ in
            
            self.deleteRelatedPhotosWithRoute()
            
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.view.tintColor = UIColor.DTIBlue()
        alertController.view.layer.cornerRadius = 25
        alertController.view.backgroundColor = UIColor.darkGray
        
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    // FIXIT - I need to fix it!
    func moveToRefreshedHistory() {
        //let vc = HistoryViewController()
        navigationController?.popViewController(animated: true)
        //self.performSegue(withIdentifier: "backToHistoryViewSegue", sender: self)
        //navigationController?.pushViewController(vc, animated: true)
        //navigationController?.popToRootViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    func deleteRelatedPhotosWithRoute() {
        
        let fileMananer = FileManager.default
        
        //Get the URL for the users home directory
        let documentsURL = fileMananer.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        //Get the document URL as a string
        let documentPath = documentsURL.path
        
        
        
        do {
            
            
            guard let photoInfo = ride?.photos else { return }
            let photoPoints = photoInfo.array as! [Photo]
            
            if photoPoints.count > 0 {
                for i in 0..<photoPoints.count {
                    if eachIndexsOfPhotoLocation[i].count > 0 {
                        for j in 0..<eachIndexsOfPhotoLocation[i].count {
                            let photoIndex = eachIndexsOfPhotoLocation[i][j]
                            print(photoIndex)
                            print("\(documentPath)/\(photoIndex).jpeg")
                            try fileMananer.removeItem(atPath: "\(documentPath)/\(photoIndex).jpeg")
                        }
                    }
                }
            }
            self.clearData()
            self.moveToRefreshedHistory()
            // Look through array of files in documentDirectory
            /*let files = try fileMananer.contentsOfDirectory(atPath: "\(documentPath)")
            for file in files {
                
                
            }*/
            
            //try fileMananer.removeItem(atPath: "\(documentPath)/\(file)")
            /*
            for i in 0..<arrayOfIndexPhoto.count {
                print("\(arrayOfIndexPhoto[i]).jpeg")
                try fileMananer.removeItem(atPath: "\(documentPath)/\(arrayOfIndexPhoto[i]).jpeg")
                
            }
            */
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    lazy var carouselView: iCarousel = {
        let view = iCarousel(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height))
        view.delegate = self
        view.dataSource = self
        view.type = .coverFlow
        view.scrollSpeed = 0.5
        //view.isUserInteractionEnabled = true
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground))
        //view.addGestureRecognizer(tapGesture)
        
        let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-70, width: self.view.frame.width, height: 50))
        label.textAlignment = .center
        label.text = "< Swipe >"
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
        
        return view
    }()
    
    var eachIndexsOfPhotoLocation = [[Int16]]()
    var images = [UIImage]()
    var tempNumbers = [1,2,3,4,5]
    var currentPosition = 0
    var isThisFirstTime = true
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        if isThisFirstTime == false {
            print(eachIndexsOfPhotoLocation[currentPosition].count)
            print("*******************************************************************************************************************************************")
            return eachIndexsOfPhotoLocation[currentPosition].count
        } else {
            return 1
        }
        
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let itemView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        //itemView.backgroundColor = UIColor.cyan
        
        
        print(isThisFirstTime)
        print("***************************************************************************")
        if isThisFirstTime == true {
            itemView.backgroundColor = UIColor.black
            
            print("does it come here?")
            
            
        } else {
            print("it should not come here when we first time see the view")
            print("***************************************************************************")
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = URL(fileURLWithPath: path)
            
            for i in 0..<eachIndexsOfPhotoLocation[currentPosition].count{
                let filePath = url.appendingPathComponent("\(eachIndexsOfPhotoLocation[currentPosition][i]).jpeg").path
                print(filePath)
                print("***************************************************************************")
                if let photo = UIImage(contentsOfFile: filePath){
                    images.append(photo)
                }
            }
            //let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            itemView.center = carouselView.center
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground))
            
            itemView.addGestureRecognizer(tapGesture)
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
            imageView.contentMode = .scaleAspectFit
            imageView.image = images[index]
            itemView.addSubview(imageView)
            
            
        }
        
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == iCarouselOption.spacing {
            return value
        }
        return value
    }
    

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("the marker is tapped")
        isThisFirstTime = false
        if let indexs = marker.userData {
            print(indexs)
            currentPosition = indexs as! Int
            
            images.removeAll()
            carouselView.reloadData()
            
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.carouselView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                self.carouselView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
                
            }, completion: nil)
            
            
        }
        return false
    }
    
    
    @objc func tappedBackground() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.carouselView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)

        }, completion: nil)
        
    }
    
    
    func DrawPhotoPin() {
        print("goes in here")
        guard let photoInfo = ride?.photos else { return }
        print("goes in here")
        let photoPoints = photoInfo.array as! [Photo]
        
        if photoPoints.count > 0 {
            print("goes in here woohooo")
            for i in 0..<photoPoints.count {
                eachIndexsOfPhotoLocation.append([])
                
                print(eachIndexsOfPhotoLocation)
                print("***************************************************************************")
                print("***************************************************************************")
                print("***************************************************************************")
                guard let photoIndex = photoPoints[i].numberOfPhoto else { return }
                //print("goes in here woohooo")
                let indexPhoto = photoIndex.array as! [IndexForPhoto]
                
                print("***************************************************************************")
                print("***************************************************************************")
                print("***************************************************************************")
                
                print("indexPhoto: ", indexPhoto.count)
                
                print("***************************************************************************")
                print("***************************************************************************")
                print("***************************************************************************")
                
                
                if indexPhoto.count > 0 {
                    print("goes in here woohooo")
                    for j in 0..<indexPhoto.count{
                        
                        
                        if i <= photoPoints.count-2{
                            let temp = (photoPoints[i+1].numberOfPhoto?.array as! [IndexForPhoto])[0].index
                            for t in indexPhoto[j].index..<temp {
                                eachIndexsOfPhotoLocation[i].append(t)
                            }
                        } else if i == photoPoints.count-1 {
                            let temp = photoPoints[i].lastElementIndex
                            for t in indexPhoto[j].index...temp{
                                eachIndexsOfPhotoLocation[i].append(t)
                            }
                            
                        }
                        
                        print("***************************************************************************")
                        print("***************************************************************************")
                        print("***************************************************************************")
                        print(eachIndexsOfPhotoLocation)
                        print("***************************************************************************")
                        print("***************************************************************************")
                        print("***************************************************************************")
                        arrayOfIndexPhoto.append(String(describing: indexPhoto[j].index))
                        
                        if j == 0 {
                            
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                            let url = URL(fileURLWithPath: path)
                            
                            print(url.appendingPathComponent("\(String(describing: indexPhoto[j].index)).jpeg").path)
                            
                            let filePath = url.appendingPathComponent("\(String(describing: indexPhoto[j].index)).jpeg").path
 
                            
                            if FileManager.default.fileExists(atPath: filePath) {
                                print("goes in here")
                                //if var photoTaken = UIImage(contentsOfFile: filePath){
                                    //photoTaken = photoTaken.resized(toWidth: 50)!
                                    /*
                                     let options : [NSObject:AnyObject] = [
                                     kCGImageSourceCreateThumbnailWithTransform: true as AnyObject,
                                     kCGImageSourceCreateThumbnailFromImageAlways: true as AnyObject,
                                     kCGImageSourceThumbnailMaxPixelSize: 300 as AnyObject ]
                                     
                                     let source = CGImageSourceCreateWithURL(filePath as! CFURL, options as CFDictionary)
                                     let thumbnails = UIImage(cgImage: source as! CGImage)
                                     */
                                    
                                   // var photoData = Dictionary<String, Any>()
                                    //photoData["index"] = indexPhoto[0].index
                                    
                                    //print(photoTaken)
                                let photoPin = GMSMarker()
                                photoPin.isTappable = true
                                photoPin.userData = i
                                
                                photoPin.title = "\(String(describing: indexPhoto[j].index)).jpeg"
                                let markerImage = UIImage(named:"photoPin")
                                let markerView = UIImageView(image: markerImage)
                                let position = CLLocationCoordinate2D(latitude: photoPoints[i].latitude, longitude: photoPoints[i].longitude)
                                markerPinConfig(marker: photoPin, imageView: markerView, position: position)
                                    
                                //}
                            }
                        }
                        
                    }
                }

            }
            
        }
        
        
        
    }
    
    

    
    func DrawPath(){
        
        
        var bounds = GMSCoordinateBounds()
        
        guard let locations = ride?.locations,
            locations.count > 0
            else {
                let alert = UIAlertController(title: "Error", message: "Sorry, this run has no locations saved", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }
        
        let locationPoints = ride?.locations?.array as! [Locations]
        
        
        

        for i in 0..<locationPoints.count{
            let eachSpeed = Double((locationPoints[i].speed as Double)*(1/1000)*(1/1.61)*(3600)).rounded(toPlaces: 2)
            let lat = locationPoints[i].latitude
            let long = locationPoints[i].longitude
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
            if i == 0{
                let startPointMapPin = GMSMarker()
                startPointMapPin.title = "Start"
                let markerImage = UIImage(named: "startPin")
                //creating a marker view
                let markerView = UIImageView(image: markerImage)
                markerPinConfig(marker: startPointMapPin, imageView: markerView, position: position)

                
            } else if i == locationPoints.count - 1{
                let endPointMapPin = GMSMarker()
                endPointMapPin.title = "end"
                let markerImage = UIImage(named: "endPin")
                //creating a marker view
                let markerView = UIImageView(image: markerImage)
                markerPinConfig(marker: endPointMapPin, imageView: markerView, position: position)

            }
            
            path.add(position)
            bounds = bounds.includingPath(path)
            // Draw colored segments on the map
            drawColoredSegments(speed: eachSpeed)
        }
        
        
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 40)
            //GMSCameraUpdate.fit(bounds, with: UIEdgeInsets.zero)

        mapView.animate(with: update)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.geodesic = true
        polyline.spans = arrayOfSegementColor
        polyline.map = self.mapView
        
        
    }
    /*
    func polyline() -> [MulticolorPolyline] {
        let locations = ride?.locations?.array as! [Locations]
        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = Double.greatestFiniteMagnitude
        var maxSpeed = 0.0
        
        for (first, second) in zip(locations, locations.dropFirst()) {
            let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
            let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
            coordinates.append((start,end))
            
            let distance = end.distance(from: start)
            let time = second.timestamp!.timeIntervalSince(first.timestamp!)
            let speed = time > 0 ? distance / time : 0
            speeds.append(speed)
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)
        }
        let avgSpeed = speeds.reduce(0, +) / Double(speeds.count)
        
        var segments: [MulticolorPolyline] = []
        for ((start, end), speed) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            //let segment =
        }
    }
    */
    func drawColoredSegments(speed: Double) {
        
        
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
        
        
        //bike speed
        /*
        if speed < 5 && speed >= 0 {
            arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidRed))
        } else if speed >= 5 && speed < 10 {
            
            arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.redToYellow))
        } else if speed >= 10 && speed < 13 {
            arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidYellow))
        } else if speed >= 13 && speed < 15 {
            arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.yellowToGreen))
        } else if speed >= 15 {
            arrayOfSegementColor.append(GMSStyleSpan(style: MulticolorPolyline.solidGreen))
        }
         */
        
    }
    
    
    func markerPinConfig(marker: GMSMarker, imageView: UIImageView, position: CLLocationCoordinate2D){
        
        marker.iconView = imageView
        marker.layer.cornerRadius = 25
        marker.position = position
        marker.opacity = 1
        marker.infoWindowAnchor.y = 1
        marker.map = mapView
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.isTappable = true
        
    }
    
    
    
    func clearData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            
            context.delete(ride!)
            
            try(context.save())
            
        } catch {
            print("Error with request: \(error)")
            
        }
        
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
            
            view.setNeedsDisplay()
            view.setNeedsLayout()
            /*
             // Align the label to the touch left position, centered
             var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
             
             // Avoid placing the label on the left of the chart
             if constant < labelLeadingMarginInitialConstant {
             constant = labelLeadingMarginInitialConstant
             }
             
             // Avoid placing the label on the right of the chart
             let rightMargin = chart.frame.width - label.frame.width
             if constant > rightMargin {
             constant = rightMargin
             }
             
             labelLeadingMarginConstraint.constant = constant
             */
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DrawPath()
        DrawPhotoPin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        navigationItem.titleView = nameOfTheRoute
        
        
        let item = UIBarButtonItem(customView: deleteButton)
        let item1 = UIBarButtonItem(customView: shareButton)
        
        //let item2 = UIBarButtonItem(customView: backButton)
        let backButton = UIBarButtonItem(customView: self.backButton)
        navigationItem.rightBarButtonItems = [item, item1]
        navigationItem.leftBarButtonItem = backButton
        
        
        
        view.addSubview(mapView)
        
        
        mapView.addSubview(maximizeMapButton)
        
        //_ = maximizeMapButton.anchor(mapView.topAnchor, left: nil, bottom: nil, right: mapView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 30, heightConstant: 30)
        
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
        view.addSubview(maxElevationLabel)
        
        
        // Average Moving Speed
        view.addSubview(heartRateLabel)
        
        
        // Gain Elevation
        view.addSubview(gainElevationLabel)
        
        // Address
        view.addSubview(addressLabel)
        
        
        
        //_ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 80, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 250)
        
        _ = dateLabel.anchor(scrollViewPagingControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = distanceLabel.anchor(dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        
        _ = averageSpeedLabel.anchor(distanceLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = heartRateLabel.anchor(timeLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = maxElevationLabel.anchor(averageSpeedLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
    
        _ = gainElevationLabel.anchor(heartRateLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = addressLabel.anchor(maxElevationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        
        
        
        
        view.addSubview(carouselView)
        
        initializedElevationChart()
        initializedSpeedChart()
        initializedHeartRateChart()
        
    }
    
}

