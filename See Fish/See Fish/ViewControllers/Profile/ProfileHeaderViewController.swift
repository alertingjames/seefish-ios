//
//  ProfileHeaderViewController.swift
//  See Fish
//
//  Created by Andre on 11/8/20.
//

import UIKit

class ProfileHeaderViewController: BaseViewController {
    
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var btn_follow: UIButton!
    
    @IBOutlet weak var lbl_followers: UILabel!
    @IBOutlet weak var lbl_followings: UILabel!
    @IBOutlet weak var lbl_feeds: UILabel!
    @IBOutlet weak var lbl_likes: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        img_profile.layer.cornerRadius = img_profile.frame.height / 2
        loadPicture(imageView: img_profile, url: URL(string: gUser.photo_url)!)
        lbl_name.text = gUser.name
        lbl_city.text = gUser.city
        
        lbl_followers.attributedText = createFormattedString(icon: "user", text: "   Followers: \(gUser.followers)")
        lbl_followings.attributedText = createFormattedString(icon: "user", text: "   Followings: \(gUser.followings)")
        lbl_feeds.attributedText = createFormattedString(icon: "feed", text: "   Feeds: \(gUser.feeds)")
        lbl_likes.attributedText = createFormattedString(icon: "like", text: "   Likes: \(gUser.followers)")
        btn_follow.layer.cornerRadius = btn_follow.frame.height / 2
        
        if gUser.followed == true {
            btn_follow.backgroundColor = primaryMainLightColor
            btn_follow.setTitleColor(primaryColor, for: .normal)
            btn_follow.setTitle("Unfollow", for: .normal)
        }else {
            btn_follow.backgroundColor = primaryColor
            btn_follow.setTitleColor(.white, for: .normal)
            btn_follow.setTitle("Follow", for: .normal)
        }
        getMemberLikes(member_id: gUser.idx)
    }
    
    @IBAction func followUser(_ sender: Any) {
        self.followMember(member_id: gUser.idx, me_id: thisUser.idx)
    }
    
    func followMember(member_id: Int64, me_id: Int64){
        self.showLoadingView()
        APIs.followMember(member_id: member_id, me_id: me_id, handleCallback: { [self]
            followers, result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                if gUser.followed == true {
                    gUser.followed = false
                    btn_follow.backgroundColor = primaryColor
                    btn_follow.setTitleColor(.white, for: .normal)
                    btn_follow.setTitle("Follow", for: .normal)
                }else {
                    gUser.followed = true
                    btn_follow.backgroundColor = primaryMainLightColor
                    btn_follow.setTitleColor(primaryColor, for: .normal)
                    btn_follow.setTitle("Unfollow", for: .normal)
                }
                self.lbl_followers.text = "Followers: " + followers
                gUser.followers = Int64(followers)!
                gHomeViewController.refreshMyInfo(email: thisUser.email, password: thisUser.password)
                gUserProfileViewController.followersController.getFollowers(me_id: thisUser.idx, member_id: gUser.idx)
                gUserProfileViewController.followersController.viewWillAppear(false)
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This user doesn\'t exist")
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    func getMemberLikes(member_id: Int64){
        APIs.getMemberLikes(member_id: member_id, handleCallback: { [self]
            likes, result_code in
            if result_code == "0"{
                self.lbl_likes.attributedText = createFormattedString(icon: "like", text: "   Likes: " + likes)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    func createFormattedString(icon:String, text:String) -> NSAttributedString {
        let string = NSMutableAttributedString(string: "")
        // create our NSTextAttachment
        if let image = UIImage.init(named: icon) {
            string.addImageAttachment(image: image, font: .systemFont(ofSize: 14), textColor: primaryColor)
        }
        string.append(NSAttributedString(string: text))
        
        return string
    }
    
    
    
}
