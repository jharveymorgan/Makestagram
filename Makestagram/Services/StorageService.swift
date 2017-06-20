//
//  StorageService.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit
import FirebaseStorage

struct StorageService {
    // method for uploading images to Firebase Storage
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // convert image to Data
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // upload media data via path provided
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            
            // after upload, check for error
            if let error = error  {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            // return download URL
            completion(metadata?.downloadURL())
        })
    
    }
    
    
}
