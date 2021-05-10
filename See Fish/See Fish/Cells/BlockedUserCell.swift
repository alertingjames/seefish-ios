//
//  BlockedUserCell.swift
//  See Fish
//
//  Created by Andre on 12/14/20.
//

import UIKit

class BlockedUserCell: UICollectionViewCell {
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img_user.layer.cornerRadius = img_user.frame.height / 2
        img_user.layer.masksToBounds = true
        
        unblockButton.layer.cornerRadius = unblockButton.frame.height / 2
        
        
    }
}
