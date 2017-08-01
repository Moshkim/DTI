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
    
    var context: NSManagedObjectContext!

    var listOfRoute: [Ride] = []
    
    
    private let cellId = "cellId"
    

    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .default
        
        navigationItem.title = "History"
        
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        
        
        
        
        
        
        //collectionView?.backgroundColor = UIColor.DTIRed()
        collectionView?.register(RideCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.alwaysBounceHorizontal = true
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
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

    
    
    
    
    let nameOfTheRoute: UILabel = {
        let name = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        name.text = "MoMo Trip1"
        name.textColor = UIColor.white
        return name
    }()
    
    
    
    let dateOfRoute: UILabel = {
        let date = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        date.textColor = UIColor.white
        date.text = "1 July, 2017"
        return date
        
    }()
    
    let distance: UILabel = {
        let totalLength = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        totalLength.textColor = UIColor.white
        totalLength.text = "30 mph"
        return totalLength
    }()
    
    let timeStamp: UILabel = {
        let time = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        time.textColor = UIColor.white
        return time
        
    }()

    let mapView: GMSMapView = {
        let map = GMSMapView()
        map.contentMode = .scaleAspectFill
        map.mapType = .normal
        map.setMinZoom(5, maxZoom: 18)
        map.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        map.layer.cornerRadius = 25
        return map
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.DTIRed().cgColor
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    override func setupViews() {
        backgroundColor = UIColor(red:0.95, green:0.95, blue:0.96, alpha:1.00)
        
        addSubview(mapView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        
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
        containerView.backgroundColor = UIColor.DTIRed()
        addSubview(containerView)
    
        addConstraintsWithFormat(format: "H:|-100-[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(80)]", views: containerView)
        
        addConstraints([NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
        
        
        containerView.addSubview(nameOfTheRoute)
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(100)]|", views: nameOfTheRoute)
        containerView.addConstraintsWithFormat(format: "V:|-10-[v0(20)]|", views: nameOfTheRoute)
        
        
        containerView.addSubview(distance)
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(50)]|", views: distance)
        containerView.addConstraintsWithFormat(format: "V:|-40-[v0(10)]|", views: distance)
        
        
        containerView.addSubview(dateOfRoute)
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0(100)]|", views: dateOfRoute)
        containerView.addConstraintsWithFormat(format: "V:|-10-[v0(10)]|", views: dateOfRoute)
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
