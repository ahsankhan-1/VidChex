//
//  MyListingsDetailsVC.swift
//  VidChex
//
//  Created by M Hayat on 02/02/2023.
//

import UIKit
import FirebaseFirestore

class MyListingsDetailsVC: UIViewController {
    
    
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
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bidUserLbl: UILabel!
    @IBOutlet weak var bidPriceLbl: UILabel!
    
    @IBOutlet weak var bidApprovedLbl: UILabel!
    @IBOutlet weak var paymentPendingLbl: UILabel!
    @IBOutlet weak var sellerLbl: UILabel!
    @IBOutlet weak var connectionLbl: UILabel!
    
    @IBOutlet weak var dateLbl1: UILabel!
    @IBOutlet weak var dateLbl2: UILabel!
    @IBOutlet weak var dateLbl3: UILabel!
   
    @IBOutlet weak var payBtn: UIButton!
    
    @IBOutlet weak var BtnImage1: UIImageView!
    @IBOutlet weak var BtnImage2: UIImageView!
    @IBOutlet weak var BtnImage3: UIImageView!
    @IBOutlet weak var BtnImage4: UIImageView!
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var imageView6: UIImageView!
    @IBOutlet weak var imageView7: UIImageView!
    @IBOutlet weak var imageView8: UIImageView!
    @IBOutlet weak var imageView9: UIImageView!
    @IBOutlet weak var imageView10: UIImageView!
    @IBOutlet weak var imageView11: UIImageView!
    @IBOutlet weak var imageView12: UIImageView!
    @IBOutlet weak var imageView13: UIImageView!
    @IBOutlet weak var imageView14: UIImageView!
    @IBOutlet weak var imageView15: UIImageView!
    
    @IBOutlet weak var chatBtn: UIButton!
    
    var buildingid = ""
    var recevireid = ""
    var UserDic:[NSDictionary] = []
    var MylistingDic:NSDictionary = [:]
    var Userid = ""
    var highestBidPrice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Listing Details"
        
        BuildingData()
        
        tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        payBtn.layer.cornerRadius = 7
        chatBtn.layer.cornerRadius = 7
        View1.layer.cornerRadius = View1.layer.frame.height/2
        View2.layer.cornerRadius = View2.layer.frame.height/2
        View3.layer.cornerRadius = View3.layer.frame.height/2
        View4.layer.cornerRadius = View4.layer.frame.height/2
        BackGroundView(backGroundView: detailsView)
        BackGroundView(backGroundView: mainView)

    }
    
    @IBAction func payBtnAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vc.uid = self.MylistingDic["addedBy"] as? String ?? ""
        vc.buildingId = Helper.buildingid
        vc.number = "2"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func chatBtnAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.recevireId = self.Userid
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func BuildingData() {
        
        Helper.dbRef.collection("buildings").document(self.buildingid).getDocument { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
            let dic = snap as NSDictionary
            
            let biddic = dic["bid"] as? [String:Any]
            self.bidUserLbl.text = biddic?["name"] as? String ?? ""
                let bidprice = String(biddic?["price"] as? Int ?? 0)
            self.bidPriceLbl.text = "$" + "" + bidprice + "" + ".0"
            let heighestbid = String(dic["highestBid"] as? Int ?? 0)
            self.priceLbl.text = "$" + " " + heighestbid + "" + ".0"
            self.recevireid = dic["addedBy"] as? String ?? ""
            self.locationLbl.text = dic["location"] as? String ?? ""
            self.Lbl1.text = String(dic["rooms"] as? Int ?? 0)
            self.Lbl2.text = String(dic["washrooms"] as? Int ?? 0)
            self.Lbl3.text = String(dic["kitchens"] as? Int ?? 0)
            self.Lbl4.text = String(dic["garages"] as? Int ?? 0)
            self.descLbl.text = dic["desc"] as? String ?? ""
            Helper.buildingtitle = dic["title"] as? String ?? ""
            self.MylistingDic = dic
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "dd MMM, h:mm a"
            
            if dic["status"] as? Int ?? 0 == 3 {
                self.payBtn.isUserInteractionEnabled = false
                self.BtnImage1.tintColor = UIColor.AppGreen
                self.BtnImage2.tintColor = UIColor.AppGreen
                self.image1.tintColor = UIColor.AppGreen
                self.image2.tintColor = UIColor.AppGreen
                self.chatBtn.backgroundColor = UIColor.BlurColor
                self.chatBtn.isUserInteractionEnabled = false
                self.dateLbl2.isHidden = true
                self.dateLbl3.isHidden = true
                
                let dateFromDataBase = biddic?["createdOn"] as? Timestamp
                let date = dateFromDataBase!.dateValue()
                let finalstring = dateFormatter.string(from: date)
                
                self.dateLbl1.text = "Requested on" + " " + finalstring
                
            } else if dic["status"] as? Int ?? 0 == 4 {
                
                self.payBtn.isUserInteractionEnabled = true
                self.bidApprovedLbl.textColor = .black
                self.paymentPendingLbl.text = "Buyer Responded"
                self.paymentPendingLbl.textColor = .black
                self.sellerLbl.textColor = .black
                self.payBtn.backgroundColor = UIColor.AppGreen
                self.BtnImage1.tintColor = UIColor.AppGreen
                self.BtnImage2.tintColor = UIColor.AppGreen
                self.BtnImage3.tintColor = UIColor.AppGreen
                self.image1.tintColor = UIColor.AppGreen
                self.image2.tintColor = UIColor.AppGreen
                self.image3.tintColor = UIColor.AppGreen
                self.imageView1.tintColor = UIColor.AppGreen
                self.imageView2.tintColor = UIColor.AppGreen
                self.imageView3.tintColor = UIColor.AppGreen
                self.imageView4.tintColor = UIColor.AppGreen
                self.imageView5.tintColor = UIColor.AppGreen
                self.imageView6.tintColor = UIColor.AppGreen
                self.imageView7.tintColor = UIColor.AppGreen
                self.imageView8.tintColor = UIColor.AppGreen
                self.imageView9.tintColor = UIColor.AppGreen
                self.imageView10.tintColor = UIColor.AppGreen
                self.chatBtn.backgroundColor = UIColor.BlurColor
                self.chatBtn.isUserInteractionEnabled = false
                self.dateLbl3.isHidden = true
                
                let dateFromDataBase = biddic?["createdOn"] as? Timestamp
                let date = dateFromDataBase?.dateValue()
                let finalstring = dateFormatter.string(from: date ?? Date())
                let dateFromDataBase1 = dic["buyerPaidOn"] as? Timestamp
                let date1 = dateFromDataBase1?.dateValue()
                let finalstring1 = dateFormatter.string(from: date1 ?? Date())
                
                self.dateLbl1.text = "Requested on" + " " + finalstring
                self.dateLbl2.text = "Approved on" + " " + finalstring1
                                
            } else if dic["status"] as? Int ?? 0 == 5 {
                
                self.paymentPendingLbl.text = "Payment Paid"
                self.sellerLbl.text = "Buyer Responded"
                self.bidApprovedLbl.textColor = .black
                self.paymentPendingLbl.textColor = .black
                self.sellerLbl.textColor = .black
                self.connectionLbl.textColor = .black
                self.BtnImage1.tintColor = UIColor.AppGreen
                self.BtnImage2.tintColor = UIColor.AppGreen
                self.BtnImage3.tintColor = UIColor.AppGreen
                self.BtnImage4.tintColor = UIColor.AppGreen
                self.image1.tintColor = UIColor.AppGreen
                self.image2.tintColor = UIColor.AppGreen
                self.image3.tintColor = UIColor.AppGreen
                self.image4.tintColor = UIColor.AppGreen
                self.imageView1.tintColor = UIColor.AppGreen
                self.imageView2.tintColor = UIColor.AppGreen
                self.imageView3.tintColor = UIColor.AppGreen
                self.imageView4.tintColor = UIColor.AppGreen
                self.imageView5.tintColor = UIColor.AppGreen
                self.imageView6.tintColor = UIColor.AppGreen
                self.imageView7.tintColor = UIColor.AppGreen
                self.imageView8.tintColor = UIColor.AppGreen
                self.imageView9.tintColor = UIColor.AppGreen
                self.imageView10.tintColor = UIColor.AppGreen
                self.imageView11.tintColor = UIColor.AppGreen
                self.imageView12.tintColor = UIColor.AppGreen
                self.imageView13.tintColor = UIColor.AppGreen
                self.imageView14.tintColor = UIColor.AppGreen
                self.imageView15.tintColor = UIColor.AppGreen
                self.chatBtn.backgroundColor = UIColor.AppGreen
                self.chatBtn.isUserInteractionEnabled = true
                self.payBtn.isHidden = true
               
                let dateFromDataBase = biddic?["createdOn"] as? Timestamp
                let date = dateFromDataBase!.dateValue()
                let finalstring = dateFormatter.string(from: date)
                let dateFromDataBase1 = dic["buyerPaidOn"] as? Timestamp
                let date1 = dateFromDataBase1!.dateValue()
                let finalstring1 = dateFormatter.string(from: date1)
                let dateFromDataBase2 = dic["sellerPaidOn"] as? Timestamp
                let date2 = dateFromDataBase2?.dateValue()
                let finalstring2 = dateFormatter.string(from: date2!)
                self.dateLbl1.text = "Requested on" + " " + finalstring
                self.dateLbl2.text = "Responded on" + " " + finalstring1
                self.dateLbl3.text = "Paid on" + " " + finalstring2
                                
            }
        }
    }
}
