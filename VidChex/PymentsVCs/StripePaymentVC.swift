//
//  StripePaymentVC.swift
//  VidChex
//
//  Created by M Hayat on 18/01/2023.
//

import UIKit
import Stripe
import CreditCardForm

class StripePaymentVC: UIViewController, STPPaymentCardTextFieldDelegate {
    
    @IBOutlet weak var creditCardView: CreditCardFormView!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var priceLbl: UILabel!
    
    var paymentIntentClientSecret:String?
    let paymentTextField = STPPaymentCardTextField()
    private var cardHolderNameTextField: TextField!
    private var cardParams: STPPaymentMethodCardParams!

    var BackendUrl = "https://apis.appistaan.com/vidchex/stripeSendPayment/paymoney.php"
    
    var recevireId = ""
    var buildingId = ""
    var fullName = ""
    var CategoryId = ""
    
    var postLink = ""
    var discription = ""
    var imageurl = ""
    var day = ""
    var price = ""
    var count = ""
    
    var intPrice = 0.0
    var totalprice = 0.0
    var taxPrice = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pay Money"
        
        print(Helper.buildingid,"buildingid",self.recevireId, "self.recevireId")
        
        payBtn.layer.cornerRadius = 7
        priceLbl.text = "$" + " " + price
        payBtn.setTitle("Pay Fee $" + price, for: .normal)
        
