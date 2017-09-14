//
//  HistoryViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 7/31/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import CoreData

class HistoryViewController: UICollectionViewController, GMSMapViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var location: [Locations]?
    
    var arrayRide: [Ride]?
    
    
    private let cellId = "cellId"
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = arrayRide?.count {
            return count
        }
        return 0
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RideCell
        if let ride = arrayRide?[indexPath.item]{
            cell.ride = ride
            
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let layout = UICollectionViewFlowLayout()
        //let controller = HistoryDetailViewController(collectionViewLayout: layout)
        let control = HistoryDetailViewController()
        control.ride = arrayRide?[indexPath.item]
        navigationController?.pushViewController(control, animated: true)
        
    }
    
    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        button.backgroundColor = UIColor.clear
        button.setTitle("<Back", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(backToMainRideStatusView), for: .touchUpInside)
        
        return button
    }()
    
    func backToMainRideStatusView() {
        
        print("clicking!")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    let segmentedControl: UISegmentedControl = {
        
        let segment = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        segment.insertSegment(withTitle: "Time", at: 0, animated: true)
        segment.insertSegment(withTitle: "Distance", at: 1, animated: true)
        let font = UIFont.systemFont(ofSize: 10)
        segment.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segment.selectedSegmentIndex = 0
        segment.tintColor = UIColor.white
        segment.backgroundColor = UIColor.clear
        segment.layer.cornerRadius = 5.0
        segment.layer.borderColor = UIColor.white.cgColor
        segment.layer.borderWidth = 1
        
        
        //segment.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        return segment
    }()
    
    
    lazy var fetchedResultesController: NSFetchedResultsController = { () -> NSFetchedResultsController<Ride> in
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    
    func changeDataSort(sender: UISegmentedControl){
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        
        
        
        if sender.selectedSegmentIndex == 0{
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            do {
                arrayRide?.removeAll()
                arrayRide = try context.fetch(fetchRequest)
                
                fetchedResultesController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
                
                
                //try frc.performFetch()
                self.collectionView?.reloadData()
                
                
                
            } catch {
                print("Error with request: \(error)")
                
            }
            
        }
        else if sender.selectedSegmentIndex == 1{
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: false)]
            
            do {
                arrayRide?.removeAll()
                arrayRide = try context.fetch(fetchRequest)
                fetchedResultesController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: false)]
                
                
                //try frc.performFetch()
                self.collectionView?.reloadData()
                
            } catch {
                print("Error with request: \(error)")
                
            }
            
        }
        else {
            print("There is an error")
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            try fetchedResultesController.performFetch()
            
        } catch {
            
            print("There was an error")
        }
        
        collectionView?.backgroundColor = UIColor.black
        UIApplication.shared.statusBarStyle = .lightContent
        
        navigationItem.title = "History"
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        //navigationItem.titleView = segmentedControl
        
        
        let item = UIBarButtonItem(customView: segmentedControl)
        let backButton = UIBarButtonItem(customView: self.backButton)
        navigationItem.setRightBarButton(item, animated: true)
        navigationItem.leftBarButtonItem = backButton
        
        
        collectionView?.register(RideCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.alwaysBounceHorizontal = false
        
        loadData()
        //clearData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    
    
    
    
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    
    
    //var numberOfHistory = Int()
    
    func loadData() {
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            arrayRide = try context.fetch(fetchRequest)
            
        } catch {
            print("Error with request: \(error)")
            
        }
        
        
    }
    
    func clearData() {
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        
        do {
            let Rides = try context.fetch(fetchRequest)
            
            for ride in Rides {
                context.delete(ride)
                
            }
            
            try(context.save())
            
        } catch {
            print("Error with request: \(error)")
            
        }
        
    }
    
    
    
    
    /*
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return listItems.count
     }
     
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
     let item = listItems[indexPath.row]
     
     print(item)
     cell.textLabel?.text = ride.name! as String
     return cell
     }
     */
    
}



class RideCell: BaseCells {
    
    fileprivate let path = GMSMutablePath()
    
