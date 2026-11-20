//
//  AgentProfileVC.swift
//  VidChex
//
//  Created by M Hayat on 03/01/2023.
//

import UIKit
import Kingfisher

class AgentProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
   
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var emailImageView: UIImageView!
    
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var HomecountVC: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var chatBtn: UIButton!
    
    @IBOutlet weak var OtherListingsTableView: UITableView!
    
    var UserBuildingsDic:[NSDictionary] = []
    var userid = ""
    var CurrentBuildingid = ""
    var status = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Seller Profile"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       
        
        UserData()
        getAllBuildings()
        
        OtherListingsTableView.delegate = self
        OtherListingsTableView.dataSource = self
        
        firstView.isHidden = true
        emailImageView.isHidden = true
        emailLbl.isHidden = true
        
        BackGroundView(backGroundView: backGroundView)
        profileImageView.layer.cornerRadius = 7
        firstView.layer.cornerRadius = firstView.layer.frame.height/2
        secondView.layer.cornerRadius = secondView.layer.frame.height/2
        chatBtn.layer.cornerRadius = 7
        
        if status == 5 {
            self.chatBtn.isUserInteractionEnabled = true
            self.chatBtn.backgroundColor = UIColor.AppGreen
        } else {
            self.chatBtn.isUserInteractionEnabled = false
            self.chatBtn.backgroundColor = UIColor.BlurColor
        }
    }
    
    @IBAction func chatBtnAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.recevireId = self.userid
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.UserBuildingsDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = OtherListingsTableView.dequeueReusableCell(withIdentifier: "OtherListinngsTVCell", for: indexPath) as! OtherListinngsTVCell
        
        cell.nameLbl.text = self.UserBuildingsDic[indexPath.row]["title"] as? String ?? ""
        cell.aboutLbl.text = self.UserBuildingsDic[indexPath.row]["location"] as? String ?? ""
        cell.priceLbl.text = "$" + "" + String(self.UserBuildingsDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
        let imageUrl = self.UserBuildingsDic[indexPath.row]["videos"] as? [String]
        let video = URL(string: imageUrl![0])
        cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
        
        BackGroundViewtableCell(backGroundView: cell.BackGroundView)
        cell.UserImageView.layer.cornerRadius = 7
        cell.UserImageView.layer.shadowOpacity = 0.5
        cell.UserImageView.layer.shadowRadius = 2.0
        cell.UserImageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        cell.UserImageView.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        cell.UserImageView.layer.masksToBounds = false
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeDetailsVC") as! HomeDetailsVC
        vc.Userid = self.UserBuildingsDic[indexPath.row]["addedBy"] as? String ?? ""
        Helper.highestBidPrice = self.UserBuildingsDic[indexPath.row]["highestBid"] as? Int ?? 0
        Helper.buildingid = self.UserBuildingsDic[indexPath.row]["id"] as? String ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func UserData() {
        //   showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("userProfile").document(self.userid).addSnapshotListener { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
            let dic = snap as NSDictionary
//            let imageurl = dic ["profileImg"] as? String ?? ""
            let imgUrl = dic["profileImg"] as? String ?? ""
            self.profileImageView.sd_setImage(with: URL(string: imgUrl),placeholderImage: UIImage(named: "profile"))
            let fullName = (dic["fname"] as? String ?? "" ) + " " + (dic["lname"] as? String ?? "" )
            self.nameLbl.text = fullName
            self.emailLbl.text = dic["email"] as? String ?? ""
            self.locationLbl.text = dic["address"] as? String ?? ""
            self.descLbl.text = dic["about"] as? String ?? ""
            
        }
    }
    
    func getAllBuildings() {
        
        Helper.dbRef.collection("buildings").whereField("addedBy", isEqualTo : self.userid).getDocuments { []querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let dict = document.data() as NSDictionary
                    
                    if dict["status"] as? Int ?? 0 == 1 && dict["id"] as? String ?? "" != self.CurrentBuildingid  {
                        self.UserBuildingsDic.append(dict)
                        removeNoData()
                        self.OtherListingsTableView.reloadData()
                    }
                }
                self.HomecountVC.text = String(self.UserBuildingsDic.count)
            }
        }
    }
}
