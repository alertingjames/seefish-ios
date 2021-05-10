//
//  ViewController.swift
//  See Fish
//
//  Created by Andre on 10/31/20.
//

import UIKit

class ViewController: BaseViewController {
    
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var titleIcon: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserDefaults.standard.setValue("", forKey: "email")
//        UserDefaults.standard.setValue("", forKey: "password")
        
        setIconTintColor(imageView: titleIcon, color: primaryColor)
        top.constant = self.screenHeight * 0.3
        
        UIView.animate(withDuration: 1.0, animations: { [self]() -> Void in
            icon.rotate()
        }){
            (finished) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // Code you want to be delayed
                
                let email = UserDefaults.standard.string(forKey: "email")
                let password = UserDefaults.standard.string(forKey: "password")
                
                if email?.count ?? 0 > 0 && password?.count ?? 0 > 0{
                    self.login(email: email!, password: password!)
                }else{
                    thisUser.idx = 0
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier:"LoginViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
                
            }
        }
        
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
                }else{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }else if result_code == "1" {
                // incorrect password
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if result_code == "2" {
                // unregistered user
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
        })
    }


}

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: -Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = 1
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
