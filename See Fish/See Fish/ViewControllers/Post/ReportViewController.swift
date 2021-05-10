//
//  ReportViewController.swift
//  See Fish
//
//  Created by Andre on 12/12/20.
//

import UIKit

class ReportViewController: BaseViewController {
    
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var txv_message: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_send.isHidden = true

        img_user.layer.cornerRadius = img_user.frame.height / 2
        img_user.layer.borderWidth = 2.5
        img_user.layer.borderColor = UIColor.red.cgColor
        loadPicture(imageView: img_user, url: URL(string: gUser.photo_url)!)
        
        txv_message.setPlaceholder2(string: "Write your report here...")
        txv_message.layer.cornerRadius = 10
        txv_message.delegate = self
        txv_message.textContainerInset = UIEdgeInsets(top: 18, left: 8, bottom: txv_message.textContainerInset.bottom, right: txv_message.textContainerInset.right)
        
        txv_message.becomeFirstResponder()
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            btn_send.isHidden = true
        }else{
            btn_send.isHidden = false
        }
    }
    
    @IBAction func sendReport(_ sender: Any) {
        if txv_message.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Please write your report here...")
            return
        }
        sendReportMessage(me_id: thisUser.idx, member_id: gUser.idx, message: txv_message.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func sendReportMessage(me_id:Int64, member_id: Int64, message:String){
        self.showLoadingView()
        APIs.reportMember(member_id:member_id, reporter_id: me_id, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Your report submitted!")
                self.txv_message.text = ""
                self.txv_message.checkPlaceholder()
                self.btn_send.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg: "This user doesn\'t exist")
                self.dismissViewController()
            }else{
                self.showToast(msg: "Something is wrong")
                
            }
        })
    }

}
