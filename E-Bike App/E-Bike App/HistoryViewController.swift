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

class HistoryViewController: UITableViewController, GMSMapViewDelegate {

    var ride: Ride!

    var listItems = [NSManagedObject]()
    
    
    let nameOfTheRoute: UILabel = {
        let name = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        return name
    }()
    
    let mapView: GMSMapView = {
        let map = GMSMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        map.mapType = .normal
        map.setMinZoom(5, maxZoom: 18)
        map.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        return map
    }()
    
    let dateOfRoute: UILabel = {
        let date = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        return date
    
    }()
    
    let distance: UILabel = {
        let totalLength = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        return totalLength
    }()
    
    let timeStamp: UILabel = {
        let time = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        return time
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
}
