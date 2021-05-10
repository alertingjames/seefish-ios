//
//  MyFriendHeaderViewController.swift
//  See Fish
//
//  Created by Andre on 11/10/20.
//

import UIKit

class MyFriendHeaderViewController: BaseViewController {

    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var lbl_followers: UILabel!
    @IBOutlet weak var lbl_followings: UILabel!
    
    @IBOutlet weak var lblfollowers: UILabel!
    @IBOutlet weak var lblfollowings: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        img_profile.layer.cornerRadius = img_profile.frame.height / 2
        
        lblfollowers.attributedText = createPrimaryFormattedString(icon: "user", text: "   Followers:")
        lblfollowings.attributedText = createPrimaryFormattedString(icon: "user", text: "   Followings:")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPicture(imageView: img_profile, url: URL(string: thisUser.photo_url)!)
        lbl_followers.text = "\(thisUser.followers)"
        lbl_followings.text = "\(thisUser.followings)"
    }
    
    func createPrimaryFormattedString(icon:String, text:String) -> NSAttributedString {
        let string = NSMutableAttributedString(string: "")
        // create our NSTextAttachment
        if let image = UIImage.init(named: icon) {
            string.addImageAttachment(image: image, font: .systemFont(ofSize: 19), textColor: primaryColor)
        }
        string.append(NSAttributedString(string: text))
        
        return string
    }
    

}
