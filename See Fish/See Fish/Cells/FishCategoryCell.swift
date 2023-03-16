//
//  CategoryCell.swift
//  See Fish
//
//  Created by james on 12/5/22.
//

import UIKit

class FishCategoryCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var colorView: UILabel!
    @IBOutlet weak var cLeft: NSLayoutConstraint!
    @IBOutlet weak var categoryNameBox: UILabel!    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