    var ride: Ride? {
        
        didSet{
            
            nameOfTheRoute.text = ride?.name
            
            if let date = ride?.timestamp {
                let formatedDate = FormatDisplay.date(date as Date?)
                dateOfRoute.text = formatedDate
            }
            
            let dist = Measurement(value: (ride?.distance)!, unit: UnitLength.meters)
            let seconds = Int((ride?.duration)!)
            let formattedDistance = FormatDisplay.distance((ride?.distance)!)
            let formattedTime = FormatDisplay.time(seconds)
            
            distance.text = formattedDistance
            averageSpeed.text = FormatDisplay.pace(distance: dist, seconds: seconds, outputUnit: .milesPerHour)
            duration.text = formattedTime
            DrawPath(ride: ride!)
            
            
        }
        
    }
    
    
    func DrawPath(ride: Ride){
        
        
        var bounds = GMSCoordinateBounds()
        
        guard let locations = ride.locations,
            locations.count > 0
            else {
                /*
                 let alert = UIAlertController(title: "Error", message: "Sorry, this run has no locations saved", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                 present(alert, animated: true)*/
                print("Error")
                return
        }
        
        if let locationPoints = ride.locations?.array as! [Locations]? {
            for i in 0..<locationPoints.count{
                let lat = locationPoints[i].latitude
                let long = locationPoints[i].longitude
                let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                path.add(position)
                bounds = bounds.includingPath(path)
                
            }
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: 0.5)
            
            let polyline = GMSPolyline(path: path)
            polyline.geodesic = true
            polyline.strokeWidth = 1
            polyline.strokeColor = UIColor.DTIRed()
            polyline.map = self.mapView
            
            
            mapView.animate(with: update)
            
        }
        
    }
    
    let nameOfTheRoute: UILabel = {
        let name = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        //name.text = "MoMo Trip1"
        name.textColor = UIColor.white
        return name
    }()
    
    
    
    let dateOfRoute: UILabel = {
        let date = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        date.textColor = UIColor.white
        //date.text = "1 July, 2017"
        return date
        
    }()
    
    var distance: UILabel = {
        let totalLength = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        totalLength.textColor = UIColor.white
        //totalLength.text = "30 mph"
        return totalLength
    }()
    
    
    var averageSpeed: UILabel = {
        let speed = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        speed.textColor = UIColor.white
        //totalLength.text = "30 mph"
        return speed
    }()
    
    var duration: UILabel = {
        let second = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        second.textColor = UIColor.white
        //totalLength.text = "30 mph"
        return second
    }()
    
    let timeStamp: UILabel = {
        let time = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        time.textColor = UIColor.white
        return time
        
    }()
    
    let mapView: GMSMapView = {
        let map = GMSMapView()
        map.mapType = .normal
        map.setMinZoom(5, maxZoom: 30)
        map.contentMode = .scaleAspectFit
        //map.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        map.layer.cornerRadius = 25
        return map
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.DTIRed().cgColor
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    
    let lightBackgroundView: UIImageView = {
        
        let image = UIImage(named: "light")
        let imageView = UIImageView(image: image)
        imageView.layer.zPosition = 0
        imageView.contentMode = .scaleToFill
        imageView.layer.opacity = 0.5
        return imageView
    }()
    
    override func setupViews() {
        backgroundColor = UIColor.black
        //UIColor(red:0.95, green:0.95, blue:0.96, alpha:1.00)
        
        //addSubview(lightBackgroundView)
        addSubview(mapView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        
        // light Background image constraints
        //addConstraintsWithFormat(format: "H:|[v0]|", views: lightBackgroundView)
        //addConstraintsWithFormat(format: "V:|[v0]|", views: lightBackgroundView)
        
        
        // mapView constraints in the UICollectionView
        addConstraintsWithFormat(format: "H:|-10-[v0(80)]|", views: mapView)
        addConstraintsWithFormat(format: "V:[v0(80)]", views: mapView)
        
        addConstraints([NSLayoutConstraint(item: mapView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
        
        // dividerLineView constraints in the UICollectionView
        addConstraintsWithFormat(format: "H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
        
        
        
    }
    
    fileprivate func setupContainerView() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        addSubview(containerView)
        
        addConstraintsWithFormat(format: "H:|-100-[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(80)]", views: containerView)
        
        addConstraints([NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
        
        containerView.addSubview(nameOfTheRoute)
        containerView.addSubview(distance)
        containerView.addSubview(dateOfRoute)
        containerView.addSubview(averageSpeed)
        containerView.addSubview(duration)
        
        // nameLabel constraints
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(200)]|", views: nameOfTheRoute)
        containerView.addConstraintsWithFormat(format: "V:|-5-[v0(20)]|", views: nameOfTheRoute)
        
        
        // distanceLabel constraints
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(100)]|", views: distance)
        containerView.addConstraintsWithFormat(format: "V:|-30-[v0(20)]|", views: distance)
        
        
        // date Label constraints
        containerView.addConstraintsWithFormat(format: "H:|-120-[v0(100)]|", views: dateOfRoute)
        containerView.addConstraintsWithFormat(format: "V:|-30-[v0(20)]|", views: dateOfRoute)
        
        
        // speed Label constraints
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(100)]|", views: averageSpeed)
        containerView.addConstraintsWithFormat(format: "V:|-55-[v0(20)]|", views: averageSpeed)
        
        
        // Duratin Label constraints
        containerView.addConstraintsWithFormat(format: "H:|-120-[v0(100)]|", views: duration)
        containerView.addConstraintsWithFormat(format: "V:|-55-[v0(20)]|", views: duration)
        
    }
    
}



class BaseCells: UICollectionViewCell {
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor.black
        
        
    }
    
}
