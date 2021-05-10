//
//  ProfileFollowerCell.swift
//  See Fish
//
//  Created by Andre on 11/8/20.
//

import UIKit

class ProfileFollowerCell: UICollectionViewCell {
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_city: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img_user.layer.cornerRadius = img_user.frame.height / 2
        img_user.layer.masksToBounds = true
        
    }
    
}
