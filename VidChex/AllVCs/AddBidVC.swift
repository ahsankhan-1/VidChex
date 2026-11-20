//
//  AddBidVC.swift
//  VidChex
//
//  Created by M Hayat on 02/01/2023.
//

import UIKit

class AddBidVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bidTF: UITextField!
    @IBOutlet weak var bidBtn: UIButton!
    
    
    var maxLen:Int = 8
    var highestBid = ""
    var postkey = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.layer.cornerRadius = 7
        bidTF.layer.cornerRadius = 7
        bidBtn.layer.cornerRadius = 7
        
        bidTF.delegate = self
        bidTF.keyboardType = .numberPad
        
        print(Helper.highestBidPrice,"highestBid")
        print(Helper.buildingid,"postkey")
               
    }
    
    @IBAction func bidBtnAction(_ sender: Any) {
        
       
        if bidTF.text == "" {
            Toast.showToast(message: "Please give price", controller: self)
        } else if Int(bidTF.text ?? "") ?? 0 <= Helper.highestBidPrice {
            self.errorWithMsg(message: "Price should be greater than \(Helper.highestBidPrice)")
        //    Toast.showToast(message: "Price should be greater than \(Helper.highestBidPrice)", controller: self)
        } else {
            
            showIndicator(caption: "Please wait...")
            let price = Int(bidTF.text ?? "") ?? 0
            print(price,"price")
            
            let ref = Helper.dbRef.collection("bids")
            let autoid = ref.document().documentID
            print(autoid,"autoid")
            let fullName = (Helper.userDic["fname"] as? String ?? "" ) + " " + (Helper.userDic["lname"] as? String ?? "" )
            
            let parametter = ["buildingId":Helper.buildingid,"createdOn":NSDate.now,"id":autoid,"name":fullName,"price":price,"uid":Helper.userId] as [String : Any]
            Helper.dbRef.collection("bids").document(autoid).setData(parametter)

            let para = ["highestBidderName":fullName,"highestBid":price,"createdOn":NSDate.now] as [String : Any]
            Helper.dbRef.collection("buildings").document(Helper.buildingid).updateData(para)

            let imgUrl = Helper.userDic["profileImg"] as? String ?? ""
            let Name = (Helper.userDic["fname"] as? String ?? "" ) + " " + (Helper.userDic["lname"] as? String ?? "" )
            let Ref = Helper.dbRef.collection("notifications")
            let autoId = Ref.document().documentID

            
            
            let NotificationPara = ["content":"\(Name) bid for $\(price )","createdOn":NSDate.now,"id":autoId,"productId":Helper.buildingid,"read":false,"receiverId":HomeDetailsVC.recevireid,"senderId":Helper.userId,"senderImg":imgUrl,"title":"New bid","type":"1"] as [String : Any]
            Helper.dbRef.collection("notifications").document(autoId).setData(NotificationPara)
            
            let title = "New bid"
            let body = "\(Name) bid for $\(price)"
            PushNotificationSender.sendPushNotification(to:HomeDetailsVC.token, title: title, body: body)
            
            removeAnimation()
            self.hideIndicator()

        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
            let touch = touches.first
            if touch?.view != self.mainView{
                print("fine")
                removeAnimation()
            }
        }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if(textField == self.bidTF){
            let currentText = textField.text! + string
            return currentText.count <= maxLen
         }

         return true;
       }
   

}
