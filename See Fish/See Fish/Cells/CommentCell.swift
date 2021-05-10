//
//  CommentCell.swift
//  See Fish
//
//  Created by Andre on 11/7/20.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var contentLayout: UIView!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userNameBox: UILabel!
    @IBOutlet weak var userCityBox: UILabel!
    @IBOutlet weak var commentedTimeBox: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var commentBoxWidth: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
