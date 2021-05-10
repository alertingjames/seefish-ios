//
//  EditImagePostViewController.swift
//  See Fish
//
//  Created by Andre on 11/9/20.
//

import UIKit
import YPImagePicker
import GSImageViewerController
import AVFoundation
import MobileCoreServices

class EditImagePostViewController: BaseViewController, YPImagePickerDelegate, UINavigationControllerDelegate {
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
    
    var postPictures = [PostPicture]()
    
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
        
        txv_desc.text = gPost.content
        txv_desc.checkPlaceholder()
        
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        config.hidesStatusBar = false
        YPImagePickerConfiguration.shared = config
        
        getPostPictures(post: gPost)
        
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
                self.loadPictures(imageOperation: true)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func delPicture(_ sender: Any) {
        if self.sliderImagesArray.count > 0{
            if self.postPictures.count > self.pagecontroll.currentPage {
                let picture_id = self.postPictures[self.pagecontroll.currentPage].idx
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this picture?", preferredStyle: .alert)
                let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                    (action : UIAlertAction!) -> Void in })
                let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
                    self.deletePostPicture(picture_id: picture_id, post_id: gPost.idx)
                })
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                
                self.present(alert, animated: true, completion: nil)
            }else{
                self.sliderImagesArray.remove(self.sliderImagesArray[self.pagecontroll.currentPage])
                print("Current Page: \(self.pagecontroll.currentPage)")
                print("Images Count: \(self.sliderImagesArray.count)")
                if self.sliderImageFilesArray.count > 0 && self.pagecontroll.currentPage >= self.postPictures.count{
                    self.sliderImageFilesArray.remove(self.sliderImageFilesArray[self.pagecontroll.currentPage - self.postPictures.count])
                }
                self.loadPictures(imageOperation: true)
            }
        }
    }
    
    func loadPictures(imageOperation:Bool){
        print("Files: \(sliderImageFilesArray.count)")
        if sliderImageFilesArray.count > 0{
            lbl_files.text = "New loaded: " + String(sliderImageFilesArray.count)
        }else{
            lbl_files.text = "Loaded: " + String(sliderImagesArray.count)
        }
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
        self.image_scrollview.contentSize = CGSize(width: self.image_scrollview.frame.size.width * CGFloat(sliderImagesArray.count), height: self.image_scrollview.frame.size.height)
        self.pagecontroll.addTarget(self, action: #selector(self.changePage(_ :)), for: UIControl.Event.valueChanged)
        
        self.pagecontroll.numberOfPages = sliderImagesArray.count
        
        if self.sliderImagesArray.count == 0 {
            view_del.isHidden = true
            bgImg.isHidden = false
        }else {
            view_del.isHidden = false
            bgImg.isHidden = true
        }
        
        var x = CGFloat(self.pagecontroll.numberOfPages - 1) * self.image_scrollview.frame.size.width
        if !imageOperation{
            x = 0
            self.image_scrollview.setContentOffset(CGPoint(x: x, y :0), animated: true)
            self.pagecontroll.currentPage = 0
        }else{
            self.image_scrollview.setContentOffset(CGPoint(x: x, y :0), animated: true)
            self.pagecontroll.currentPage = self.pagecontroll.numberOfPages - 1
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
        if gPost.pictures == gPostPictures.count && txv_desc.text == gPost.content { return }
        if sliderImageFilesArray.count == 0 && sliderImagesArray.count == 0 {
            showToast(msg: "Please load at least one picture.")
            return
        }
        
        let parameters: [String:Any] = [
            "post_id" : String(gPost.idx),
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
                    self.showToast(msg: "Your feed updated successfully.")
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
    
    func getPostPictures(post: Post){
        self.showLoadingView()
        APIs.getPostPictures(post_id: post.idx,handleCallback: {
            pictures, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.postPictures = pictures!
                self.sliderImagesArray.removeAllObjects()
                    
                for pic in pictures! {
                    let image = self.getImageFromURL(url: URL(string: pic.image_url)!)
                    self.sliderImagesArray.add(image)
                }
                
                self.loadPictures(imageOperation: false)
                    
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
                self.image_scrollview.addGestureRecognizer(tap)
            }
        })
            
    }
    
    func deletePostPicture(picture_id: Int64, post_id:Int64){
        self.showLoadingView()
        APIs.deletePostPicture(picture_id: picture_id, post_id: post_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.sliderImagesArray.remove(self.sliderImagesArray[self.pagecontroll.currentPage])
                self.loadPictures(imageOperation: true)
            }else if result_code == "1"{
                self.showToast(msg: "This post doesn\'t exist")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
}









































