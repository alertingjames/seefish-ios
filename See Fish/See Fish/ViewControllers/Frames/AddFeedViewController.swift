//
//  AddFeedViewController.swift
//  See Fish
//
//  Created by Andre on 11/3/20.
//

import UIKit
import AVFoundation

class AddFeedViewController: BaseViewController {
    
    @IBOutlet weak var imageBtn: UIImageView!
    @IBOutlet weak var videoBtn: UIImageView!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRoundShadowView(view: imageBtn, corner: imageBtn.frame.height/2)
        setRoundShadowView(view: videoBtn, corner: videoBtn.frame.height/2)
        
        setIconTintColor(imageView: backgroundImg, color: primaryMainLightColor)
        self.view.backgroundColor = primaryMainLightColor
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(captureImage(gesture:)))
        imageBtn.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(captureVideo(gesture:)))
        videoBtn.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gFishViewController.image = nil
    }
    
    @objc func captureImage(gesture: UITapGestureRecognizer) {
        gPost.idx = 0
        let vc = self.storyboard?.instantiateViewController(identifier: "ImageSubmitViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    @objc func captureVideo(gesture: UITapGestureRecognizer) {
        gPost.idx = 0
        let vc = self.storyboard?.instantiateViewController(identifier: "VideoSubmitViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
}











































