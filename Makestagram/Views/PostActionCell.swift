//
//  PostActionCell.swift
//  Makestagram
//
//  Created by Jordan Harvey-Morgan on 6/20/17.
//  Copyright © 2017 Jordan Harvey-Morgan. All rights reserved.
//

import UIKit

protocol PostActionCellDelegate: class{
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
}

class PostActionCell: UITableViewCell {
    // MARK: - Properties
    static let height: CGFloat = 46
    weak var delegate: PostActionCellDelegate?
    
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
        delegate?.didTapLikeButton(sender as! UIButton, on: self)
    }
}
