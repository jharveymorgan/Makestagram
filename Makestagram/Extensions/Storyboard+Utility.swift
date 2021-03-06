//
//  Storyboard+Utility.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/19/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

extension UIStoryboard{
    enum MGType: String {
        case main
        case login
        case findFriends
        case profile
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(type: MGType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
    
    // get initial view controller of specific storyboard
    static func initialViewController(for type: MGType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate view controller for \(type.filename) storyboard.")
        }
        
        return initialViewController
    }
}// end extension
