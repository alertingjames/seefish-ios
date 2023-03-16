//
//  RouteSaveBox.swift
//  See Fish
//
//  Created by james on 12/8/22.
//

import UIKit

class RouteSaveBox: BaseViewController {
    
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var descBox: UITextView!
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var descH: NSLayoutConstraint!
    
    var end:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        headerView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
        descBox.layer.cornerRadius = 5
        descBox.layer.borderColor = primaryDarkColor.cgColor
        descBox.layer.borderWidth = 1.5
        
        descBox.setPlaceholder(string: "Comment (optional)")
        descBox.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        descBox.delegate = self
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        alertView.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            UIView.animate(withDuration: 0.8) {
                self.alertView.alpha = 1.0
            }
        }
        
        okayButton.layer.cornerRadius = 3
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
//        self.removeFromParent()
//        self.view.removeFromSuperview()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
    }


    @IBAction func saveRoute(_ sender: Any) {
        descBox.resignFirstResponder()
        gLocationSharingViewController.endRoute(desc: descBox.text!)
        dismissDialog()
    }
    
    func dismissDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        alertView.alpha = 1
    }
    
}
