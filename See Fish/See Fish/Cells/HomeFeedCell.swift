//
//  HomeFeedCell.swift
//  See Fish
//
//  Created by Andre on 11/3/20.
//

import UIKit

class HomeFeedCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var img_poster: UIImageView!
    @IBOutlet weak var lbl_poster_name: UILabel!
    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var lbl_follows: UILabel!
    @IBOutlet weak var lbl_posted_time: UILabel!
    @IBOutlet weak var img_post_picture: UIImageView!
    @IBOutlet weak var view_video: PlayerView!
    @IBOutlet weak var lbl_likes: UILabel!
    @IBOutlet weak var lbl_comments: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var txv_desc: UITextView!
    @IBOutlet weak var lbl_pics: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var img_videomark: UIImageView!
    @IBOutlet weak var view_info: UIView!
    
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    @IBOutlet weak var postDescHeight: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
