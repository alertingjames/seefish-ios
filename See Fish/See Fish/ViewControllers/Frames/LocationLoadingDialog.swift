//
//  LocationLoadingDialog.swift
//  See Fish
//
//  Created by james on 12/8/22.
//

import UIKit

class LocationLoadingDialog: BaseViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var messageBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        alertView.alpha = 0
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            UIView.animate(withDuration: 0.8) {
                self.alertView.alpha = 1.0
            }
        }
        
    }
    

}
