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

class VideoSubmitViewController: BaseViewController, FlexibleAVCaptureDelegate, CachingPlayerItemDelegate {
    
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
    @IBOutlet weak var videoFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var videoView: UIView!
    var videoButtons:VideoOptionsViewController!
    
    let flexibleAVCaptureVC: FlexibleAVCaptureViewController = FlexibleAVCaptureViewController()
    
    var videoURL:URL!
    var thumbnailFile:Data?
    let videoBackground = VideoBackground()
    
    var player:AVPlayer!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gVideoSubmitViewController = self
        
        videoButtons = (self.storyboard!.instantiateViewController(withIdentifier: "VideoOptionsViewController") as! VideoOptionsViewController)
        videoButtons.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        videoButtons.view_buttons.alpha = 0

        view_back.roundCorners(corners: [.bottomRight], radius: view_back.frame.height/2)
        view_submit.roundCorners(corners: [.bottomLeft], radius: view_submit.frame.height/2)
        view_add.roundCorners(corners: [.topLeft], radius: view_add.frame.height/2)
        
        txv_desc.delegate = self
        txv_desc.setPlaceholder(string: "Write something here...")
        txv_desc.textContainerInset = UIEdgeInsets(top: txv_desc.textContainerInset.top, left: 8, bottom: txv_desc.textContainerInset.bottom, right: txv_desc.textContainerInset.right)
        
        videoFrameHeight.constant = screenHeight * 2/3
        
        self.flexibleAVCaptureVC.delegate = self
        self.flexibleAVCaptureVC.maximumRecordDuration = CMTime(seconds: 180.0, preferredTimescale: .max)
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(toggleVideo(gesture:)))
        self.img_thumbnail.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toggleVideo(gesture:)))
        self.videoView.addGestureRecognizer(tap)
        
        if gPost.idx > 0 && gPost.video_url.count > 0 && gPost.picture_url.count > 0 {
            loadPicture(imageView: img_thumbnail, url: URL(string: gPost.picture_url)!)
            txv_desc.text = gPost.content
            txv_desc.checkPlaceholder()
            lbl_desc.text = "Edit description"
            self.img_videomark.isHidden = false
            self.bgImage.isHidden = true
            self.videoView.isHidden = true
            self.addVideoBtn.setImage(UIImage(named: "pen"), for: .normal)
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
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
            if videoURL != nil {
                postVideo(post_id: gPost.idx, member_id: thisUser.idx, content: txv_desc.text, video_url: self.videoURL, thumbnail: thumbnailFile!)
            }else {
                updatePostWithoutVideo(post_id: gPost.idx, member_id: thisUser.idx, content: txv_desc.text)
            }
        }else {
            if self.videoURL == nil {
                showToast(msg: "Please load a video.")
                return
            }
            postVideo(post_id: 0, member_id: thisUser.idx, content: txv_desc.text, video_url: self.videoURL, thumbnail: thumbnailFile!)
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
        config.hidesStatusBar = false
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
    
    func postVideo(post_id: Int64, member_id:Int64, content:String, video_url:URL, thumbnail: Data){
        self.showLoadingView()
        APIs.postVideo(post_id: post_id, member_id: member_id, content: content, video_url: video_url, thumbnail: thumbnail, handleCallback: {
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
    
    func updatePostWithoutVideo(post_id: Int64, member_id:Int64, content:String){
        self.showLoadingView()
        APIs.editPostWithoutVideo(member_id: member_id, post_id: post_id, content: content, handleCallback: {
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
    
}
