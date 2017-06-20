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
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL)  in
            guard let downloadURL = downloadURL else { return }
            
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(forURLString: urlString, aspectHeight: aspectHeight)
        }
    
    }
    
    // after upload image to storage, create new post in database
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        let currentUser = User.current
        
        // initialize a new post
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        // convert the new post object to a dictionary
        let dict = post.dictValue
        
        // get path to where we want to store new post in database and write data
        let postRef = Database.database().reference().child("posts").child(currentUser.uid).childByAutoId()
        postRef.updateChildValues(dict)
        
    }


}
