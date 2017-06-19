//
//  ResizeImage.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/9/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import UIKit


class ResizingImage: UIView {
    
    func resizeImageWith(image: UIImage, newSize: CGSize) -> UIImage {
        guard image.size != newSize else { return image }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
