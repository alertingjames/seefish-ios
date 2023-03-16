//
//  TermsViewController.swift
//  See Fish
//
//  Created by Andre on 12/12/20.
//

import UIKit

class TermsViewController: BaseViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRoundShadowButton(button: agreeButton, corner: agreeButton.frame.height / 2)
        textBox.text = "Thank you for signing up for See Fish!\n\n***By signing up to See Fish, you are agreeing to not engage in any type of:***\n\n"
        textBox.text = textBox.text + "- hate speech\n\n- cyberbullying\n\n- solicitation and/or selling of goods or services\n\n- posting content inappropriate for our diverse community including but not limited to political or religious views\n\n"
        textBox.text = textBox.text + "We want See Fish to be a safe place for support and inspiration. Help us foster this community and please respect everyone on See Fish.\n\n"
        textBox.text = textBox.text + "If you find any content abusive or violationg the terms, please report it to the See Fish Administrator.\n\n"
        textBox.text = textBox.text + "Thank you and enjoy your See Fish Days!"
        
    }
    
    @IBAction func agreeTerms(_ sender: Any) {
//        self.showLoadingView()
//        APIs.readTerms(member_id: thisUser.idx, handleCallback: {
//            result in
//            print("result: \(result)")
//            self.dismissLoadingView()
//            if result == "0" {
//                if gSignupViewController != nil {
//                    gSignupViewController.acceptTerms()
//                    self.dismissViewController()
//                }
//            }
//        })
        if gSignupViewController != nil {
            gSignupViewController.acceptTerms()
            self.dismissViewController()
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
}
