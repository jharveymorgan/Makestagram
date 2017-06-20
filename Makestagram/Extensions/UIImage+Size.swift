//
//  UIImage+Size.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

extension UIImage {
    var aspectHeight: CGFloat {
        let heightRatio = size.height/736
        let widthRatio = size.width/414
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return size.height/aspectRatio
    }
}
