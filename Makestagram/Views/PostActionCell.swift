//
//  PostActionCell.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

class PostActionCell: UITableViewCell {
    
    static let height: CGFloat = 46
    
    // MARK: - Subviews
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // MARK: - Cell Lifecyle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - IBActions
    @IBAction func likeButtonTapped(_ sender: Any) {
        print("like button tapped")
    }
}
