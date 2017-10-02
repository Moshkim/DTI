//
//  SettingViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/2/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit


class SettingViewController: UIViewController{
    
    let userDefaults = UserDefaults.standard
    var switchOn: Bool = true

    // MARK: - Back Button ****************************************************************************************************************
    lazy var backToHome: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle("<Back", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.isHighlighted = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(moveBack), for: .touchUpInside)
        return button
    }()
    
    @objc func moveBack() {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // ************************************************************************************************************************************
    
    
    // MARK: - History List Sort Type Setting *********************************************************************************************
    
    lazy var historyListSortTypeSetting: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Distance", "Date"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        if userDefaults.value(forKey: "historyListSortType") as! String == "Distance"{
            segment.selectedSegmentIndex = 0
        } else {
            segment.selectedSegmentIndex = 1
        }
        
        segment.addTarget(self, action: #selector(historySortType), for: .valueChanged)
        return segment
    }()
    
    @objc func historySortType(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            userDefaults.set("Distance", forKey: "historyListSortType")
        case 1:
            userDefaults.set("Date", forKey: "historyListSortType")
        default:
            break
        }
        
    }
    // ************************************************************************************************************************************
    
    
    // MARK: - Weather Setting*************************************************************************************************************
    var weatherLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        label.text = "Weather Enable"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    lazy var weatherSwitch: UISwitch = {
        let switchBar = UISwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        switchBar.addTarget(self, action: #selector(checkState), for: .valueChanged)
        return switchBar
    }()
    
    
    func setTheWeatherSwitch() {
        if userDefaults.value(forKey: "switchOn") != nil {
            switchOn = userDefaults.value(forKey: "switchOn") as! Bool
            if switchOn == true {
                weatherSwitch.isOn = true
            
            } else if switchOn == false {
                weatherSwitch.isOn = false
            }
        
        } else {
            weatherSwitch.isOn = true
            userDefaults.set(true, forKey: "switchOn")
        }
    }
    
    @objc func checkState(_ sender: UISwitch) {
        if sender.isOn {
            switchOn = true
            userDefaults.set(switchOn, forKey: "switchOn")
        }
        if sender.isOn == false {
            switchOn = false
            userDefaults.set(switchOn, forKey: "switchOn")
        }
    }
    
    
    //************************************************************************************************************************************
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setTheWeatherSwitch()
        
        
        view.addSubview(backToHome)
        view.addSubview(weatherLabel)
        view.addSubview(weatherSwitch)
        
        view.addSubview(historyListSortTypeSetting)
        
        
        
        _ = backToHome.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 30)
        
        _ = weatherLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 40)
        weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        weatherLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        _ = weatherSwitch.anchor(weatherLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 40)
        weatherSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        _ = historyListSortTypeSetting.anchor(weatherSwitch.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 50)
        historyListSortTypeSetting.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Do any additional setup after loading the view.
    }

}
