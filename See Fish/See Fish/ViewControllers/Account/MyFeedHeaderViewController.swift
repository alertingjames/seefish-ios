//
//  InfoHeaderViewController.swift
//  See Fish
//
//  Created by Andre on 11/10/20.
//

import UIKit

class MyFeedHeaderViewController: BaseViewController {
    
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var lbl_feeds: UILabel!
    @IBOutlet weak var lbl_likes: UILabel!
    @IBOutlet weak var lbl_saveds: UILabel!
    
    @IBOutlet weak var lblfeeds: UILabel!
    @IBOutlet weak var lbllikes: UILabel!
    @IBOutlet weak var lblsaveds: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        img_profile.layer.cornerRadius = img_profile.frame.height / 2
        
        lblfeeds.attributedText = createPrimaryFormattedString(icon: "feed", text: "   Feeds posted:")
        lbllikes.attributedText = createPrimaryFormattedString(icon: "like", text: "   Feed likes:")
        lblsaveds.attributedText = createPrimaryFormattedString(icon: "save", text: "   Feeds saved:")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPicture(imageView: img_profile, url: URL(string: thisUser.photo_url)!)
        lbl_feeds.text = "\(thisUser.feeds)"
        
        getMemLikes(member_id: thisUser.idx)
    }
    
    func getMemLikes(member_id: Int64){
        APIs.getMeLikes(member_id: member_id, handleCallback: { [self]
            likes, saveds, result_code in
            if result_code == "0"{
                self.lbl_likes.text = likes
                self.lbl_saveds.text = saveds
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
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
