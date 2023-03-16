//
//  VideoRecordingViewController.swift
//  See Fish
//
//  Created by Andre on 11/5/20.
//

import UIKit
import AVKit
import MediaPlayer
import MobileCoreServices
import AVFoundation
import YPImagePicker
import FlexibleAVCapture
import SwiftVideoBackground
import CoreLocation

class VideoSubmitViewController: BaseViewController, CLLocationManagerDelegate, FlexibleAVCaptureDelegate, CachingPlayerItemDelegate {
    
    @IBOutlet weak var img_thumbnail: UIImageView!
    @IBOutlet weak var txv_desc: UITextView!
    @IBOutlet weak var img_videomark: UIImageView!
    
    @IBOutlet weak var lbl_desc: UILabel!
    @IBOutlet weak var addVideoBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var view_back: UIView!
    @IBOutlet weak var view_submit: UIView!
    @IBOutlet weak var view_add: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var titleBox: UITextField!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryBox: UITextField!
    @IBOutlet weak var rodBox: UITextField!
    @IBOutlet weak var reelBox: UITextField!
    @IBOutlet weak var lureBox: UITextField!
    @IBOutlet weak var lineBox: UITextField!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationSharingSW: UISwitch!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var videoFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var videoView: UIView!
    var videoButtons:VideoOptionsViewController!
    
    let flexibleAVCaptureVC: FlexibleAVCaptureViewController = FlexibleAVCaptureViewController()
    
    var videoURL:URL!
    var thumbnailFile:Data?
    let videoBackground = VideoBackground()
    
    var player:AVPlayer!
    
    var manager = CLLocationManager()
    var thisUserLocation:CLLocationCoordinate2D!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoButtons = (self.storyboard!.instantiateViewController(withIdentifier: "VideoOptionsViewController") as! VideoOptionsViewController)
        videoButtons.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        videoButtons.view_buttons.alpha = 0

        view_back.roundCorners(corners: [.bottomRight], radius: view_back.frame.height/2)
        view_submit.roundCorners(corners: [.bottomLeft], radius: view_submit.frame.height/2)
        view_add.roundCorners(corners: [.topLeft], radius: view_add.frame.height/2)
        
        txv_desc.delegate = self
        txv_desc.setPlaceholder(string: "Write something here...")
        txv_desc.textContainerInset = UIEdgeInsets(top: txv_desc.textContainerInset.top, left: 10, bottom: txv_desc.textContainerInset.bottom, right: txv_desc.textContainerInset.right)
        
        videoFrameHeight.constant = screenHeight * 2/3
        
