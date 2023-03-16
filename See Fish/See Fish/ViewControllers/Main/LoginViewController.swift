//
//  LoginViewController.swift
//  See Fish
//
//  Created by Andre on 10/31/20.
//

import UIKit
import TextFieldEffects

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var titleIcon: UIImageView!
    @IBOutlet weak var emailBox: HoshiTextField!
    @IBOutlet weak var passwordBox: HoshiTextField!
    @IBOutlet weak var showBtn: UIButton!
    var showF:Bool = false
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var forgotpasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setIconTintColor(imageView: titleIcon, color: primaryColor)
        showBtn.setImageTintColor(primaryLightColor)
                
        emailBox.placeholder = "Email address"
        emailBox.minimumFontSize = 5
        emailBox.textColor = primaryDarkColor
        emailBox.font = UIFont(name: "Helvetica", size: 17)
        emailBox.keyboardType = UIKeyboardType.emailAddress
        
        passwordBox.placeholder = "Password"
        passwordBox.minimumFontSize = 5
        passwordBox.paddingRightCustom = 35
        passwordBox.textColor = primaryDarkColor
        passwordBox.font = UIFont(name: "Helvetica", size: 17)
        passwordBox.isSecureTextEntry = true
        
        setRoundShadowButton(button: loginBtn, corner: loginBtn.frame.height/2)
        setRoundShadowButton(button: signupBtn, corner: signupBtn.frame.height/2)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if authMesOpt == "email_sent" {
            let msg = """
            You were not verified.
            We have sent a verification link
            to your email. Please check.
            """
            showAlertDialog(title: "Notice", message: msg)
        } else if authMesOpt == "email_failed" {
            let msg = """
            You were not verified.
            Please try to login again later.
            """
            showAlertDialog(title: "Notice", message: msg)
        } else if authMesOpt == "upgrade_email_sent" {
            let msg = """
            Your free trial was ended.
            To keep using this app, you need
            to upgrade your account. We have
            sent an upgradation link to your
            email. Please check.
            """
            showAlertDialog(title: "Notice", message: msg)
        } else if authMesOpt == "upgrade_email_failed" {
            let msg = """
            Your free trial was ended.
            To keep using this app, you need
            to upgrade your account. Please
            try to login again later.
            """
            showAlertDialog(title: "Notice", message: msg)
        }
    }
    
    @IBAction func togglePasswordShowing(_ sender: Any) {
        if showF == false{
            showBtn.setImage(unshow, for: UIControl.State.normal)
            showF = true
            passwordBox.isSecureTextEntry = false
        }else{
            showBtn.setImage(show, for: UIControl.State.normal)
            showF = false
            passwordBox.isSecureTextEntry = true
        }
        showBtn.setImageTintColor(primaryLightColor)
    }
    
    @IBAction func login(_ sender: Any) {
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Enter your email.")
            return
        }
        
        if !isValidEmail(email: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) {
            showToast(msg: "Enter a valid email.")
            return
        }
        
        if passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "Enter your password.")
            return
        }
        
        if (passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)! <= 5 {
            showToast(msg: "Enter characters more than 5.")
            return
        }
        
        login(email: emailBox.text!, password: passwordBox.text!)
        
    }
    
    @IBAction func signup(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignupViewController")
        self.transitionVc(vc: vc!, duration: 0.3, type: .fromRight)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ForgotPasswordViewController")
        self.transitionVc(vc: vc!, duration: 0.3, type: .fromRight)
    }
    
    func login(email:String, password: String)
    {
        showLoadingView()
        APIs.login(email: email, password: password, handleCallback:{
            user, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                if thisUser.terms == "" {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight) 
                }
            } else if result_code == "-1" {
                // incorrect password
                thisUser.idx = 0
                let msg = """
                You were not verified.
                We have sent a verification link
                to your email. Please check.
                """
                self.showAlertDialog(title: "Notice", message: msg)
            } else if result_code == "-2" {
                // incorrect password
                thisUser.idx = 0
                let msg = """
                You were not verified.
                Please try to login again later.
                """
                self.showAlertDialog(title: "Notice", message: msg)
            } else if result_code == "-10" {
                let msg = """
                Your free trial was ended.
                To keep using this app, you need
                to upgrade your account. We have
                sent an upgradation link to your
                email. Please check.
                """
                self.showAlertDialog(title: "Notice", message: msg)
            } else if result_code == "-20" {
                let msg = """
                Your free trial was ended.
                To keep using this app, you need
                to upgrade your account. Please
                try to login again later.
                """
                self.showAlertDialog(title: "Notice", message: msg)
            } else if result_code == "1" {
                // incorrect password
                thisUser.idx = 0
                self.showToast(msg: "Your password is incorrect.")
            } else if result_code == "2" {
                // unregistered user
                thisUser.idx = 0
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            } else {
                thisUser.idx = 0
                self.showToast(msg: "Something is wrong")
            }
        })
    }
    
    
}
