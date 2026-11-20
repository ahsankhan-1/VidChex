//
//  PurchaseVC.swift
//  VidChex
//
//  Created by M Hayat on 02/01/2023.
//

import UIKit
import PayPalCheckout

class PurchaseVC: UIViewController {
    
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!
    @IBOutlet weak var View4: UIView!
    @IBOutlet weak var Lbl1: UILabel!
    @IBOutlet weak var Lbl2: UILabel!
    @IBOutlet weak var Lbl3: UILabel!
    @IBOutlet weak var Lbl4: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var BuildingPriceLbl: UILabel!
    @IBOutlet weak var TransactionChargesLbl: UILabel!
    @IBOutlet weak var adminTaxLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var paypalBtn: UIButton!
    @IBOutlet weak var stripeBtn: UIButton!
    @IBOutlet weak var googlepayBtn: UIButton!
    @IBOutlet weak var paypalView: UIView!
    @IBOutlet weak var stripeView: UIView!
    @IBOutlet weak var googlepayView: UIView!
    @IBOutlet weak var buyBtn: UIButton!
    
    var uid = ""
    var buildingId = ""
    static var buildingtitle = ""
    var price = ""
    var bed = ""
    var bathroom = ""
    var kitchen = ""
    var garage = ""
    var desc = ""
    var location = ""
    var Bprice = 0.0
    var TRCharges = 120.0
    var AdminTax = 0.0
    var total = 0.0
    var selectedPayment = "Paypal"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Purchase Building"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        View1.layer.cornerRadius = View1.layer.frame.height/2
        View2.layer.cornerRadius = View2.layer.frame.height/2
        View3.layer.cornerRadius = View3.layer.frame.height/2
        View4.layer.cornerRadius = View4.layer.frame.height/2
        BackGroundView(backGroundView: detailsView)
        
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
        
        priceLbl.text = "$" + " " + price + "" + ".0"
        locationLbl.text = location
        Lbl1.text = bed
        Lbl2.text = bathroom
        Lbl3.text = kitchen
        Lbl4.text = garage
        descLbl.text = desc
        
        BuildingPriceLbl.text = "$" + " " + price + "" + ".0"
        TransactionChargesLbl.text = "$" + " " + String(TRCharges)
        AdminTax = Double(price)! / 10
        adminTaxLbl.text = "$" + " " +  String(AdminTax)
        total = Double(price)! + AdminTax + TRCharges
        totalLbl.text = "$" + " " +  String(total)
        
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
            
        guard self.totalLbl.text != "" else{return}
        triggerPayPalCheckout(price: "10000".trimmingCharacters(in: .whitespacesAndNewlines))
            
        } else if self.selectedPayment == "Stripe" {
       
            let vc = storyboard?.instantiateViewController(withIdentifier: "StripePaymentVC") as! StripePaymentVC
            vc.totalprice = self.total
            vc.recevireId = self.uid
            vc.buildingId = self.buildingId
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if  self.selectedPayment == "Apple Pay" {
            
            
            
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
                            
                            let NotificationPara = ["content ":"\(Name) purchased your building","createdOn":NSDate.now,"id":autoId,"productId":self.buildingId,"read":false,"receiverId":self.uid,"senderId":Helper.userId,"senderImg":imgUrl,"title":"\(HomeDetailsVC.buildingtitle) Sold","type":"bid"] as [String : Any]
                            Helper.dbRef.collection("notifications").document(autoId).setData(NotificationPara)
                            
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