        submitButton.layer.cornerRadius = submitButton.frame.height / 2
        titleBox.addBorder(side: .bottom, color: UIColor(rgb: 0x000000, alpha: 0.7), width: 1)
        categoryBox.addBorder(side: .bottom, color: UIColor(rgb: 0x000000, alpha: 0.7), width: 1)
        txv_desc.addBorder(side: .bottom, color: UIColor(rgb: 0x000000, alpha: 0.7), width: 1)
        rodBox.addBorder(side: .bottom, color: UIColor(rgb: 0x000000, alpha: 0.7), width: 1)
        reelBox.addBorder(side: .bottom, color: UIColor(rgb: 0x000000, alpha: 0.7), width: 1)
        lureBox.addBorder(side: .bottom, color: UIColor(rgb: 0x000000, alpha: 0.7), width: 1)
        lineBox.addBorder(side: .bottom, color: UIColor(rgb: 0x000000, alpha: 0.7), width: 1)
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                locationView.visibility = .gone
                locationSharingSW.isOn = false
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                @unknown default:
                    break
            }
        } else {
            print("Location services are not enabled")
            locationView.visibility = .gone
            locationSharingSW.isOn = false
        }
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowDeferredLocationUpdates(untilTraveled: 0, timeout: 0)
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
        self.flexibleAVCaptureVC.delegate = self
        self.flexibleAVCaptureVC.maximumRecordDuration = CMTime(seconds: 180.0, preferredTimescale: .max)
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(toggleVideo(gesture:)))
        self.img_thumbnail.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toggleVideo(gesture:)))
        self.videoView.addGestureRecognizer(tap)
        
        if gPost.idx > 0 && gPost.video_url.count > 0 && gPost.picture_url.count > 0 {
            loadPicture(imageView: img_thumbnail, url: URL(string: gPost.picture_url)!)
            titleBox.text = gPost.title
            categoryBox.text = gPost.category
            rodBox.text = gPost.rod
            reelBox.text = gPost.reel
            lureBox.text = gPost.lure
            lineBox.text = gPost.line
            txv_desc.text = gPost.content
            txv_desc.checkPlaceholder()
            lbl_desc.text = "Edit description"
            self.img_videomark.isHidden = false
            self.bgImage.isHidden = true
            self.videoView.isHidden = true
            self.addVideoBtn.setImage(UIImage(named: "pen"), for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recent = self
        gVideoSubmitViewController = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("locations = \(locations)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            thisUserLocation = center
        }
    }
    
    var isPlaying = false
    
    @objc func toggleVideo(gesture:UITapGestureRecognizer){
        if videoURL != nil {
            if !isPlaying {
                videoView.isHidden = false
                img_videomark.isHidden = true
                videoBackground.play(view: videoView, url: videoURL, darkness: 0.1)
                isPlaying = true
            }else {
                img_videomark.isHidden = false
                isPlaying = false
                videoBackground.pause()
            }
        }else {
            if gPost.idx > 0 && gPost.video_url.count > 0 {
                let url = URL(string: gPost.video_url)!
                let playerItem = CachingPlayerItem(url: url)
                playerItem.delegate = self
                player = AVPlayer(playerItem: playerItem)
                player.rate = 1 //auto play
                let playerFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                let playerController = AVPlayerViewController()
                playerController.player = player
                playerController.showsPlaybackControls = true
                playerController.view.frame = playerFrame
                self.view.addSubview(playerController.view)
                self.addChild(playerController)
                playerController.didMove(toParent: self)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.view.bounds
                self.view.layer.addSublayer(playerLayer)
                player.play()
                return
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        textView.checkPlaceholder()
    }
    
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return .lightContent
//    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func openCamera(_ sender: Any) {
        showButtons(option: true)
    }

    @IBAction func submitPost(_ sender: Any) {
        if gPost.idx > 0 {
            if self.videoURL == nil && txv_desc.text == gPost.content {
                showToast(msg: "Please change something for this feed.")
                return
            }
            let lat = locationSharingSW.isOn && thisUserLocation != nil ? String(thisUserLocation.latitude) : (gPost.lat != nil ? String(gPost.lat) : "")
            let lng = locationSharingSW.isOn && thisUserLocation != nil ? String(thisUserLocation.longitude) : (gPost.lng != nil ? String(gPost.lng) : "")
            if videoURL != nil {
                postVideo(post_id: gPost.idx, member_id: thisUser.idx, title: titleBox.text!, category: categoryBox.text!, content: txv_desc.text, rod: rodBox.text!, reel: reelBox.text!, lure: lureBox.text!, line: lineBox.text!, lat: lat, lng: lng, video_url: self.videoURL, thumbnail: thumbnailFile!)
            }else {
                updatePostWithoutVideo(post_id: gPost.idx, member_id: thisUser.idx, title: titleBox.text!, category: categoryBox.text!, content: txv_desc.text, rod: rodBox.text!, reel: reelBox.text!, lure: lureBox.text!, line: lineBox.text!, lat: lat, lng: lng)
            }
        }else {
            if self.videoURL == nil {
                showToast(msg: "Please load a video.")
                return
            }
            let lat = locationSharingSW.isOn && thisUserLocation != nil ? String(thisUserLocation.latitude) : ""
            let lng = locationSharingSW.isOn && thisUserLocation != nil ? String(thisUserLocation.longitude) : ""
            postVideo(post_id: 0, member_id: thisUser.idx, title: titleBox.text!, category:categoryBox.text!, content: txv_desc.text, rod:rodBox.text!, reel:reelBox.text!, lure:lureBox.text!, line:lineBox.text!, lat: lat, lng: lng, video_url: self.videoURL, thumbnail: thumbnailFile!)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        videoBackground.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    func showButtons(option:Bool){
        if option == true{
            UIView.animate(withDuration: 0.3) {
                self.addChild(self.videoButtons)
                self.view.addSubview(self.videoButtons.view)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.videoButtons.showButtonFrame()
            }
        }else{
            self.videoButtons.removeFromParent()
            self.videoButtons.view.removeFromSuperview()
        }
    }
    
    func recordVideo(){
        self.present(flexibleAVCaptureVC, animated: true, completion: nil)
        showButtons(option: false)
    }
    
    func didCapture(withFileURL fileURL: URL) {
        print("VIDEO URL+++ \(fileURL)")
        self.videoURL = fileURL
        let thumbImage = generateThumbnail(path: fileURL)
        self.img_thumbnail.image = thumbImage
        self.thumbnailFile = thumbImage!.jpegData(compressionQuality: 0.8)
        self.img_videomark.isHidden = false
        self.bgImage.isHidden = true
        self.videoView.isHidden = true
        self.addVideoBtn.setImage(UIImage(named: "pen"), for: .normal)
        self.flexibleAVCaptureVC.dismiss(animated: true, completion: nil)
    }
    
    func pickVideo(){
        var config = YPImagePickerConfiguration()
        config.video.compression = AVAssetExportPresetHighestQuality
        config.screens = [.library]
        config.library.mediaType = .video
        config.video.libraryTimeLimit = 180.0
        config.video.minimumTimeLimit = 3.0
        config.video.trimmerMaxDuration = 180.0
        config.video.trimmerMinDuration = 3.0
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [self, unowned picker] items, _ in
            if let video = items.singleVideo {
                self.videoURL = video.url
                self.img_thumbnail.image = video.thumbnail
                self.thumbnailFile = video.thumbnail.jpegData(compressionQuality: 0.8)
                self.img_videomark.isHidden = false
                self.bgImage.isHidden = true
                self.videoView.isHidden = true
                self.addVideoBtn.setImage(UIImage(named: "pen"), for: .normal)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        showButtons(option: false)
    }

    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func postVideo(post_id: Int64, member_id:Int64, title:String, category:String, content:String, rod:String, reel:String, lure:String, line:String, lat:String, lng:String, video_url:URL, thumbnail: Data){
        self.showLoadingView()
        APIs.postVideo(post_id: post_id, member_id: member_id, title:title, category:category, content:content, rod:rod, reel:reel, lure:lure, line:line, lat:lat, lng:lng, video_url: video_url, thumbnail: thumbnail, handleCallback: {
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.showToast(msg: "Your feed posted successfully.")
                gMainViewController.selectedIndex = 0
                self.dismiss(animated: true, completion: nil)
            }
            else{
                self.showToast(msg: "Server issue.")
            }
        })
        
    }
    
    func updatePostWithoutVideo(post_id: Int64, member_id:Int64, title:String, category:String, content:String, rod:String, reel:String, lure:String, line:String, lat:String, lng:String){
        self.showLoadingView()
        APIs.editPostWithoutVideo(member_id: member_id, post_id: post_id, title: title, category: category, content: content, rod: rod, reel: reel, lure: lure, line: line, lat: lat, lng: lng, handleCallback: {
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.showToast(msg: "Your feed updated successfully.")
                self.dismiss(animated: true, completion: nil)
            }
            else{
                self.showToast(msg: "Server issue.")
            }
        })
        
    }
    
    @IBAction func openCategoryMenu(_ sender: Any) {
        to(strb: "Main2", vc: "CategoryListViewController", trans: false, modal: false, anim: true)
    }
    
    @IBAction func changeIfLocationShare(_ sender: Any) {
        
    }
    
    
    
    
    
}
