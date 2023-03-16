//
//  MapHintDialog.swift
//  See Fish
//
//  Created by james on 12/6/22.
//

import UIKit

class MapHintDialog: BaseViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 10
        
//        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.light)
//        let blurFxView = UIVisualEffectView(effect: blurFx)
//        blurFxView.frame = view.bounds
//        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.view.insertSubview(blurFxView, at: 0)
        
        self.alertView.alpha = 0
        
    }
    
    func showDialog() {
        UIView.animate(withDuration: 1.2) {
            self.alertView.alpha = 1.0
        }
    }
    
    func dismissDialog() {
        UIView.animate(withDuration: 0.5) {
            self.alertView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }

    @IBAction func OK(_ sender: Any) {
        
        dismissDialog()
    }
    
}
