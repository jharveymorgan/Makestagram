//
//  MainTabBarController.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    let photoHelper = MGPhotoHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        photoHelper.completionHandler = { image in
            PostService.create(for: image)
        }
        
        
        delegate = self
        tabBar.unselectedItemTintColor = .black
    }
    

}

extension MainTabBarController: UITabBarControllerDelegate {
    // present corresponding view controller user selected
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // if the view controller is the center tab button
        if viewController.tabBarItem.tag == Constants.TabButtons.takePhoto {
            // present photo taking action
            photoHelper.presentActionSheet(from: self)
            return false
        }
        
        return true
    }
}
