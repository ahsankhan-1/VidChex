//
//  ChatVC.swift
//  VidChex
//
//  Created by M Hayat on 13/01/2023.
//

import UIKit
import FirebaseDatabase
import IQKeyboardManagerSwift
import SDWebImage
import FirebaseFirestore

class ChatVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    
    @IBOutlet weak var MessageTableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var ChatTextView: UITextView!
    @IBOutlet weak var tvBottomConstraint: NSLayoutConstraint!
    
    
    let date = Date()
    let formatter = DateFormatter()
    
    var recevireId = ""
    var orderUserDic:NSDictionary = [:]
    var image = ""
    var online = ""
    var chatkeys = [String]()
    var chattingDic:[NSDictionary] = []
    var listid = ""
    
    let navigationView = UIView(frame: CGRect(x: 0, y: 0, width: 330, height: 50))
    var ProfileImg = UIImageView(frame: CGRect(x: -25, y: 0, width: 45, height: 45))
    let NameLbl = UILabel(frame: CGRect(x: 35, y: 3, width: 200, height: 20))
    let onlineLbl = UILabel(frame: CGRect(x: 35, y: 23, width: 200, height: 20))
    let Blockbutton = UIButton(frame: CGRect(x: 270, y: 0, width: 80, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserskeys()
        reteriveUserData()
        getBlockData()
        
        MessageTableView.delegate = self
        MessageTableView.dataSource = self
        tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        
        //   MessageTableView.contentInset = UIEdgeInsets(top: -MessageTableView.adjustedContentInset.top, left: 0, bottom: 0, right: 0)
        
        
        sendBtn.layer.cornerRadius = 7
        
        ChatTextView.layer.cornerRadius = ChatTextView.layer.frame.height/2
        ChatTextView.layer.borderWidth = 0.7
        ChatTextView.layer.borderColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.9176470588, alpha: 0.7614513675)
        ChatTextView.delegate = self
        ChatTextView.text = "Write your message here...."
        ChatTextView.textColor = UIColor.lightGray
        ChatTextView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        MessageTableView.estimatedRowHeight = 50
        MessageTableView.rowHeight = UITableView.automaticDimension
    
        let rightbtn = UIBarButtonItem(customView: navigationView)
        self.navigationItem.rightBarButtonItem = rightbtn
        navigationView.backgroundColor = .white
        
        NameLbl.backgroundColor = .clear
        NameLbl.textColor = .black
        navigationView.addSubview(NameLbl)
        
        NameLbl.font = NameLbl.font.withSize(18)
        let RightBtn = UIBarButtonItem(customView: navigationView)
        self.navigationItem.rightBarButtonItem = RightBtn
        navigationView.backgroundColor = .white
        
        onlineLbl.backgroundColor = .clear
        onlineLbl.textColor = .gray
        navigationView.addSubview(onlineLbl)
        onlineLbl.font = onlineLbl.font.withSize(14)
        let rightBtn = UIBarButtonItem(customView: navigationView)
        self.navigationItem.rightBarButtonItem = rightBtn
        navigationView.backgroundColor = .clear
        
        ProfileImg.image = UIImage(named: "profile")
        ProfileImg.contentMode = UIView.ContentMode.scaleAspectFill
        ProfileImg.layer.cornerRadius = ProfileImg.frame.height / 2
        ProfileImg.layer.borderWidth = 2
        ProfileImg.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ProfileImg.layer.masksToBounds = true
        self.navigationView.addSubview(ProfileImg)
        
        let rightBarButton = UIBarButtonItem(customView: navigationView)
        navigationItem.rightBarButtonItem = rightBarButton
        
        Blockbutton.setTitleColor(.red, for: .normal)
        Blockbutton.setTitle("Block", for: .normal)
        Blockbutton.titleLabel?.font = UIFont(name: "Arial", size: 16)
        navigationView.addSubview(Blockbutton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationView)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(BlockAction))
        Blockbutton.isUserInteractionEnabled = true
        Blockbutton.addGestureRecognizer(tapGesture)
        
        if online == "" {
            onlineLbl.text = "online"
        }else if online == "online" {
            onlineLbl.text = self.online
        } else {
            let date = Int(self.online)
            let time3 = TimestampToStringAgo(timestamp: Int64(date!))
            onlineLbl.text = time3
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func BlockAction(){
        
        if Blockbutton.isSelected == true {
            Blockbutton.isSelected = false
            Blockbutton.setTitle("UnBlock", for: .normal)
            self.sendBtn.isUserInteractionEnabled = false
            self.ChatTextView.isUserInteractionEnabled = false
            
            let ref = Helper.dbRef.collection("blockedlist")
            let autoid = ref.document().documentID
            let para = ["id":autoid,"createOn":NSDate.now,"blockedby":Helper.userId,"blockto":self
                .recevireId] as [String : Any]
            Helper.dbRef.collection("blockedlist").document(autoid).setData(para)
            
        } else {
            Blockbutton.isSelected = true
            Blockbutton.setTitle("Block", for: .normal)
            self.sendBtn.isUserInteractionEnabled = true
            self.ChatTextView.isUserInteractionEnabled = true
            
            Helper.dbRef.collection("blockedlist").document(self.listid).delete()
            
        }
    }
    //MARK: get Block Data  -
    
    func getBlockData() {
        
        showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("blockedlist").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retreiving snapshots \(error!)")
                return
            }
            for document in snapshot.documents {
                let postTempDic = document.data() as NSDictionary
                
                if postTempDic["blockedby"] as? String ?? "" == Helper.userId {
                    self.listid = postTempDic["id"] as? String ?? ""
                    self.Blockbutton.isSelected = false
                    self.Blockbutton.setTitle("UnBlock", for: .normal)
                    self.sendBtn.isUserInteractionEnabled = false
                    self.ChatTextView.isUserInteractionEnabled = false
                    self.hideIndicator()
                } else if postTempDic["blockto"] as? String ?? "" == Helper.userId {
                    self.listid = postTempDic["id"] as? String ?? ""
                    self.Blockbutton.isSelected = false
                    self.Blockbutton.setTitle("Blocked", for: .normal)
                    self.Blockbutton.isUserInteractionEnabled = false
                    self.sendBtn.isUserInteractionEnabled = false
                    self.ChatTextView.isUserInteractionEnabled = false
                    self.hideIndicator()
                }
            }
            
        }
        self.hideIndicator()
        self.Blockbutton.isSelected = true
        self.sendBtn.isUserInteractionEnabled = true
        self.ChatTextView.isUserInteractionEnabled = true
        self.Blockbutton.setTitle("Block", for: .normal)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tvBottomConstraint.constant = keyboardSize.height + 20
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tvBottomConstraint.constant = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = "Write your message here...."
            textView.textColor = UIColor.lightGray
            
        }
    }
    
    @objc func BackButton(){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        
        if ChatTextView.text == "" {
            
        } else {
            
            let txt =  ChatTextView.text.condensingWhitespace()
            let mesgKey = (Helper.dbChatRef.childByAutoId().key)!
            let date1 = Date().millisecondsSince1970
            let chatPara = ["createdOn":date1,"msg":txt,"recieverId":self.recevireId,"seen":false,"senderId":Helper.userId, "type":"text"] as [String : Any]
            Helper.dbChatRef.child("chat").child(mesgKey).setValue(chatPara)
            
            let chatListpara = ["date":date1,"id":self.recevireId,"lastMsg":txt] as [String : Any]
            Helper.dbChatRef.child("chatList").child(Helper.userId).child(self.recevireId).updateChildValues(chatListpara)
            
            let chatList = ["date":date1,"id":Helper.userId,"lastMsg":txt] as [String : Any]
            Helper.dbChatRef.child("chatList").child(self.recevireId).child(Helper.userId).updateChildValues(chatList)
            
            ChatTextView.text = ""
            
        }
    }
    
    //MARK: Table View -
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chattingDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MessageTableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        cell.sendLbl.layer.cornerRadius = 16
        cell.sendLbl.layer.masksToBounds = true
        cell.sendLbl.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner]
        
        cell.receiveLbl.layer.cornerRadius = 16
        cell.receiveLbl.layer.masksToBounds = true
        cell.receiveLbl.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner]
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.sendLbl.isHidden = true
        cell.receiveLbl.isHidden = true
        cell.seenLbl.isHidden = true
        cell.recevertimeLbl.isHidden = true
        
        if self.chattingDic[indexPath.row]["recieverId"] as? String ?? "" == Helper.userId {
            cell.receiveLbl.text = self.chattingDic[indexPath.row]["msg"] as? String ?? ""
            let time = self.chattingDic[indexPath.row]["createdOn"] as? Int ?? 0
            cell.recevertimeLbl.text = timestampToStringAgo(timestamp: Int64(time))
            cell.receiveLbl.isHidden = false
            cell.recevertimeLbl.isHidden = false
            
        }else if self.chattingDic[indexPath.row]["senderId"] as? String ?? "" == Helper.userId {
            cell.sendLbl.text = self.chattingDic[indexPath.row]["msg"] as? String ?? ""
            let time = self.chattingDic[indexPath.row]["createdOn"] as? Int ?? 0
            cell.seenLbl.text = timestampToStringAgo(timestamp: Int64(time))
            cell.sendLbl.isHidden = false
            cell.seenLbl.isHidden = false
            
            
        }
        return cell
    }
    //MARK: tableView willDisplay -
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0)
        if indexPath.row == lastRowIndex - 1 {
            tableView.scrollToBottom(animated: true)
        }
    }
    
    //MARK: reterive UserData -
    func reteriveUserData(){
        
        Helper.dbRef.collection("userProfile").document(self.recevireId).addSnapshotListener { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
            let dic = snap as NSDictionary
            let imgUrl = dic["profileImg"] as? String ?? ""
            self.ProfileImg.sd_setImage(with: URL(string: imgUrl),placeholderImage: UIImage(named: "profile"))
            let fullName = (dic["fname"] as? String ?? "" ) + " " + (dic["lname"] as? String ?? "" )
            self.NameLbl.text = fullName
        }
    }
    //MARK: get Users keys -
    func getUserskeys(){
        
        Helper.dbChatRef.child("chat").observe( .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let keys = Array(dictionary.keys)
                self.chatkeys  =  keys.sorted(by: <)
                let connectedRef = Database.database().reference(withPath: ".info/connected")
                connectedRef.observe(.value, with: { (snapshot) in
                    if snapshot.value as? Bool ?? false {
                        self.retriveMessageData()
                    } else {
                        print("error loading")
                        return
                    }
                })
            }
        })
        {
            (error) in
            print(error.localizedDescription)
            let alert = UIAlertController(title: "No Network", message: "Please connect to internet and try again", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        }
    }
    //MARK: retrive MessageData -
    func retriveMessageData(){
        self.chattingDic.removeAll()
        for key in self.chatkeys {
            Helper.dbChatRef.child("chat").child(key).observe(.value) { snapShopt in
                guard snapShopt.exists() else {
                    print("Post are not found")
                    return
                }
                let snap = snapShopt.value as? NSDictionary ?? [:]
                
                if (snap["senderId"] as? String ?? "" == Helper.userId && snap["recieverId"] as? String ?? "" == self.recevireId) || (snap["senderId"] as? String ?? "" == self.recevireId && snap["recieverId"] as? String ?? "" == Helper.userId) {
                    
                    self.chattingDic.append(snap)
                    self.reloadData()
                    
                }
            }
        }
    }
    func reloadData(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [self] in
            let contentOffset = MessageTableView.contentOffset
            MessageTableView.reloadData()
            MessageTableView.layoutIfNeeded()
            MessageTableView.setContentOffset(contentOffset, animated: false)
            
            let scrollPoint = CGPoint(x: 0, y: self.MessageTableView.contentSize.height - self.MessageTableView.frame.size.height)
            self.MessageTableView.setContentOffset(scrollPoint, animated: true)
        }
    }
}

