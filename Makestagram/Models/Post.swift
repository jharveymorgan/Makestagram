//
//  Post.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post {
    // MARK: - Properties
    var key: String?
    let imageURL: String
    let imageHeight: CGFloat
    let creationDate: Date
    
    // MARK: - Init
    init(imageURL: String, imageHeight: CGFloat) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
    }

    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        
        return ["image_url": imageURL, "image_height": imageHeight, "created_at": createdAgo]
    }
}
