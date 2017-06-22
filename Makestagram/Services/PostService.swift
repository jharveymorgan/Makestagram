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
    // upload image to Firebase Storage and get url for image
    static func create(for image: UIImage) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL)  in
            guard let downloadURL = downloadURL else { return }
            
            // add image to database and timeline
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
        
        // references to locations where data needs to be written to
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        // get array of all follower's UIDs
        UserService.followers(for: currentUser) { (followerUIDs) in
            // timeline JSON object to store the current user's uid
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            // dictionary to store all data to be written to the databse
            var updatedData: [String: Any] = ["timeline/\(currentUser.uid)/\(newPostKey)": timelinePostDict]
            
            // add current user's post to each of their follower's timeline
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // write the post we are trying to create
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // write the multi-location update to the database
            rootRef.updateChildValues(updatedData)
        }
    }
    
    // get a single post from the database
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else { return completion(nil) }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
    
    
}
