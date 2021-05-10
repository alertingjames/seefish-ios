//
//  AccountViewController.swift
//  See Fish
//
//  Created by Andre on 11/3/20.
//

import UIKit
import DropDown

class AccountViewController: BaseViewController {
    
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_email: UILabel!
    @IBOutlet weak var lbl_phone: UILabel!
    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var view_layout: UIView!
    @IBOutlet weak var lbl_feeds: UILabel!
    @IBOutlet weak var lbl_followers: UILabel!
    @IBOutlet weak var lbl_followings: UILabel!
    @IBOutlet weak var lbl_likes: UILabel!
    @IBOutlet weak var lbl_saveds: UILabel!
    
    @IBOutlet weak var lblfeeds: UILabel!
    @IBOutlet weak var lblfollowers: UILabel!
    @IBOutlet weak var lblfollowings: UILabel!
    @IBOutlet weak var lbllikes: UILabel!
    @IBOutlet weak var lblsaveds: UILabel!
    @IBOutlet weak var img_bg: UIImageView!
    
//    var buttonAlert:ProfileOptionsViewController!
    var buttonAlert:ProfileOptions2ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        buttonAlert = (self.storyboard!.instantiateViewController(withIdentifier: "ProfileOptionsViewController") as! ProfileOptionsViewController)
        buttonAlert = (self.storyboard!.instantiateViewController(withIdentifier: "ProfileOptions2ViewController") as! ProfileOptions2ViewController)
        buttonAlert.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        buttonAlert.view_buttons.alpha = 0
        
        setIconTintColor(imageView: img_bg, color: primaryMainLightColor)
        self.view.backgroundColor = primaryMainLightColor
        
        img_profile.layer.cornerRadius = img_profile.frame.height / 2
        
        lblfollowers.attributedText = createPrimaryFormattedString(icon: "user", text: "   Followers:")
        lblfollowings.attributedText = createPrimaryFormattedString(icon: "user", text: "   Followings:")
        lblfeeds.attributedText = createPrimaryFormattedString(icon: "feed", text: "   Feeds posted:")
        lbllikes.attributedText = createPrimaryFormattedString(icon: "like", text: "   Feed likes:")
        lblsaveds.attributedText = createPrimaryFormattedString(icon: "save", text: "   Feeds saved:")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPicture(imageView: img_profile, url: URL(string: thisUser.photo_url)!)
        lbl_name.text = thisUser.name
        
        lbl_email.attributedText = createBlackFormattedString(icon: "mail", text: "   " + thisUser.email)
        
        if thisUser.phone_number.count > 0 {
            lbl_phone.attributedText = createBlackFormattedString(icon: "phone", text: "   " + thisUser.phone_number)
        }else {
            lbl_phone.visibility = .gone
        }
        
        lbl_city.attributedText = createBlackFormattedString(icon: "location", text: "   " + thisUser.city)
        
        lbl_feeds.text = "\(thisUser.feeds)"
        lbl_followers.text = "\(thisUser.followers)"
        lbl_followings.text = "\(thisUser.followings)"
        
        getMemLikes(member_id: thisUser.idx)
        
        gFishViewController.image = nil
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
    
    func createBlackFormattedString(icon:String, text:String) -> NSAttributedString {
        let string = NSMutableAttributedString(string: "")
        // create our NSTextAttachment
        if let image = UIImage.init(named: icon) {
            string.addImageAttachment(image: image, font: .systemFont(ofSize: 19), textColor: .label)
        }
        string.append(NSAttributedString(string: text))
        
        return string
    }
    
    func showButtons(){
        UIView.animate(withDuration: 0.3) {
            self.addChild(self.buttonAlert)
            self.view.addSubview(self.buttonAlert.view)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonAlert.showButtonFrame()
        }
    }

    @IBAction func openMenu(_ sender: Any) {
        showButtons()
    }
    
    
}
