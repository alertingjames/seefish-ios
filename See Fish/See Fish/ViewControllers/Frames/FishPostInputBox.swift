//
//  FishPostInputBox.swift
//  See Fish
//
//  Created by Andre on 12/10/20.
//

import UIKit

class FishPostInputBox: BaseViewController {
    
    @IBOutlet weak var descBox: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        headerView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
        descBox.layer.cornerRadius = 5
        descBox.layer.borderColor = primaryColor.cgColor
        descBox.layer.borderWidth = 1.5
        
//        descBox.setPlaceholder(string: "Write something here...")
        descBox.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        descBox.delegate = self
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        submitButton.layer.cornerRadius = 3
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        textView.checkPlaceholder()
    }
    
    func showAlert() {
        UIView.animate(withDuration: 0.2) {
            self.alertView.alpha = 1.0
        }
    }
    
    func dismissAlert() {
        UIView.animate(withDuration: 0.3) {
            self.alertView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
    @IBAction func closeBox(_ sender: Any) {
        dismissAlert()
    }
    
    @IBAction func submitFishPost(_ sender: Any) {
        gFishViewController.postFish(desc:descBox.text.trimmingCharacters(in: .whitespacesAndNewlines))
        dismissAlert()
    }
    
}
