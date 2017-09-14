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


// UICollectionViewController, UICollectionViewDelegateFlowLayout
class HistoryDetailViewController: UIViewController, GMSMapViewDelegate{
    
    
    fileprivate let path = GMSMutablePath()
    
    lazy var elevationData = [Double]()
    lazy var elevationTempLables = [CLLocation]()
    lazy var elevationLabels = [String]()
    
    
    var ride: Ride? {
        didSet{
            navigationItem.title = ride?.name
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
            
            let distance = Measurement(value: (ride?.distance)!, unit: UnitLength.meters)
            let seconds = Int((ride?.duration)!)
            //let movingSeconds = Int((ride?.movingduration)!)
            let formattedDistance = FormatDisplay.distance(distance)
            let formattedDate = FormatDisplay.date(ride?.timestamp as Date?)
            let formattedTime = FormatDisplay.time(seconds)
            let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: .milesPerHour)
            //let formattedMovingPace = FormatDisplay.pace(distance: distance, seconds: movingSeconds, outputUnit: .milesPerHour)
            guard let address = ride?.address else { return }
            guard let heartRate = ride?.heartrate else { return }
                        
            dateLabel.text = "Date: \(formattedDate)"
            distanceLabel.text = "Distance: \(formattedDistance)"
            timeLabel.text = "Time: \(formattedTime)"
            averageSpeedLabel.text = "Avg 🚴🏼: \(formattedPace)"
            heartRateLabel.text = "Avg ❤️ Rate: \(heartRate) bpm"
            addressLabel.text = "Region: \(address)"
            
            DrawPath()
            
        }
    }
    
    
    
    
    lazy var graphView: ScrollableGraphView = {
        var view = ScrollableGraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.white
        return view
    }()
    
    
    let mapView: GMSMapView = {
        
        let view = GMSMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.mapType = .normal
        view.layer.cornerRadius = 5
        view.setMinZoom(5, maxZoom: 18)
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        button.setTitle("<Back", for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(goBackToMain), for: .touchUpInside)
        return button
    }()
    
    
    func goBackToMain() {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "deleteButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        button.addTarget(self, action: #selector(alertView), for: .touchUpInside)
        
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "shareButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        button.addTarget(self, action: #selector(shareInfoAndExport), for: .touchUpInside)
        
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
    
    var addressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        
        return label
    }()
    
    
    
    
    func shareInfoAndExport() {
        
        let exportString = createExportString()
        
        saveAndExport(exportString: exportString)
        
    }
    
    func saveAndExport(exportString: String) {
        
        var name: String?
        if let titleName = ride?.name{
            name = titleName
        }
        //NSTemporaryDirectory()
        
        //Temporary I save csv file to the desktop to see if it is really export
        let exportFilePath = "/Users/Moses/Desktop/" + "\(name!).csv"
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
            export += addressOptional + ","
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
        
        
        
        
        //export += "\(name), \(date), \(address), \(duration), \(totalDistance), \(averageSpeed) \n"
        return export
    }
    
    func alertView() {
        
        let alertController = UIAlertController(title: "Delete this route?", message: "Are you sure?", preferredStyle: .alert)
        let titleFont: [String:AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        let messageFont: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        
        let attributedTitle = NSMutableAttributedString(string: "Delete this route?", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "Are you sure?", attributes: messageFont)
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let deleteButton = UIAlertAction(title: "Delete", style: .default) {
            _ in
            self.moveToRefreshedHistory()
            self.clearData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.view.tintColor = UIColor.DTIBlue()
        alertController.view.layer.cornerRadius = 25
        alertController.view.backgroundColor = UIColor.darkGray
        
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
        
        
    }
    func moveToRefreshedHistory() {
        //self.performSegue(withIdentifier: .history, sender: self)
        
        //_ = navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func drawGraph() {
    
        let locationPoints = ride?.locations?.array as! [Locations]
        
        for i in 0..<locationPoints.count{
            if locationPoints[i].elevation > 0 {
                let elevation = locationPoints[i].elevation
                let lat = locationPoints[i].latitude
                let long = locationPoints[i].longitude
                let position = CLLocation(latitude: lat, longitude: long)
                
                print(elevation)
                elevationTempLables.append(position)
                
                elevationData.append(elevation)
            }
            
        }
        
        var cumulativeDistance = 0.0
        
        print("******************************************************************************************************************************************************************************")
        
        for i in 0..<elevationTempLables.count {
            if i == 0 {
                self.elevationLabels.append(String(format: "%.1f", 0.0))
                
            } else {
                cumulativeDistance += self.elevationTempLables[i].distance(from: self.elevationTempLables[i-1])
                let cumulativeDistanceInMiles = ((cumulativeDistance/1000.0)/1.61)
                //self.elevationLabels.append(String(format: "%.1f", cumulativeDistance))
                self.elevationLabels.append(String(format: "%.1f", cumulativeDistanceInMiles))
            }
            
        }
        
        graphView.set(data: elevationData, withLabels: elevationLabels)
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
            let lat = locationPoints[i].latitude
            let long = locationPoints[i].longitude
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            
            if i == 0{
                
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
                
            } else if i == locationPoints.count - 1{
                
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
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 1)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.geodesic = true
        polyline.strokeColor = UIColor(red:0.14, green:0.17, blue:0.17, alpha:1.00)
        polyline.map = self.mapView
        
        
        mapView.animate(with: update)
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let item = UIBarButtonItem(customView: deleteButton)
        let item1 = UIBarButtonItem(customView: shareButton)
        
        //let item2 = UIBarButtonItem(customView: backButton)
        let backButton = UIBarButtonItem(customView: self.backButton)
        navigationItem.rightBarButtonItems = [item, item1]
        navigationItem.leftBarButtonItem = backButton
        
        
        
        graphView = Graph.createDarkGraph(CGRect(x: 0, y: 0, width: view.frame.width-20, height: 200))
        
        
        view.addSubview(mapView)
        
        
        // Graph
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
        view.addSubview(heartRateLabel)
        
        // Address
        view.addSubview(addressLabel)
        
        
        _ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 80, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 250)
        
        
        _ = graphView.anchor(mapView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 180)
        
        _ = dateLabel.anchor(graphView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = distanceLabel.anchor(dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        
        _ = averageSpeedLabel.anchor(distanceLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 5, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        _ = heartRateLabel.anchor(timeLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 10, widthConstant: (view.frame.width/2)-20, heightConstant: 20)
        
        
        _ = addressLabel.anchor(averageSpeedLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: view.frame.width-20, heightConstant: 20)
        
        drawGraph()
        
    }
    
}

