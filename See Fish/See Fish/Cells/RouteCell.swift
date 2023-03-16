//
//  RouteCell.swift
//  See Fish
//
//  Created by james on 12/8/22.
//

import UIKit

class RouteCell: UITableViewCell {
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
