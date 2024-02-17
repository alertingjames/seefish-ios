//
//  ProfileOptions2ViewController.swift
//  See Fish
//
//  Created by Andre on 12/10/20.
//

import UIKit

class ProfileOptions2ViewController: BaseViewController {
    
    @IBOutlet weak var btn_edit_profile: UIButton!
    @IBOutlet weak var btn_feeds: UIButton!
    @IBOutlet weak var btn_followers: UIButton!
    @IBOutlet weak var btn_blocks: UIButton!
    @IBOutlet weak var btn_logout: UIButton!
    @IBOutlet weak var btn_delete: UIButton!
    @IBOutlet weak var view_buttons: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn_edit_profile.layer.cornerRadius = 20
        btn_feeds.layer.cornerRadius = 20
        btn_followers.layer.cornerRadius = 20
        btn_blocks.layer.cornerRadius = 20
        btn_logout.layer.cornerRadius = 20
        btn_delete.layer.cornerRadius = 20
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    func showButtonFrame() {
        UIView.animate(withDuration: 0.2) {
            self.view_buttons.alpha = 1.0
        }
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        dismissAlert()
    }
    
    func dismissAlert() {
        UIView.animate(withDuration: 0.3) {
            self.view_buttons.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }

    @IBAction func editProfile(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "EditProfileViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
        dismissAlert()
    }
    
    @IBAction func getFeeds(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "FeedContainerViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
        dismissAlert()
    }
    
    @IBAction func getFollowers(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "FriendContainerViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
        dismissAlert()
    }
    
    @IBAction func logOut(_ sender: Any) {
        self.logout()
        dismissAlert()
    }
    
    @IBAction func getBlockedUsers(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "BlockedUserListViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
        dismissAlert()
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let msg = """
        Once you deleted your account,
        all your data will be deleted and
        you can't recovery it back.
        """
        let alert = UIAlertController(title: "Sure delete your account?", message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        let regAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
            self.deleteAccount()
        })
        alert.addAction(regAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }
    
    func deleteAccount() {
        showLoadingView()
        APIs.deleteAccount(member_id: thisUser.idx, handleCallback: { result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                self.exitApp()
            } else {
                self.showAlertDialog(title: "Notice", message: "The account deletion failed.")
            }
        })
    }
    
}