//MARK: Auto Message Function -
extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0){
            self.scrollToRow(at: NSIndexPath(row: rows - 1, section: sections - 1) as IndexPath, at: .bottom, animated: true)
        }
    }
}

extension UIViewController{
    func TimestampToStringAgo(timestamp: Int64) -> String{
        let actualTime = Int64(Date().timeIntervalSince1970*1000)
        var lastSeenTime = actualTime - timestamp
        lastSeenTime /= 1000 //seconds
        var lastTimeString = ""
        if lastSeenTime < 60 {
            if lastSeenTime == 10 {
                lastTimeString = "Just now"
            } else {
                lastTimeString = "just now"
            }
        } else {
            lastSeenTime /= 60
            if lastSeenTime < 60 {
                if lastSeenTime == 1 {
                    lastTimeString = "Active" + " " + String(lastSeenTime) + " minute ago"
                } else {
                    lastTimeString = "Active" + " " + String(lastSeenTime) + " minute ago"
                }
            } else {
                lastSeenTime /= 60
                if lastSeenTime < 24 {
                    if lastSeenTime == 1 {
                        lastTimeString = "Active" + " " + String(lastSeenTime) + " hour ago"
                    } else {
                        lastTimeString = "Active" + " " + String(lastSeenTime) + " hours ago"
                    }
                } else {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    lastTimeString = formatter.string(from: Date(milliseconds: timestamp))
                    print(lastTimeString,"Day")
                    if lastTimeString == "1" {
                        lastTimeString = "Active" + " " + lastTimeString + " " + "day ago"
                    } else {
                        lastTimeString = "Active" + " " + lastTimeString + " " + "days ago"
                    }
                }
            }
        }
        return lastTimeString
    }
}

extension String {
    func condensingWhitespace() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
