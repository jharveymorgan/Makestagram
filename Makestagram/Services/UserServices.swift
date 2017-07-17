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
        let ref = DatabaseReference.toLocation(.showUser(uid: uid))
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
        let userAttrs: [String: Any] = ["username": username, "follower_count": 0, "following_count": 0, "post_count": 0]
        
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
        let ref = DatabaseReference.toLocation(.posts(uid: user.uid))
        
        ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            // ???: DON'T COMPLETELY UNDERSTAND:
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
    
    // get all users of the app
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        
        // path to read all users in Firebase
        let ref = Database.database().reference().child("users")
        
        // read users node from the database
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return completion([]) }
            
            
            // ??? REVIEW
            // convert all elements into User and filter out the current user
            let users = snapshot.flatMap(User.init).filter { $0.uid != currentUser.uid }
            
            // new dispatch group to know when asynch tasks are done
            let dispatchGroup = DispatchGroup()
            
            users.forEach { (user) in
                dispatchGroup.enter()
                
                // make a request for each user and see if the user is being followed by the current user
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
            }
            
            // run completion block when all the follow/relationship data has come back
            dispatchGroup.notify(queue: .main, execute: { completion(users) })
        })
    }
    
    // get all of give user's followers UIDs and return them as a string array
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        let followersRef = Database.database().reference().child("followers").child(user.uid)
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String: Bool] else { return completion([]) }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
    
    // get current user's timeline data and return an array of Posts
    static func timeline(completion: @escaping ([Post]) -> Void) {
        let currentUser = User.current
        
        let timelineRef = Database.database().reference().child("timeline").child(currentUser.uid)
        timelineRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String: Any], let posterUID = postDict["poster_uid"] as? String else
                { continue }
                
                dispatchGroup.enter()
                
                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: { completion(posts.reversed()) })
        })
    }
    
    // get content for user's profile, user object and all of the user's posts
    static func observeProfile(for user: User, completion: @escaping (DatabaseReference, User?, [Post]) -> Void) -> DatabaseHandle {
        // path to where user object is read from
        let userRef = DatabaseReference.toLocation(.showUser(uid: user.uid))
        
        // observer to get user object
        return userRef.observe(.value, with: { snapshot in
            // check if data is a valid user, if not return an an empty completion block
            guard let user = User(snapshot: snapshot) else { return completion(userRef, nil, []) }
            
            // get all posts for the respective user
            posts(for: user, completion: { posts in
                // if successful, return a completion block with reference to the Database Reference, user, and posts
                completion(userRef, user, posts)
            })
        })
    }
    
}// end struct
