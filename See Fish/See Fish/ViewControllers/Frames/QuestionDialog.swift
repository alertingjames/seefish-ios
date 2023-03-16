//
//  QuestionDialog.swift
//  See Fish
//
//  Created by james on 12/8/22.
//

import UIKit

class QuestionDialog: BaseViewController {
    
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var messageBox: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        headerView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
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
        
    }
    
    @IBAction func noAction(_ sender: Any) {
        dismissDialog()
    }
    
    @IBAction func yesAction(_ sender: Any) {
        if gLocationSharingViewController != nil {
//            gLocationSharingViewController.saveRoute(route: gHomeVC.route, islongtime: true)
            dismissDialog()
        }
    }
    
    func dismissDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        alertView.alpha = 1
    }
    
}
