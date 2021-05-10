//
//  ImageSubmitViewController.swift
//  See Fish
//
//  Created by Andre on 11/5/20.
//

import UIKit
import YPImagePicker
import GSImageViewerController
import AVFoundation
import MobileCoreServices

class ImageSubmitViewController: BaseViewController, YPImagePickerDelegate, UINavigationControllerDelegate {
    func noPhotos() {
        print("No photos")
    }
    
    @IBOutlet weak var imageFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var imageAddBtn: UIButton!
    @IBOutlet weak var image_scrollview: UIScrollView!
    @IBOutlet weak var pagecontroll: UIPageControl!
    @IBOutlet weak var txv_desc: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var view_back: UIView!
    @IBOutlet weak var view_submit: UIView!
    @IBOutlet weak var view_del: UIView!
    @IBOutlet weak var view_add: UIView!
    @IBOutlet weak var lbl_files: UILabel!
    @IBOutlet weak var bgImg: UIImageView!
    
    var sliderImagesArray = NSMutableArray()
    var sliderImageFilesArray = NSMutableArray()
    var videoURL:URL!
    
    var config = YPImagePickerConfiguration()
    var picker = YPImagePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image_scrollview.delegate = self
        pagecontroll.numberOfPages = 0
        
        imageFrameHeight.constant = screenHeight * 2/3
        
        view_back.roundCorners(corners: [.bottomRight], radius: view_back.frame.height/2)
        view_submit.roundCorners(corners: [.bottomLeft], radius: view_submit.frame.height/2)
        view_add.roundCorners(corners: [.topLeft], radius: view_add.frame.height/2)
        view_del.roundCorners(corners: [.topRight], radius: view_del.frame.height/2)
        
        view_del.isHidden = true
        
        txv_desc.delegate = self
        txv_desc.setPlaceholder(string: "Write something here...")
        txv_desc.textContainerInset = UIEdgeInsets(top: txv_desc.textContainerInset.top, left: 8, bottom: txv_desc.textContainerInset.bottom, right: txv_desc.textContainerInset.right)
        
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        config.hidesStatusBar = false
        YPImagePickerConfiguration.shared = config
        
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

    @IBAction func takePicture(_ sender: Any) {
        picker.didFinishPicking { [picker] items, _ in
            if let photo = items.singlePhoto {
                self.sliderImagesArray.add(photo.image)
                let imageFile = photo.image.jpegData(compressionQuality: 0.8)
                self.sliderImageFilesArray.add(imageFile!)
                self.loadPictures()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func delPicture(_ sender: Any) {
        if self.sliderImagesArray.count > 0{
            self.sliderImagesArray.remove(self.sliderImagesArray[self.pagecontroll.currentPage])
            self.sliderImageFilesArray.remove(self.sliderImageFilesArray[self.pagecontroll.currentPage])
            self.loadPictures()
        }
    }
    
    func loadPictures(){
        print("Files: \(sliderImageFilesArray.count)")
        lbl_files.text = "Loaded: " +  String(sliderImagesArray.count)
        for i in 0..<sliderImagesArray.count {
            var imageView : UIImageView
            let xOrigin = self.image_scrollview.frame.width * CGFloat(i)
            imageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: self.image_scrollview.frame.width, height: self.image_scrollview.frame.height))
            imageView.isUserInteractionEnabled = true
            imageView.image = (sliderImagesArray.object(at: i) as! UIImage)
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
            imageView.tag = i
            imageView.addGestureRecognizer(tap)
            
            self.image_scrollview.addSubview(imageView)
        }
            
        self.image_scrollview.isPagingEnabled = true
        self.image_scrollview.bounces = false
        self.image_scrollview.showsVerticalScrollIndicator = false
        self.image_scrollview.showsHorizontalScrollIndicator = false
        self.image_scrollview.contentSize = CGSize(width:
            self.image_scrollview.frame.size.width * CGFloat(sliderImagesArray.count), height: self.image_scrollview.frame.size.height)
        self.pagecontroll.addTarget(self, action: #selector(self.changePage(_ :)), for: UIControl.Event.valueChanged)
            
        self.pagecontroll.numberOfPages = sliderImagesArray.count
            
        let x = CGFloat(self.pagecontroll.numberOfPages - 1) * self.image_scrollview.frame.size.width
        self.image_scrollview.setContentOffset(CGPoint(x: x, y :0), animated: true)
        self.pagecontroll.currentPage = self.pagecontroll.numberOfPages - 1
        if self.sliderImagesArray.count == 0 {
            view_del.isHidden = true
            bgImg.isHidden = false
        }else {
            view_del.isHidden = false
            bgImg.isHidden = true
        }
    }
    
    @objc func tappedScrollView(_ sender: UITapGestureRecognizer? = nil) {
        let imageView:UIImageView = (sender?.view as? UIImageView)!
        let index = imageView.tag
        let image = self.sliderImagesArray[index]
            
        let imageInfo   = GSImageInfo(image: image as! UIImage , imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: imageView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            
        imageViewer.dismissCompletion = {
                print("dismissCompletion")
        }
            
        present(imageViewer, animated: true, completion: nil)
    }
    
    @IBAction func changePage(_ sender: Any) {
        let x = CGFloat(pagecontroll.currentPage) * image_scrollview.frame.size.width
        image_scrollview.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(image_scrollview.contentOffset.x / image_scrollview.frame.size.width)
        pagecontroll.currentPage = Int(pageNumber)
    }
    
    
    @IBAction func submitPost(_ sender: Any) {
        if sliderImageFilesArray.count == 0 {
            showToast(msg: "Please load at least one picture.")
            return
        }
        
        let parameters: [String:Any] = [
            "post_id" : "0",
            "member_id" : String(thisUser.idx),
            "content" : self.txv_desc.text as Any,
            "pic_count" : String(self.sliderImageFilesArray.count) as Any,
        ]
        
        let ImageArray:NSMutableArray = []
        for image in self.sliderImageFilesArray{
            ImageArray.add(image as! Data)
        }
        
        self.showLoadingView()
        APIs().postImageArrayRequestWithURL(withUrl: SERVER_URL + "createimagepost", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("Post Response: \(response)")
            if isSuccess == true{
                let result = response["result_code"] as Any
                print("Result: \(result)")
                if result as! String == "0"{
                    self.showToast(msg: "Your feed posted successfully.")
                    gMainViewController.selectedIndex = 0
                    self.dismiss(animated: true, completion: nil)
                }else if result as! String == "1"{
                    self.showToast(msg: "Your account doesn\'t exist")
                    self.logout()
                }else{
                    self.showToast(msg: "Something is wrong")                    
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                self.showToast(msg: "Issue: \n" + message)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}









































