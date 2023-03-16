//
//  ForgotPasswordViewController.swift
//  See Fish
//
//  Created by Andre on 11/1/20.
//

import UIKit
import TextFieldEffects

class ForgotPasswordViewController: BaseViewController {
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var emailBox: HoshiTextField!
    @IBOutlet weak var titleIcon: UIImageView!
    @IBOutlet weak var lbl_desc: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setIconTintColor(imageView: titleIcon, color: primaryColor)
        
        emailBox.placeholder = "Email address"
        emailBox.minimumFontSize = 5
        emailBox.textColor = primaryDarkColor
        emailBox.font = UIFont(name: "Helvetica", size: 17)        
        emailBox.keyboardType = UIKeyboardType.emailAddress
        
        setRoundShadowButton(button: submitBtn, corner: submitBtn.frame.height/2)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 10
        
        let text = "Please enter your email.\nWe will send password reset link to your email."

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont(name: "Comfortaa-Medium", size: 15.0)!,
            .foregroundColor: primaryColor
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        lbl_desc.attributedText = attributedString
    }
    
    @IBAction func submit(_ sender: Any) {
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Enter your email.")
            return
        }
        
        if !isValidEmail(email: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) {
            showToast(msg: "Enter a valid email.")
            return
        }
        
        forgotPassword(email: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        
    }
    
    @IBAction func toLogin(_ sender: Any) {
        self.dismissViewController()
    }
    
    func forgotPassword(email:String) {
        showLoadingView()
        APIs.forgotPassword(email: email, handleCallback:{
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                let msg = """
                We've sent a password reset link to
                your email. Please check...
                """
                self.showAlertDialog(title: "Notice", message: msg)
//                self.openMailBox(email: email)
            }else if result_code == "1"{
                self.showToast(msg: "Sorry, but we don\'t know your email.")
            }else {
                self.showToast(msg: "Server error!")
            }
        })
    }
    
    func openMailBox(email:String){
        let mailURL = URL(string: "message://")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.openURL(mailURL)
        }
    }
    
}