        creditCardView.cardHolderString = ""
        creditCardView.cardGradientColors[Brands.Amex.rawValue] = [UIColor.red, UIColor.black]
        creditCardView.cardNumberFont = UIFont(name: "HelveticaNeue", size: 20)!
        creditCardView.cardPlaceholdersFont = UIFont(name: "HelveticaNeue", size: 10)!
        creditCardView.cardTextFont = UIFont(name: "HelveticaNeue", size: 12)!
        paymentTextField.postalCodeEntryEnabled = false
        paymentTextField.delegate = self
        createTextField()
        cardParams = STPPaymentMethodCardParams()
        cardParams.number = ""
//        cardParams.expMonth =
//        cardParams.expYear =
        cardParams.cvc = ""
        self.paymentTextField.cardParams = cardParams
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        
        startCheckout()
    }
    
    @IBAction func payBtnAction(_ sender: Any) {
       
        pay()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // load saved card params
        creditCardView.paymentCardTextFieldDidChange(cardNumber: cardParams.number, expirationYear: cardParams!.expYear as? UInt, expirationMonth: cardParams!.expMonth as? UInt, cvc: cardParams.cvc)
        
    }
    
    func createTextField() {
        cardHolderNameTextField = TextField(frame: CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44))
        cardHolderNameTextField.placeholder = "CARD HOLDER"
        cardHolderNameTextField.delegate = self
        cardHolderNameTextField.translatesAutoresizingMaskIntoConstraints = false
        cardHolderNameTextField.setBottomBorder()
        cardHolderNameTextField.addTarget(self, action: #selector(StripePaymentVC.textFieldDidChange(_:)), for: .editingChanged)
        view.addSubview(cardHolderNameTextField)
         cardHolderNameTextField.isHidden = true
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.delegate = self
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        view.addSubview(paymentTextField)
        NSLayoutConstraint.activate([
            cardHolderNameTextField.topAnchor.constraint(equalTo: priceLbl.bottomAnchor, constant: 20),
            cardHolderNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardHolderNameTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-25),
            cardHolderNameTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: priceLbl.bottomAnchor, constant: 20),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
//        func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
//            creditCardView.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
//        }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingExpiration(expirationYear: UInt(Int(textField.expirationYear)))
        
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingCVC()
        
    }
    
    func startCheckout() {
            // let url = URL(string: BackendUrl + "\(String(price))")!
            let url = URL(string: BackendUrl)!
            let json: [String: Any] = [
                "currency": "usd",
                "money" : price,
                
                "items": [
                    "id": Helper.userId
                ]
            ]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                      let clientSecret = json["clientSecret"] as? String
                else {
                    let message = error?.localizedDescription ?? "Failed to decode response from server."
                    self?.errorWithTitleMsg(title: "Oops Error", message: message)
                    
                    return
                }
                print("Created PaymentIntent")
                self?.paymentIntentClientSecret = clientSecret
                
                StripeAPI.defaultPublishableKey = "pk_test_51MPiOkCqpDLEyZ9GsabFfFQyC3w3bbyTAKFJnGpSc4bve8AQaiIA7CeYjkv2v2zs0TDyHLCZmliKVAsKmbOab3OJ000xR8RcYA"
                
            })
            task.resume()
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
    
    
    func pay() {
        
        showIndicator(caption: "Please wait")
        guard let paymentIntentClientSecret = paymentIntentClientSecret else {
            return;
        }
       
        let cardParams = paymentTextField.cardParams
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        // Submit the payment
        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(paymentIntentParams, with: self) { [self] (status, paymentIntent, error) in
            switch (status) {
            case .failed:
                self.view.dismissProgress()
                self.hideIndicator()
                let alertTitle = "Payment failed"
                self.displayAlert(title: alertTitle, message: error?.localizedDescription ?? "")
                break
            case .canceled:
                self.view.dismissProgress()
                let alertTitle = "Payment canceled"
                self.hideIndicator()
                self.displayAlert(title: alertTitle, message: error?.localizedDescription ?? "")
                break
            case .succeeded:
                
    //MARK: Notification -
                
                let imgUrl = Helper.userDic["profileImg"] as? String ?? ""
                let Name = (Helper.userDic["fname"] as? String ?? "" ) + " " + (Helper.userDic["lname"] as? String ?? "" )
                let Ref = Helper.dbRef.collection("notifications")
                let autoId = Ref.document().documentID
                
                if self.price == "250" {
                    let NotificationPara = ["content ":"\(Name) paid tax for building","createdOn":NSDate.now,"id":autoId,"productId":self.buildingId,"read":false,"receiverId":self.recevireId,"senderId":Helper.userId,"senderImg":imgUrl,"title":"\(Helper.buildingtitle) Update!","type":"3"] as [String : Any]
                    Helper.dbRef.collection("notifications").document(autoId).setData(NotificationPara)
                    let para = ["buyerPaidOn":NSDate.now,"status":4]
                    Helper.dbRef.collection("buildings").document(Helper.buildingid).updateData(para)
                   
                    
                    self.UserData(recieverId: self.recevireId) { token in
                        guard token != nil else {return}
                        let title = "\(Helper.buildingtitle) Update!"
                        let body = "\(Name) paid tax for building"
                        PushNotificationSender.sendPushNotification(to:token!, title: title, body: body)
                    }
                } else {
                    let NotificationPara = ["content ":"Now you can contact for seller","createdOn":NSDate.now,"id":autoId,"productId":self.buildingId,"read":false,"receiverId":self.recevireId,"senderId":Helper.userId,"senderImg":imgUrl,"title":"\(Helper.buildingtitle) Sold","type":"4"] as [String : Any]
                    Helper.dbRef.collection("notifications").document(autoId).setData(NotificationPara)
                    let para = ["sellerPaidOn":NSDate.now,"status":5]
                    Helper.dbRef.collection("buildings").document(Helper.buildingid).updateData(para)
                    
                    self.UserData(recieverId: self.recevireId) { token in
                        guard token != nil else {return}
                        let title = "\(Helper.buildingtitle) Sold"
                        let body = "Now you can contact for seller"
                        PushNotificationSender.sendPushNotification(to:token!, title: title, body: body)
                    }
                    
                }
                
                self.hideIndicator()
                let vc = storyboard?.instantiateViewController(withIdentifier: "SuccessfullPaymentVC") as? SuccessfullPaymentVC
                vc?.modalPresentationStyle = .fullScreen
                present(vc!, animated: true, completion: nil)
                break
            @unknown default:
                fatalError()
                break
            }
        }
    }
    
    func displayAlert(title: String, message: String, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if restartDemo {
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension StripePaymentVC: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        creditCardView.cardHolderString = textField.text!
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cardHolderNameTextField {
            textField.resignFirstResponder()
            paymentTextField.becomeFirstResponder()
        } else if textField == paymentTextField  {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = UITextField.BorderStyle.none
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension StripePaymentVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

