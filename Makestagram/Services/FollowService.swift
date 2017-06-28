//
//  FollowService.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/21/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        // create dictionary to update multiple locations at the same time for when a user follows another user
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)": true, "following/\(currentUID)/\(user.uid)": true]
        
        // write new dictionary/relationship to firebase
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            
            // create a DispatchGroup to manage the completion of asynchronous requests
            let dispatchGroup = DispatchGroup()
            
            // each time a request is made, call enter(), to track request
            dispatchGroup.enter()
            
            // path and completion block to increment the current user's following count after following a new user
            let followingCountRef = DatabaseReference.toLocation(.showUser(uid: currentUID)).child("following_count")
            followingCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // check if value exists, then increment
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            })
            
            // make a request to track the incrementation of a user's follower count
            dispatchGroup.enter()
            // path and completion block to increment a user's follower count after getting a new follower
            let followerCountRef = DatabaseReference.toLocation(.showUser(uid: user.uid)).child("follower_count")
            followerCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // check if there is value, then increment it
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            })
            
            // use dispatch group for original request to get all of user's posts
            dispatchGroup.enter()
            // get all posts for the user that is being followed (followee)
            UserService.posts(for: user) { (posts) in
                // get all the post keys for that user
                let postKeys = posts.flatMap { $0.key }
                
                // multi-location update using dictionary that adds each of the followee's posts to the current user's timeline
                var followData = [String: Any]()
                let timelinePostDict = ["poster_uid": user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                // write the dictionary to the database
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    //
                    dispatchGroup.leave()
                })
            }
            
            // success callback after all previous requests have been completed
            dispatchGroup.notify(queue: .main) {
                success(true)
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        // create dictionary to update multiple locations at the same time for when a user unfollows another user
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)": NSNull(), "following/\(currentUID)/\(user.uid)": NSNull()]
        
        // delete dictionary/relationship to firebase
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            
            // create a DispatchGroup to manage the completion of asynchronous requests
            let dispatchGroup = DispatchGroup()
            
            // each time a request is made, call enter(), to track request
            dispatchGroup.enter()
            
            // path and completion block to increment the current user's following count after following a new user
            let followingCountRef = DatabaseReference.toLocation(.showUser(uid: currentUID)).child("following_count")
            followingCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // check if value exists, then increment
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount - 1
                
                return TransactionResult.success(withValue: mutableData)
            })
            
            // make a request to track the incrementation of a user's follower count
            dispatchGroup.enter()
            // path and completion block to increment a user's follower count after getting a new follower
            let followerCountRef = DatabaseReference.toLocation(.showUser(uid: user.uid)).child("follower_count")
            followerCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // check if there is value, then increment it
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount - 1
                
                return TransactionResult.success(withValue: mutableData)
            })
            
            // use dispatch group for original request to get all of user's posts
            dispatchGroup.enter()
            
            // get all posts for the user that is being unfollowed (unfollowee)
            UserService.posts(for: user) { (posts) in
                
                // multi-location update using dictionary that deletes each of the unfollowee's posts from the current user's timeline
                var unfollowData = [String: Any]()
                // get all the post keys for that user
                let postKeys = posts.flatMap { $0.key }
                postKeys.forEach { unfollowData["timeline/\(currentUID)/\($0)"] = NSNull() }
                
                // write the dictionary to the database
                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    //
                    dispatchGroup.leave()
                })
            }
            
            // success callback after all previous requests have been completed
            dispatchGroup.notify(queue: .main) {
                success(true)
            }
        }
    }
    
    // easilty set up relationship between two users
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    // check if already following a user
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        // get current user and path for user to check if already following
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("followers").child(user.uid)
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
}
