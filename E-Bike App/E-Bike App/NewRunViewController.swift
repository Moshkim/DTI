//
//  NewRunViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 7/19/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit

class NewRunViewController: UIViewController {

    
    
    
    var dataStackView: UIStackView = {
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        
        return view
    }()
    
    
    let distanceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        return label
    }()
    
    
    let timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        return label
    }()
    
    
    let paceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        return label
    }()
    
    
    
    lazy var startButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        return button
    }()
    
    
    func startTapped() {
        dataStackView.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = false
    
    }
    
    lazy var stopButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        
        button.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        
        return button
    }()
    
    func stopTapped() {
    
        dataStackView.isHidden = true
        startButton.isHidden = false
        stopButton.isHidden = true
    
    }
    
    //private var bike: Biking?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(dataStackView)
        view.addSubview(startButton)
        view.addSubview(stopButton)
        
        
        dataStackView.isHidden = true
    }
    

}
