//
//  HistoryDetailViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/4/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit



//
class HistoryDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{

    
    var ride: Ride? {
        didSet{
            navigationItem.title = ride?.name
        
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
    }

}
