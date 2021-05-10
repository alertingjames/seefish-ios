//
//  PostUserCell.swift
//  See Fish
//
//  Created by Andre on 11/7/20.
//

import UIKit

class PostUserCell: UICollectionViewCell {
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img_user.layer.cornerRadius = img_user.frame.height / 2
        img_user.layer.masksToBounds = true
        
    }
}
