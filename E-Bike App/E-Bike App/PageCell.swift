//
//  PageCell.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/12/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var page: Page? {
        didSet {
            
            guard let page = page else {
                return
            }
        
            imageView.image = UIImage(named: page.imageName)
            
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedStringKey.foregroundColor:UIColor.DTIBlue()])
            
            attributedText.append(NSAttributedString(string: "\n\n\(page.Message)", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:UIColor.DTIBlue()]))
            
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.alignment = .center
            
            let length = attributedText.string.characters.count
            
            attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))
            
            textView.attributedText = attributedText
        }
    
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .yellow
        iv.image = UIImage(named: "page1")
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "This is Sample"
        tv.isEditable = false
        tv.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        return tv
    }()
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.DTIRed().withAlphaComponent(1)
        return view
    }()
    
    
    
    func setupView() {
        addSubview(imageView)
        addSubview(textView)
        addSubview(lineSeparatorView)
        
        
        imageView.anchorToTop(top: topAnchor, left: leftAnchor, bottom: textView.topAnchor, right: rightAnchor)
        
        //textView.anchorToTop(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        textView.anchorWithConstantsToTop(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15)
        
        textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25).isActive = true
        
        
        lineSeparatorView.anchorToTop(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        lineSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
