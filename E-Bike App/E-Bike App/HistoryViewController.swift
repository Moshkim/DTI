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
    
    //rideStatusViewSegue
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.black
        UIApplication.shared.statusBarStyle = .lightContent
        
        navigationItem.title = "History"
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        

        collectionView?.register(RideCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.alwaysBounceHorizontal = false

        loadData()
        //clearData()
        
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
            
            let formattedDistance = FormatDisplay.distance((ride?.distance)!)
            distance.text = formattedDistance
            
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
        
        let locationPoints = ride.locations?.array as! [Locations]
        
        for i in 0..<locationPoints.count{
            let lat = locationPoints[i].latitude
            let long = locationPoints[i].longitude
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            path.add(position)
            bounds = bounds.includingPath(path)
            
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 15.0)
        
        let polyline = GMSPolyline(path: path)
        polyline.geodesic = true
        polyline.strokeWidth = 1
        polyline.strokeColor = UIColor.DTIRed()
        polyline.map = self.mapView
        
        
        mapView.animate(with: update)
        
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
        
        addSubview(lightBackgroundView)
        addSubview(mapView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        
        // light Background image constraints
        addConstraintsWithFormat(format: "H:|[v0]|", views: lightBackgroundView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: lightBackgroundView)
        
        
        // mapView constraints in the UICollectionView
        addConstraintsWithFormat(format: "H:|-10-[v0(80)]|", views: mapView)
        addConstraintsWithFormat(format: "V:[v0(80)]", views: mapView)
        
        addConstraints([NSLayoutConstraint(item: mapView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])

        // dividerLineView constraints in the UICollectionView
        addConstraintsWithFormat(format: "H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)

        
        //loadData()
        
        
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
        
        
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(100)]|", views: nameOfTheRoute)
        containerView.addConstraintsWithFormat(format: "V:|-10-[v0(20)]|", views: nameOfTheRoute)
        
        
        
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(100)]|", views: distance)
        containerView.addConstraintsWithFormat(format: "V:|-40-[v0(20)]|", views: distance)
        
        
        
        containerView.addConstraintsWithFormat(format: "H:|-120-[v0(150)]|", views: dateOfRoute)
        containerView.addConstraintsWithFormat(format: "V:|-40-[v0(20)]|", views: dateOfRoute)
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
