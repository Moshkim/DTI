//
//  SplashViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 5/30/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit
//import Commons


/*
open class SplashViewController: UIViewController {
    open var pulsing: Bool = false
    
    let animatedUILogoView: AnimatedUILogoView = AnimatedUILogoView(frame: CGRect(x: 0.0, y: 0.0, width: 90.0, height: 90.0))
    
    var tileGridView: TileGridView!

    public init(tileViewFileName: String) {
        super.init(nibName: nil, bundle: nil)
    
        //view.backgroundColor = UIColor(red:0.03, green:0.24, blue:0.39, alpha:1.00)
        tileGridView = TileGridView(TileFileName: tileViewFileName)
        view.addSubview(tileGridView)
        tileGridView.frame = view.bounds
        
        
        view.addSubview(animatedUILogoView)
        animatedUILogoView.layer.position = view.layer.position
        
        tileGridView.startAnimating()
        animatedUILogoView.startAnimating()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }

}
*/


open class SplashViewController: UIViewController {
    open var pulsing: Bool = false
    
    let animatedULogoView: AnimatedULogoView = AnimatedULogoView(frame: CGRect(x: 0.0, y: 0.0, width: 90.0, height: 90.0))
    var tileGridView: TileGridView!
    
    public init(tileViewFileName: String) {
        
        super.init(nibName: nil, bundle: nil)
        tileGridView = TileGridView(TileFileName: tileViewFileName)
        view.addSubview(tileGridView)
        tileGridView.frame = view.bounds
        
        view.addSubview(animatedULogoView)
        animatedULogoView.layer.position = view.layer.position
        
        tileGridView.startAnimating()
        animatedULogoView.startAnimating()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
}
