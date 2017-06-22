//
//  FindFriendsCell.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/21/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

protocol FindFriendsCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton,on cell: FindFriendsCell)
}

class FindFriendsCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    weak var delegate: FindFriendsCellDelegate?
    
    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
    }
    
    //MARK: - IBActions
    @IBAction func followButtonTapped(_ sender: Any) {
        delegate?.didTapFollowButton(sender as! UIButton, on: self)
    }
}
