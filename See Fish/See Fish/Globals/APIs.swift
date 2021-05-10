//
//  APIs.swift
//  See Fish
//
//  Created by Andre on 10/31/20.
//

import SwiftyJSON
import Alamofire

class APIs {
    
    static func login(email : String, password: String, handleCallback: @escaping (User?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "email":email,
            "password":password
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "login", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                
                NSLog("login result: \(json)")
                
                let result_code = json["result_code"].stringValue
                
                if result_code != nil {
                    
                    if(result_code == "0"){
                        
                        let data = json["data"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.followers = Int64(data["followers"] as! String)!
                        user.followings = Int64(data["followings"] as! String)!
                        user.feeds = Int64(data["feeds"] as! String)!
                        user.fcm_token = data["fcm_token"] as! String
                        user.terms = data["terms"] as! String
                        user.status = data["status"] as! String
                        
                        handleCallback(user, result_code)
                    
                    }else{
                        handleCallback(nil, result_code)
                    }
                }else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    func registerWithPicture(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,withImages imageArray:NSMutableArray,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Image Array
            for (imageDic) in imageArray
            {
                let imageDic = imageDic as! NSDictionary
                
                for (key,valus) in imageDic
                {
                    MultipartFormData.append(valus as! Data, withName:key as! String, fileName: String(NSDate().timeIntervalSince1970) + ".jpg", mimeType: "image/jpg")
                }
            }
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    func registerWithoutPicture(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    static func forgotPassword(email : String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "email":email
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "forgotpassword", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    handleCallback("0")
                }
                else if(json["result_code"].stringValue == "1"){
                    handleCallback("1")
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    static func likePost(member_id:Int64, post_id:Int64, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "post_id": String(post_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "likepost", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        let likes = json["likes"].stringValue
                        handleCallback(likes, result_code)
                    }else{
                        handleCallback("", result_code)
                    }
                    
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    static func savePost(member_id:Int64, post_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "post_id": String(post_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "savepost", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        handleCallback(result_code)
                    }else{
                        handleCallback(result_code)
                    }
                    
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func getComments(me_id:Int64, post_id: Int64, handleCallback: @escaping ([Comment]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "me_id" : String(me_id),
            "post_id":String(post_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getcomments", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var comments = [Comment]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["comment"].object as! [String: Any]
                        let comment = Comment()
                        comment.idx = data["id"] as! Int64
                        comment.post_id = Int64(data["post_id"] as! String)!
                        comment.comment = data["comment_text"] as! String
                        comment.image_url = data["image_url"] as! String
                        comment.commented_time = data["commented_time"] as! String
                        comment.status = data["status"] as! String
                        
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.followers = Int64(data["followers"] as! String)!
                        user.followings = Int64(data["followings"] as! String)!
                        user.feeds = Int64(data["feeds"] as! String)!
                        user.fcm_token = data["fcm_token"] as! String
                        user.terms = data["terms"] as! String
                        user.status = data["status"] as! String
                        
                        comment.user = user
                        
                        comments.append(comment)
                    }
                    
                    handleCallback(comments, "0")
                    
                }else if result_code == "1" || result_code == "101" || result_code == "102" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func getPosts(member_id: Int64, handleCallback: @escaping ([Post]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "networkposts", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var posts = [Post]()
                    var post:Post!
                    
                    var dataArray = json["posts"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        post.video_url = data["video_url"] as! String
                        post.comments = Int64(data["comments"] as! String)!
                        post.likes = Int64(data["likes"] as! String)!
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        
                        if data["saved"] as! String == "yes"{
                            post.isSaved = true
                        }else {
                            post.isSaved = false
                        }
                        post.status = data["status"] as! String
                        
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.followers = Int64(data["followers"] as! String)!
                        user.followings = Int64(data["followings"] as! String)!
                        if data["followed"] as! String == "yes"{
                            user.followed = true
                        }else {
                            user.followed = false
                        }
                        user.feeds = Int64(data["feeds"] as! String)!
                        user.fcm_token = data["fcm_token"] as! String
                        user.terms = data["terms"] as! String
                        user.status = data["status"] as! String
                        
                        post.user = user
                        
                        let pics = json["pics"].stringValue
                        let pic_count = Int(pics)
                        
                        post.pictures = pic_count!
                        
                        posts.append(post)
                    }
                    
                    handleCallback(posts, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func deletePost(post_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "post_id": String(post_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "deletepost", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func deleteComment(comment_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "comment_id": String(comment_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "deletecomment", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func getPostPictures(post_id: Int64, handleCallback: @escaping ([PostPicture]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "post_id":String(post_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getpostpictures", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var pics = [PostPicture]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let pic = PostPicture()
                        pic.idx = data["id"] as! Int64
                        pic.post_id = Int64(data["post_id"] as! String)!
                        pic.image_url = data["picture_url"] as! String
                        
                        pics.append(pic)
                    }
                    
                    handleCallback(pics, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    func postImageArrayRequestWithURL(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,withImages imageArray:NSMutableArray,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Image Array
            for image in imageArray
            {
                let imageData = image as! Data
                
                MultipartFormData.append(imageData, withName:"file" + String(imageArray.index(of: image)), fileName: String(NSDate().timeIntervalSince1970) + ".jpg", mimeType: "image/jpg")
            }
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    print("Status Code: \(response.response?.statusCode)")
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    
    static func postVideo(post_id: Int64, member_id:Int64, content:String, video_url: URL, thumbnail: Data, handleCallback: @escaping (String) -> ())
    {
        let url = SERVER_URL + "createvideopost"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append("\(post_id)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "post_id")
                multipartFormData.append("\(member_id)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "member_id")
                multipartFormData.append(content.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "content")
                multipartFormData.append(video_url, withName: "video")
                multipartFormData.append(thumbnail, withName: "thumbnail", fileName: String(Int64(Date().timeIntervalSince1970)) + ".jpg", mimeType: "image/jpeg")
        },
            to: url,
            /*method: .post,
             headers: nil,*/
            encodingCompletion: { encodingResult in
                NSLog("\(encodingResult)")
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (progress) in
                        print("uploding")
                    })
                    upload.responseJSON { response in
                        if response.result.isFailure{
                            handleCallback("Server issue")
                        }
                        else{
                            let json = JSON(response.result.value!)
                            NSLog("\(json)")
                            if(json["result_code"].stringValue == "0"){
                                handleCallback("0")
                            }else{
                                handleCallback("Server issue")
                            }
                        }
                    }
                case .failure(let encodingError):
                    handleCallback("Server issue")
                }
        })
        
    }
    
    
    static func sendMessage(me_id:Int64, member_id:Int64, message:String, handleCallback: @escaping (String) -> ()) {
        //NSLog(url)
        let params = [
            "me_id": String(me_id),
            "member_id": String(member_id),
            "message": message
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "sendmessage", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func registerFCMToken(member_id:Int64, token:String, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "fcm_token":token,
            "member_id": String(member_id),
            ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "uploadfcmtoken", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                if(json["result_code"].stringValue == "0"){
                    handleCallback(json["fcm_token"].stringValue, "0")
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    
    static func getallmembers(member_id: Int64, handleCallback: @escaping ([User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getallmembers", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()                    
                    let dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.followers = Int64(data["followers"] as! String)!
                        user.followings = Int64(data["followings"] as! String)!
                        if data["followed"] as! String == "yes"{
                            user.followed = true
                        }else {
                            user.followed = false
                        }
                        user.feeds = Int64(data["feeds"] as! String)!
                        user.fcm_token = data["fcm_token"] as! String
                        user.terms = data["terms"] as! String
                        user.status = data["status"] as! String
                        
                        users.append(user)
                    }
                    
                    handleCallback(users, "0")
                    
                }else if result_code == "1" || result_code == "2"{
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func getUserPosts(me_id: Int64, member_id:Int64, handleCallback: @escaping ([Post]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "me_id":String(me_id),
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getmemberposts", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var posts = [Post]()
                    
                    let dataArray = json["posts"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        let data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        post.video_url = data["video_url"] as! String
                        post.comments = Int64(data["comments"] as! String)!
                        post.likes = Int64(data["likes"] as! String)!
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        
                        if data["saved"] as! String == "yes"{
                            post.isSaved = true
                        }else {
                            post.isSaved = false
                        }
                        post.status = data["status"] as! String
                        
                        let pics = json["pics"].stringValue
                        let pic_count = Int(pics)
                        
                        post.pictures = pic_count!
                        
                        posts.append(post)
                    }
                    
                    handleCallback(posts, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func followMember(member_id:Int64, me_id:Int64, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "me_id": String(me_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "followmember", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        let followers = json["followers"].stringValue
                        handleCallback(followers, result_code)
                    }else{
                        handleCallback("", result_code)
                    }
                    
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    
    static func getFollowers(me_id: Int64, member_id: Int64, handleCallback: @escaping ([User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "me_id":String(me_id),
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getfollowers", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Member Followers: \(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()
                    let dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.followers = Int64(data["followers"] as! String)!
                        user.followings = Int64(data["followings"] as! String)!
                        if data["followed"] as! String == "yes"{
                            user.followed = true
                        }else {
                            user.followed = false
                        }
                        user.feeds = Int64(data["feeds"] as! String)!
                        user.fcm_token = data["fcm_token"] as! String
                        user.terms = data["terms"] as! String
                        user.status = data["status"] as! String
                        
                        users.append(user)
                    }
                    
                    handleCallback(users, "0")
                    
                }else if result_code == "1" || result_code == "2"{
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func getFollowings(me_id: Int64, member_id: Int64, handleCallback: @escaping ([User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "me_id":String(me_id),
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getprofilefollowings", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Followings: \(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()
                    let dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.followers = Int64(data["followers"] as! String)!
                        user.followings = Int64(data["followings"] as! String)!
                        if data["followed"] as! String == "yes"{
                            user.followed = true
                        }else {
                            user.followed = false
                        }
                        user.feeds = Int64(data["feeds"] as! String)!
                        user.fcm_token = data["fcm_token"] as! String
                        user.terms = data["terms"] as! String
                        user.status = data["status"] as! String
                        
                        users.append(user)
                    }
                    
                    handleCallback(users, "0")
                    
                }else if result_code == "1" || result_code == "2"{
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func getMemberLikes(member_id:Int64, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getmemberlikes", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        let likes = json["likes"].stringValue
                        handleCallback(likes, result_code)
                    }else{
                        handleCallback("", result_code)
                    }
                    
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    static func editPostWithoutPicture(member_id:Int64, post_id:Int64, content:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params: [String:Any] = [
            "post_id" : String(post_id),
            "member_id" : String(thisUser.idx),
            "content" : content,
            "pic_count" : "0",
        ]
        
        Alamofire.request(SERVER_URL + "createimagepost", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                    
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func editPostWithoutVideo(member_id:Int64, post_id:Int64, content:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params: [String:Any] = [
            "post_id" : String(post_id),
            "member_id" : String(thisUser.idx),
            "content" : content,
        ]
        
        Alamofire.request(SERVER_URL + "createvideopost", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                    
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func deletePostPicture(picture_id:Int64, post_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "picture_id": String(picture_id),
            "post_id": String(post_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "delpostpicture", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func getMeLikes(member_id:Int64, handleCallback: @escaping (String, String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getmelikes", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        let likes = json["likes"].stringValue
                        let saveds = json["saveds"].stringValue
                        handleCallback(likes, saveds, result_code)
                    }else{
                        handleCallback("", "", result_code)
                    }
                    
                }else {
                    handleCallback("", "", "Server issue")
                }
            }
        }
    }
    
    static func changePassword(member_id:Int64, password:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "password": password
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "changepassword", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)                    
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func getMyLikes(member_id: Int64, handleCallback: @escaping ([PostLike]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getmylikes", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Likes: \(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var pls = [PostLike]()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let pl = PostLike()
                        pl.idx = data["id"] as! Int64
                        pl.post_id = Int64(data["post_id"] as! String)!
                        pl.user_id = Int64(data["member_id"] as! String)!
                        
                        pls.append(pl)
                    }
                    
                    handleCallback(pls, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func getSavedFeeds(member_id: Int64, handleCallback: @escaping ([PostSave]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getsavedposts", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Saveds: \(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var psvs = [PostSave]()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let psv = PostSave()
                        psv.idx = data["id"] as! Int64
                        psv.post_id = Int64(data["post_id"] as! String)!
                        psv.user_id = Int64(data["member_id"] as! String)!
                        
                        psvs.append(psv)
                    }
                    
                    handleCallback(psvs, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func getStories(member_id: Int64, handleCallback: @escaping ([Story]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getstories", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var stories = [Story]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let story = Story()
                        story.idx = data["id"] as! Int64
                        story.content = data["content"] as! String
                        story.picture_url = data["picture_url"] as! String
                        story.video_url = data["video_url"] as! String
                        story.views = Int64(data["views"] as! String)!
                        story.posted_time = data["posted_time"] as! String
                        story.pictures = Int(data["pics"] as! String)!
                        story.status = data["status"] as! String
                        
                        stories.append(story)
                    }
                    
                    handleCallback(stories, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func identifyFish(deviceID: String, file: Data?, handleCallback: @escaping (String, String, String) -> ())
    {
        let url = SERVER_URL + "fishidentify"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(deviceID.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "ID")
                if file != nil {
                    multipartFormData.append(file!, withName: "file", fileName: String(Int64(Date().timeIntervalSince1970)) + ".jpg", mimeType: "image/jpeg")
                    //                    multipartFormData.append(file!, withName: "file")
                }
        },
            to: url,
            /*method: .post,
             headers: nil,*/
            encodingCompletion: { encodingResult in
                NSLog("\(encodingResult)")
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if response.result.isFailure{
                            handleCallback("", "", "Server issue")
                        }
                        else
                        {
                            let json = JSON(response.result.value!)
                            NSLog("\(json)")
                            if(json["result_code"].stringValue == "0"){
                                let name = json["name"].stringValue
                                let prob = json["prob"].stringValue
                                
                                handleCallback(name, prob, "0")
                            }else{
                                handleCallback("", "", "Server issue")
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    handleCallback("", "", "Server issue")
                }
        })
        
    }
    
    static func reportMember(member_id:Int64, reporter_id:Int64, message:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "reporter_id": String(reporter_id),
            "message": message
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "reportmember", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func readTerms(member_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "readterms", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("READ TERMS response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func blockUser(member_id:Int64, blocker_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "blocker_id": String(blocker_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "blockuser", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("BLOCK USER response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func unblockUser(member_id:Int64, blocker_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "blocker_id": String(blocker_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "userunblock", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("BLOCK USER response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func getBlockedUsers(member_id: Int64, handleCallback: @escaping ([User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getblocks", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Blocked members: \(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()
                    let dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.followers = Int64(data["followers"] as! String)!
                        user.followings = Int64(data["followings"] as! String)!
                        if data["followed"] as! String == "yes"{
                            user.followed = true
                        }else {
                            user.followed = false
                        }
                        user.feeds = Int64(data["feeds"] as! String)!
                        user.fcm_token = data["fcm_token"] as! String
                        user.terms = data["terms"] as! String
                        user.status = data["status"] as! String
                        
                        users.append(user)
                    }
                    
                    handleCallback(users, "0")
                    
                }else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
}





















































