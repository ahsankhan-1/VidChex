//
//  PaymentVC.swift
//  VidChex
//
//  Created by M Hayat on 01/02/2023.
//

import UIKit
import PayPalCheckout
import PassKit

class PaymentVC: UIViewController {
    
    @IBOutlet weak var paypalBtn: UIButton!
    @IBOutlet weak var stripeBtn: UIButton!
    @IBOutlet weak var googlepayBtn: UIButton!
    @IBOutlet weak var paypalView: UIView!
    @IBOutlet weak var stripeView: UIView!
    @IBOutlet weak var googlepayView: UIView!
    @IBOutlet weak var buyBtn: UIButton!
    
    var uid = ""
    var buildingId = ""
    var selectedPayment = "Paypal"
    var number = ""
    var payprice = ""
    
    private var paymentRequest: PKPaymentRequest = {
            let request = PKPaymentRequest()
            request.merchantIdentifier = "merchant.ideaLogics.VidChex"
            request.supportedNetworks = [.visa, .masterCard,.amex,.discover]
            request.supportedCountries = ["US"]
            request.merchantCapabilities = .capability3DS
            request.countryCode = "UA"
            request.currencyCode = "UAH"
            request.paymentSummaryItems = [PKPaymentSummaryItem(label: "App test", amount: 10.99)]
            return request
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
        
        print(uid,"uid")
        self.title = "Payment Method"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        paypalBtn.isSelected = true
        paypalView.layer.cornerRadius = 5
        paypalView.layer.borderWidth = 0.5
        paypalView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        stripeView.layer.cornerRadius = 5
        stripeView.layer.borderWidth = 0.5
        stripeView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        googlepayView.layer.cornerRadius = 5
        googlepayView.layer.borderWidth = 0.5
        googlepayView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        buyBtn.layer.cornerRadius = 7
        
        if number == "1" {
           
            payprice = "250"
            buyBtn.setTitle("Pay Fee $" + payprice, for: .normal)
           
        } else {
           
            payprice = "150"
            buyBtn.setTitle("Pay Fee $" + payprice, for: .normal)
            
        }
    }
    
    
    @IBAction func paypalAction(_ sender: Any) {
        
        paypalBtn.isSelected = true
        stripeBtn.isSelected = false
        googlepayBtn.isSelected = false
        self.selectedPayment = "Paypal"
        
    }
    @IBAction func stripeAction(_ sender: Any) {
        
        paypalBtn.isSelected = false
        stripeBtn.isSelected = true
        googlepayBtn.isSelected = false
        self.selectedPayment = "Stripe"
        
    }
    
    @IBAction func googlepayAction(_ sender: Any) {
        
        paypalBtn.isSelected = false
        stripeBtn.isSelected = false
        googlepayBtn.isSelected = true
        self.selectedPayment = "Apple Pay"
        
    }
    
    @IBAction func buyAction(_ sender: Any) {
        
        if self.selectedPayment == "Paypal" {
            
        triggerPayPalCheckout(price: payprice.trimmingCharacters(in: .whitespacesAndNewlines))
            
        } else if self.selectedPayment == "Stripe" {
       
            let vc = storyboard?.instantiateViewController(withIdentifier: "StripePaymentVC") as! StripePaymentVC
            vc.recevireId = self.uid
            vc.price = self.payprice
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if  self.selectedPayment == "Apple Pay" {
            print("working....")
            if let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
                controller.delegate = self
                present(controller, animated: true, completion: nil)
            }
           
        }
    }
    
    func UserData(recieverId: String, completion: @escaping (String?) -> Void) {
        showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("userProfile").document(recieverId).getDocument { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                completion(nil)
                return
            }

            guard let snap = snapshot?.data() else {
                print("No Data Found in Dictionary")
                self.hideIndicator()
                completion(nil)
                return
            }

            let dic = snap as NSDictionary
            let token = dic["token"] as? String ?? ""
            self.hideIndicator()
            completion(token)
        }
    }
    
    func triggerPayPalCheckout(price:String) {
        Checkout.start(
            createOrder: { createOrderAction in
                let amount = PurchaseUnit.Amount(currencyCode: .usd, value: price)
                let purchaseUnit = PurchaseUnit(amount: amount)
                let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
                createOrderAction.create(order: order)
            }, onApprove: { approval in
                approval.actions.capture { (response, error) in
                    print("Order successfully captured: \(String(describing: response?.data))")
                    DispatchQueue.main.async {
                        self.errorWithTitleMsg(title: "Payment sent successfully", message: "")
                        
                        //MARK: Notification -
                        
                        let imgUrl = Helper.userDic["profileImg"] as? String ?? ""
                        let Name = (Helper.userDic["fname"] as? String ?? "" ) + " " + (Helper.userDic["lname"] as? String ?? "" )
                        let Ref = Helper.dbRef.collection("notifications")
                        let autoId = Ref.document().documentID
                        
                        if self.number == "1" {
                            let NotificationPara = ["content ":"\(Name) paid tax for building","createdOn":NSDate.now,"id":autoId,"productId":self.buildingId,"read":false,"receiverId":self.uid,"senderId":Helper.userId,"senderImg":imgUrl,"title":"\(Helper.buildingtitle) Update!","type":"3"] as [String : Any]
                            Helper.dbRef.collection("notifications").document(autoId).setData(NotificationPara)
                            let para = ["buyerPaidOn":NSDate.now,"status":4]
                            Helper.dbRef.collection("buildings").document(Helper.buildingid).updateData(para)
                            
                            self.UserData(recieverId: self.uid) { token in
                                guard token != nil else {return}
                                let title = "\(Helper.buildingtitle) Update!"
                                let body = "\(Name) paid tax for building"
                                PushNotificationSender.sendPushNotification(to:token!, title: title, body: body)
                            }
                            
                            
                        } else {
                            let NotificationPara = ["content ":"Now you can contact for seller","createdOn":NSDate.now,"id":autoId,"productId":self.buildingId,"read":false,"receiverId":self.uid,"senderId":Helper.userId,"senderImg":imgUrl,"title":"\(Helper.buildingtitle) Sold","type":"4"] as [String : Any]
                            Helper.dbRef.collection("notifications").document(autoId).setData(NotificationPara)
                            let para = ["sellerPaidOn":NSDate.now,"status":5]
                            Helper.dbRef.collection("buildings").document(Helper.buildingid).updateData(para)
                            self.UserData(recieverId: self.uid) { token in
                                guard token != nil else {return}
                                let title = "\(Helper.buildingtitle) Sold"
                                let body = "Now you can contact for seller"
                                PushNotificationSender.sendPushNotification(to:token!, title: title, body: body)
                            }
                        }
                        
                    }
                }
            }, onCancel: {
                DispatchQueue.main.async {
                    self.errorWithTitleMsg(title: "Payment Canceled", message: "")
                }
            }, onError: { error in
                DispatchQueue.main.async {
                    self.errorWithTitleMsg(title: "Error", message: "happing some error")
                }
            }
        )
    }
}

//MARK: Apple pay -

extension PaymentVC: PKPaymentAuthorizationViewControllerDelegate {
 
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
 
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
 
}
