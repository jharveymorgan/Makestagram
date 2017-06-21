//
//  UserServices.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/16/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

// for user networking code
struct UserService {
    // read/get user from Firebase Database
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    // write to Firebase Database
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        // create dictionary with username
        let userAttrs = ["username": username]
        
        // get path for where data should be stored
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        // write data at specific location
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            // read data we just wrote and create a user from the snapshot
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    // read/get all post(s) from Firebase Database
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            // DON'T COMPLETELY UNDERSTAND:
            // dispatch groups allow you to monitor the completion of a group of tasks
            // used here to notify me after all my network requests have been done
            let dispatchGroup = DispatchGroup()
            
            // check if each post is liked by the current user
            let posts: [Post] = snapshot.reversed().flatMap {
                guard let post = Post(snapshot: $0) else { return nil }
                
                dispatchGroup.enter()
                
                LikeService.isPostLiked(post) { (isLiked) in
                    post.isLiked = isLiked
                    
                    dispatchGroup.leave()
                }
                
                return post
            }
            
            dispatchGroup.notify(queue: .main, execute: { completion(posts) })
        })
    }
    
}// end struct
