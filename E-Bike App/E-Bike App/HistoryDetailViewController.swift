//
//  HistoryDetailViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 8/4/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit



// UICollectionViewController, UICollectionViewDelegateFlowLayout
class HistoryDetailViewController: UIViewController{

    
    var ride: Ride? {
        didSet{
            navigationItem.title = ride?.name
        
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        //collectionView?.backgroundColor = UIColor.white
    }

}
