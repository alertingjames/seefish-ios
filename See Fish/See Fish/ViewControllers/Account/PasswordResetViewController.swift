//
//  PasswordResetViewController.swift
//  See Fish
//
//  Created by Andre on 11/10/20.
//

import UIKit
import TextFieldEffects

class PasswordResetViewController: BaseViewController {
    
    @IBOutlet weak var oldBox: HoshiTextField!
    @IBOutlet weak var newBox: HoshiTextField!
    @IBOutlet weak var confirmBox: HoshiTextField!
    @IBOutlet weak var showPwBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var showF:Bool = false
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        oldBox.placeholder = "Old password"
        oldBox.minimumFontSize = 5
        oldBox.paddingRightCustom = 35
        oldBox.textColor = .label
        oldBox.font = UIFont(name: "Helvetica", size: 19)
        oldBox.isSecureTextEntry = true
        
        newBox.placeholder = "New password"
        newBox.minimumFontSize = 5
        newBox.paddingRightCustom = 35
        newBox.textColor = .label
        newBox.font = UIFont(name: "Helvetica", size: 19)
        newBox.isSecureTextEntry = true
        
        confirmBox.placeholder = "Confirm Password"
        confirmBox.minimumFontSize = 5
        confirmBox.paddingRightCustom = 35
        confirmBox.textColor = .label
        confirmBox.font = UIFont(name: "Helvetica", size: 19)
        confirmBox.isSecureTextEntry = true
        
        showPwBtn.setImageTintColor(primaryLightColor)
        setRoundShadowButton(button: saveBtn, corner: saveBtn.frame.height / 2)
        
    }
    
    @IBAction func showPw(_ sender: Any) {
        if showF == false{
            showPwBtn.setImage(unshow, for: UIControl.State.normal)
            showF = true
            newBox.isSecureTextEntry = false
        }else{
            showPwBtn.setImage(show, for: UIControl.State.normal)
            showF = false
            newBox.isSecureTextEntry = true
        }
        showPwBtn.setImageTintColor(primaryLightColor)
    }
    
    @IBAction func savePw(_ sender: Any) {
        if oldBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please enter your old password.")
            return
        }
        if newBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please enter your new password.")
            return
        }
        if confirmBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Please reenter your password to confirm.")
            return
        }
        if oldBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) != thisUser.password {
            showToast(msg: "Your password doesn\'t match your old one.")
            return
        }
        if newBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) != confirmBox.text?.trimmingCharacters(in: .whitespaces) {
            showToast(msg: "Please enter the same password to confirm.")
            return
        }
        
        changePassword(member_id: thisUser.idx, password: (newBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        
    }
    
    func changePassword(member_id: Int64, password:String){
        APIs.changePassword(member_id: member_id, password: password, handleCallback: { [self]
            result_code in
            if result_code == "0"{
                showToast2(msg: "Your password has been updated successfully.")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
