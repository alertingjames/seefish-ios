//
//  VideoOptionsViewController.swift
//  See Fish
//
//  Created by Andre on 11/5/20.
//

import UIKit

class VideoOptionsViewController: UIViewController {

    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var libraryBtn: UIButton!
    @IBOutlet weak var view_buttons: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraBtn.layer.cornerRadius = 20
        libraryBtn.layer.cornerRadius = 20
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    func showButtonFrame() {
        UIView.animate(withDuration: 0.2) {
            self.view_buttons.alpha = 1.0
        }
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.view_buttons.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
    @IBAction func openCamera(_ sender: Any) {
        gVideoSubmitViewController.recordVideo()
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        gVideoSubmitViewController.pickVideo()
    }
    
}
