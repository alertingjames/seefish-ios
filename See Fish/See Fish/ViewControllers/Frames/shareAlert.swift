//
//  shareAlert.swift
//  See Fish
//
//  Created by james on 8/25/23.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import Photos
import Social

class shareAlert: BaseViewController {
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    var progressVC:ProgressVC!
    var shareOption:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        gShareAlert = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        view.addGestureRecognizer(tap)
        
    }
    
    func showButtonFrame() {
        UIView.animate(withDuration: 0.2) {
            self.buttonsView.alpha = 1.0
        }
    }
    
    func closeDialog() {
        UIView.animate(withDuration: 0.3) {
            self.buttonsView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
    @objc func dismissDialog() {
        closeDialog()
    }
    
    @IBAction func toFB(_ sender: Any) {
        shareOption = "FB"
        if gPost.video_url != "" {
            downloadVideo()
        } else if gPost.picture_url != "" {
            downloadImage(from: URL(string: gPost.picture_url)!)
        }
    }
    
    @IBAction func toTW(_ sender: Any) {
        shareOption = "TW"
        if gPost.video_url != "" {
            downloadVideo()
        } else if gPost.picture_url != "" {
            downloadImage(from: URL(string: gPost.picture_url)!)
        }
    }
    
    @IBAction func toINS(_ sender: Any) {
        shareOption = "INS"
        if gPost.video_url != "" {
            downloadVideo()
        } else if gPost.picture_url != "" {
            downloadImage(from: URL(string: gPost.picture_url)!)
        }
    }
    
    func downloadVideo() {
        showProgressView()
        let downloadTask = DownloadTask()
        downloadTask.download(url: gPost.video_url) { [weak self] totalDownloaded in
            self?.updateProgress(val: totalDownloaded)
        }
    }
    
    func showProgressView(){
        progressVC = (UIStoryboard(name: "Frames", bundle: nil).instantiateViewController(withIdentifier: "ProgressVC") as! ProgressVC)
        progressVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.addChild(progressVC)
        self.view.addSubview(progressVC.view)
    }
    
    func dismissProgressView(){
        if progressVC != nil {
            progressVC.view.removeFromSuperview()
            progressVC.removeFromParent()
        }
    }
    
    func updateProgress(val:Float) {
        if progressVC != nil {
            progressVC.progressView.progress = val
            progressVC.progressView.setProgress(progressVC.progressView.progress, animated: true)
            progressVC.percentageBox.text = String(format:"%.2f", val * 100) + "%"
        }
    }
    
    func finalizeDownload(furl:URL) {
        dismissProgressView()
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(Date().timeStamp()).mp4")
        var status = "failure"
        do {
            let data : Data? = try! Data(contentsOf:furl) as Data?
            try data?.write(to: filePath)
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath)
            }) { completed, error in
                if completed {
                    print("Saved to gallery! \(filePath.downloadURL)")
                    status = "success"
                } else if let error = error {
                    print(error.localizedDescription)
                    status = "failure"
                }
            }
        } catch {
            print(error.localizedDescription)
            status = "failure"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let furl = filePath.downloadURL
            if status == "success" {
                if self.shareOption == "FB" {
                    var quote = gPost.title + "\n" + gPost.category
                    if gPost.content.count > 0 { quote += "\n" + gPost.content }
                    let activityViewController = self.share(items: [quote,
                                                                    furl])
                    self.present(activityViewController,
                                 animated: true)
                } else if self.shareOption == "TW" {
                    var quote = gPost.title + "\n" + gPost.category
                    if gPost.content.count > 0 { quote += "\n" + gPost.content }
                    let activityViewController = self.share(items: [quote,
                                                                    furl])
                    self.present(activityViewController,
                                 animated: true)
                } else if self.shareOption == "INS" {
                    let activityVC = UIActivityViewController(activityItems: [furl as Any], applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.view
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func share(items: [Any],
                       excludedActivityTypes: [UIActivity.ActivityType]? = nil,
                       ipad: (forIpad: Bool, view: UIView?) = (false, nil)) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items,
                                                              applicationActivities: nil)
        if ipad.forIpad {
            activityViewController.popoverPresentationController?.sourceView = ipad.view
        }
        
        if let excludedActivityTypes = excludedActivityTypes {
            activityViewController.excludedActivityTypes = excludedActivityTypes
        }
        
        return activityViewController
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        showLoadingView()
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.shareImage(data: data)
            }
        }
    }
    
    func shareImage(data:Data) {
        dismissLoadingView()
        if self.shareOption == "FB" {
            var quote = gPost.title + "\n" + gPost.category
            if gPost.content.count > 0 { quote += "\n" + gPost.content }
            let content = SharePhotoContent()
            let photo = SharePhoto(
                image: UIImage(data: data) as! UIImage,
                isUserGenerated: true
            )
            photo.caption = quote
            content.photos.append(photo)
            let dialog = ShareDialog(viewController: self, content: content, delegate: self)
            // Recommended to validate before trying to display the dialog
            do {
                try dialog.validate()
            } catch {
                print(error)
            }
            dialog.show()
        } else if self.shareOption == "TW" {
            var quote = gPost.title + "\n" + gPost.category
            if gPost.content.count > 0 { quote += "\n" + gPost.content }
            let activityViewController = self.share(items: [quote,
                                                            UIImage(data: data)])
            self.present(activityViewController,
                         animated: true)
        } else if self.shareOption == "INS" {
            let activityVC = UIActivityViewController(activityItems: [UIImage(data: data)], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
}


extension shareAlert: SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print(results)
        presentAlert(title: "Success", message: "Post is done!")
    }

    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        presentAlert(for: error)
    }

    func sharerDidCancel(_ sharer: Sharing) {
        presentAlert(title: "Cancelled", message: "Sharing cancelled")
    }
}
