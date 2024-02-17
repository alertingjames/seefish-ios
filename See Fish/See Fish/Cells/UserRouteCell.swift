//
//  UserRouteCell.swift
//  See Fish
//
//  Created by james on 9/5/23.
//

import UIKit

class UserRouteCell: UITableViewCell {
    
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userNameBox: UILabel!
    @IBOutlet weak var userCityBox: UILabel!
    
    @IBOutlet weak var nameBox: UILabel!
    @IBOutlet weak var timeBox: UILabel!
    @IBOutlet weak var durationBox: UILabel!
    @IBOutlet weak var distanceBox: UILabel!
    @IBOutlet weak var descBox: UITextView!
    @IBOutlet weak var statusBox: UILabel!
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
