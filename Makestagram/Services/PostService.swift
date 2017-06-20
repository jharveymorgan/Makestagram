//
//  PostService.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    
    static func create(for image: UIImage) {
        let imageRef = Storage.storage().reference().child("test-image.jpg")
        StorageService.uploadImage(image, at: imageRef) { (downloadURL)  in
            guard let downloadURL = downloadURL else { return }
            
            let urlString = downloadURL.absoluteString
            print("image url: \(urlString)")
        }
    
    }


}
