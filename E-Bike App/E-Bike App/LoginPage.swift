//
//  LoginPage.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/13/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit


class LoginPage: UICollectionViewCell {

    
    //let animateButton: TransitionSubmitButton
    
    let wholeView: UIImageView = {
        let image = UIImage(named: "atom")
        let imageView = UIImageView(image: image)
        //imageView.center =
        imageView.frame(forAlignmentRect: .zero)
        imageView.layer.zPosition = -1
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    
    }()
    

    
    let logoImageView: UIImageView = {
        let image = UIImage(named: "logo")
        let imageClicked = UIImage(named: "logoClicked")
        let imageView = UIImageView(image: image)
        
        
        return imageView
    }()
    
    let emailTextField: UITextField = {
        let text = LeftPaddingTextField()
        text.placeholder = "Enter Email"
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.layer.borderWidth = 1
        text.keyboardType = .emailAddress
        return text
        
    }()
    
    let passwordTextField: UITextField = {
        let password = LeftPaddingTextField()
        password.placeholder = "Enter Password"
        password.layer.borderColor = UIColor.lightGray.cgColor
        password.layer.borderWidth = 1
        password.isSecureTextEntry = true
        return password
        
    }()
    

    

    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        //let Text = NSMutableAttributedString(string: "Log In", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 10), NSForegroundColorAttributeName:UIColor.DTIRed()])
        button.layer.cornerRadius = 30
        button.backgroundColor = UIColor.DTIBlue()
        
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(UIColor.DTIRed(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.shadowColor = UIColor.darkGray
        
        
        //button.addTarget(self, action: #selector(loginButtonFunc), for: .touchUpInside)
        
        return button
    }()
    
    
    func loginButtonFunc(sender: UIButton) {
        let username = emailTextField.text
        let password = passwordTextField.text
        
        if (username == "" || password == "") {
        
            return
        }
        
        //DoLogin(username!, password!)
        print("wow")
    
    }
    
    func DoLogin(_ user: String, _ psw: String){
        /*
        
        let url = URL(string: "http://www.kaleidosblog.com/tutorial/login/api/login")
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        let paramToSend = "username=" + user + "&password=" + psw
        
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        //request.httpMethod = paramToSend.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
        (data, response, error) in
        
            guard let _ = data else {
            
                return
            }
            
            let json:Any?
            
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            
            } catch {
            
                return
            }
            
            guard let server_response = json as? NSDictionary else {
                return
            }
            
            if let data_block = server_response["data"] as? NSDictionary{
            
                if let session_data = data_block["session"] as? String {
                
                    let preferences = UserDefaults.standard
                    preferences.set(session_data, forKey: "session")
                    
                    DispatchQueue.main.async {
                        //execute:self.LoginDone
                    }
                }
            
            }
            
            
        })
        task.resume()
         */
    
        
    }
    
    func LoginToDo() {
    
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        
        loginButton.setTitle("Login", for: .normal)
    }
 
    func LoginDone() {
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        
        loginButton.setTitle("Logout", for: .normal)
    
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(wholeView)
        addSubview(logoImageView)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        //addSubview(loginButton)
        //addSubview(animateButton)
        
        /*
        let preference = UserDefaults.standard
        
        if (preference.object(forKey: "session") != nil){
            LoginDone()
        } else {
        
            LoginToDo()
        }
        */
        
        let blurrEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurrEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        let blurrView = UIVisualEffectView(effect: blurrEffect)
        
        blurrView.frame = self.bounds
        blurrView.layer.zPosition = -1
        blurrView.contentMode = .scaleAspectFit
        blurrView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurrView)
        addSubview(vibrancyView)
        
        
        
        
        
        //addSubview(moveToMapButton)
        
        
        _ = logoImageView.anchor(centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: -200, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 160)
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = emailTextField.anchor(logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 50)
        
        _ = passwordTextField.anchor(emailTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 50)
        
        //_ = loginButton.anchor(passwordTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 50)
        
        
        //_ = animateButton.anchor(loginButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 60)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}


class LeftPaddingTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
    
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }

}
