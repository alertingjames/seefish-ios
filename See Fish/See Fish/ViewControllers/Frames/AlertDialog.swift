//
//  AlertDialog.swift
//  See Fish
//
//  Created by Andre on 12/14/20.
//

import UIKit

class AlertDialog: BaseViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertText: UITextView!
    var index:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        alertText.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)        
        
    }
    
    func showDialog() {
        UIView.animate(withDuration: 0.2) {
            self.alertView.alpha = 1.0
        }
    }
    
    func dismissDialog() {
        UIView.animate(withDuration: 0.3) {
            self.alertView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
    @IBAction func no(_ sender: Any) {
        dismissDialog()
    }

    @IBAction func yes(_ sender: Any) {
        if index == 0 {
            gHomeViewController.blockUser(member_id: gUser.idx)
        }else if index == 1 {
            gCommentViewController.blockUser(member_id: gUser.idx)
        }else if index == 2 {
            print("Alert Selected: \(index)")
            gUserProfileViewController.blockMember(member_id: gUser.idx)
        }
        dismissDialog()
    }
    
}
