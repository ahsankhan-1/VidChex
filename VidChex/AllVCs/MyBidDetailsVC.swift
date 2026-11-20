//
//  MyBidDetailsVC.swift
//  VidChex
//
//  Created by M Hayat on 31/01/2023.
//

import UIKit
import Kingfisher
import SDWebImage
import Alamofire
import AVKit
import FirebaseFirestore


class MyBidDetailsVC: UIViewController,AVPlayerViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
        
    @IBOutlet weak var VideosCollectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBOutlet weak var FirstView: UIView!
    @IBOutlet weak var highestBidLbl: UILabel!
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
    
    @IBOutlet weak var BackGroundView: UIView!
    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var UsernameLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    
    @IBOutlet weak var bidRequestLbl: UILabel!
    @IBOutlet weak var bidApprovedLbl: UILabel!
    @IBOutlet weak var paymentPendingLbl: UILabel!
    @IBOutlet weak var sellerLbl: UILabel!
    @IBOutlet weak var connectionLbl: UILabel!
    
    @IBOutlet weak var dateLbl1: UILabel!
    @IBOutlet weak var dateLbl2: UILabel!
    @IBOutlet weak var dateLbl3: UILabel!
    @IBOutlet weak var dateLbl4: UILabel!
    
    @IBOutlet weak var payBtn: UIButton!

    @IBOutlet weak var BtnImage1: UIImageView!
    @IBOutlet weak var BtnImage2: UIImageView!
    @IBOutlet weak var BtnImage3: UIImageView!
    @IBOutlet weak var BtnImage4: UIImageView!
    @IBOutlet weak var BtnImage5: UIImageView!
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    
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
    @IBOutlet weak var imageView16: UIImageView!
    @IBOutlet weak var imageView17: UIImageView!
    @IBOutlet weak var imageView18: UIImageView!
    @IBOutlet weak var imageView19: UIImageView!
    @IBOutlet weak var imageView20: UIImageView!
    
    @IBOutlet weak var chatBtn: UIButton!
    
    
    var UserDic:NSDictionary = [:]
    var HighestBidDic:NSDictionary = [:]
    var Userid = ""
    static var recevireid = ""
    var VideosArray = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserData()
        getAllBuildings()
        
        VideosCollectionView.delegate = self
        VideosCollectionView.dataSource = self
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        UserImageView.layer.cornerRadius = 7
        View1.layer.cornerRadius = View1.layer.frame.height/2
        View2.layer.cornerRadius = View2.layer.frame.height/2
        View3.layer.cornerRadius = View3.layer.frame.height/2
        View4.layer.cornerRadius = View4.layer.frame.height/2
        chatBtn.layer.cornerRadius = 7
        payBtn.layer.cornerRadius = 10
        
        
    
        VidChex.BackGroundView(backGroundView: FirstView)
        VidChex.BackGroundView(backGroundView: detailsView)
        
        let tapGesture1 = UITapGestureRecognizer()
        tapGesture1.addTarget(self, action: #selector(selectUserDetails))
        BackGroundView.addGestureRecognizer(tapGesture1)
        
        if Userid == Helper.userId {
            self.aboutLbl.text = "Added by you"
            BackGroundView.isUserInteractionEnabled = false
        } else {
            BackGroundView.isUserInteractionEnabled = true
            self.aboutLbl.text = "View Seller Profile"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        
    }
    
    @objc func selectUserDetails (){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AgentProfileVC") as! AgentProfileVC
        vc.userid = self.UserDic["uid"] as? String ?? ""
        vc.status = HighestBidDic["status"] as? Int ?? 0
        vc.CurrentBuildingid = HighestBidDic["id"] as? String ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    
    @IBAction func payBtnAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vc.uid = self.HighestBidDic["uid"] as? String ?? ""
        vc.buildingId = Helper.buildingid
        vc.number = "1"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func chatBtnAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.recevireId = self.Userid
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func UserData() {
          showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("userProfile").document(self.Userid).getDocument { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
          let dic = snap as NSDictionary
            let imgUrl = dic["profileImg"] as? String ?? ""
            self.UserImageView.sd_setImage(with: URL(string: imgUrl),placeholderImage: UIImage(named: "profile"))
            let fullName = (dic["fname"] as? String ?? "" ) + " " + (dic["lname"] as? String ?? "" )
            self.UsernameLbl.text = fullName
            BackGroundViewtableCell(backGroundView: self.BackGroundView)
            self.UserImageView.layer.shadowOpacity = 0.5
            self.UserImageView.layer.shadowRadius = 2.0
            self.UserImageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
            self.UserImageView.layer.shadowOffset = CGSize(width: 0.0, height: 1)
            self.UserImageView.layer.masksToBounds = false
            
            self.UserDic = dic
            self.hideIndicator()
        }
    }
    
    func getAllBuildings() {
        
        Helper.dbRef.collection("buildings").document(Helper.buildingid).getDocument { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
            
            let dic = snap as NSDictionary
            
            let heighestbid = dic["highestBid"] as? Int ?? 0
            self.highestBidLbl.text = "$" + " " + "\(heighestbid)" + ".0"
            Helper.highestBidPrice = heighestbid
            MyBidDetailsVC.recevireid = dic["addedBy"] as? String ?? ""
            self.priceLbl.text = "$" + " " + String(dic["price"] as? Int ?? 0) + ".0"
            self.locationLbl.text = dic["location"] as? String ?? ""
            self.Lbl1.text = String(dic["rooms"] as? Int ?? 0)
            self.Lbl2.text = String(dic["washrooms"] as? Int ?? 0)
            self.Lbl3.text = String(dic["kitchens"] as? Int ?? 0)
            self.Lbl4.text = String(dic["garages"] as? Int ?? 0)
            self.descLbl.text = dic["desc"] as? String ?? ""
            Helper.buildingtitle = dic["title"] as? String ?? ""
            
            let imageUrl = dic["videos"] as! [String]
            self.VideosArray = imageUrl
            self.HighestBidDic = dic
            self.VideosCollectionView.reloadData()
            let biddate = dic["bid"] as? [String:Any]
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "dd MMM, h:mm a"
            
            if dic["status"] as? Int ?? 0 == 1 {
                self.payBtn.isUserInteractionEnabled = false
                self.BtnImage1.tintColor = UIColor.AppGreen
                self.image1.tintColor = UIColor.AppGreen
                self.bidRequestLbl.textColor = .black
                self.chatBtn.backgroundColor = UIColor.BlurColor
                self.chatBtn.isUserInteractionEnabled = false
                self.dateLbl2.isHidden = true
                self.dateLbl3.isHidden = true
                self.dateLbl4.isHidden = true
                
                let dateFromDataBase = biddate?["createdOn"] as? Timestamp
                let date = dateFromDataBase!.dateValue()
                let finalstring = dateFormatter.string(from: date)
                
                self.dateLbl1.text = "Requested on" + " " + finalstring
                
            } else if dic["status"] as? Int ?? 0 == 3 {
                self.payBtn.isUserInteractionEnabled = true
                self.bidRequestLbl.textColor = .black
                self.bidApprovedLbl.textColor = .black
                self.paymentPendingLbl.textColor = .black
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
                self.dateLbl4.isHidden = true
                
                let dateFromDataBase = biddate?["createdOn"] as? Timestamp
                let date = dateFromDataBase!.dateValue()
                let finalstring = dateFormatter.string(from: date)
                let dateFromDataBase1 = dic["approvedOn"] as? Timestamp
                let date1 = dateFromDataBase1!.dateValue()
                let finalstring1 = dateFormatter.string(from: date1)
                
                self.dateLbl1.text = "Requested on" + " " + finalstring
                self.dateLbl2.text = "Approved on" + " " + finalstring1
                
            } else if dic["status"] as? Int ?? 0 == 4 {
                self.paymentPendingLbl.text = "Payment Paid"
                self.sellerLbl.text = "Waiting for Seller"
                self.bidRequestLbl.textColor = .black
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
                self.chatBtn.backgroundColor = UIColor.BlurColor
                self.chatBtn.isUserInteractionEnabled = false
                self.payBtn.isHidden = true
                self.dateLbl4.isHidden = true
                
                let dateFromDataBase = biddate?["createdOn"] as? Timestamp
                let date = dateFromDataBase!.dateValue()
                let finalstring = dateFormatter.string(from: date)
                
                let dateFromDataBase1 = dic["approvedOn"] as? Timestamp
                let date1 = dateFromDataBase1!.dateValue()
                let finalstring1 = dateFormatter.string(from: date1)
                let dateFromDataBase2 = dic["buyerPaidOn"] as? Timestamp
                let date2 = dateFromDataBase2?.dateValue()
                let finalstring2 = dateFormatter.string(from: date2!)
                self.dateLbl1.text = "Requested on" + " " + finalstring
                self.dateLbl2.text = "Approved on" + " " + finalstring1
                self.dateLbl3.text = "Paid on" + " " + finalstring2
                
            } else if dic["status"] as? Int ?? 0 == 5 {
                self.paymentPendingLbl.text = "Payment Paid"
                self.sellerLbl.text = "Seller Responded"
                self.bidRequestLbl.textColor = .black
                self.bidApprovedLbl.textColor = .black
                self.paymentPendingLbl.textColor = .black
                self.sellerLbl.textColor = .black
                self.connectionLbl.textColor = .black
                self.BtnImage1.tintColor = UIColor.AppGreen
                self.BtnImage2.tintColor = UIColor.AppGreen
                self.BtnImage3.tintColor = UIColor.AppGreen
                self.BtnImage4.tintColor = UIColor.AppGreen
                self.BtnImage5.tintColor = UIColor.AppGreen
                self.image1.tintColor = UIColor.AppGreen
                self.image2.tintColor = UIColor.AppGreen
                self.image3.tintColor = UIColor.AppGreen
                self.image4.tintColor = UIColor.AppGreen
                self.image5.tintColor = UIColor.AppGreen
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
                self.imageView16.tintColor = UIColor.AppGreen
                self.imageView17.tintColor = UIColor.AppGreen
                self.imageView18.tintColor = UIColor.AppGreen
                self.imageView19.tintColor = UIColor.AppGreen
                self.imageView20.tintColor = UIColor.AppGreen
                
                self.chatBtn.backgroundColor = UIColor.AppGreen
                self.chatBtn.isUserInteractionEnabled = true
                self.payBtn.isHidden = true
                
                let dateFromDataBase = biddate?["createdOn"] as? Timestamp
                let date = dateFromDataBase!.dateValue()
                let finalstring = dateFormatter.string(from: date)
                let dateFromDataBase1 = dic["approvedOn"] as? Timestamp
                let date1 = dateFromDataBase1!.dateValue()
                let finalstring1 = dateFormatter.string(from: date1)
                let dateFromDataBase2 = dic["buyerPaidOn"] as? Timestamp
                let date2 = dateFromDataBase2?.dateValue()
                let dateFromDataBase3 = dic["sellerPaidOn"] as? Timestamp
                let date3 = dateFromDataBase3?.dateValue()
                let finalstring2 = dateFormatter.string(from: date2!)
                let finalstring3 = dateFormatter.string(from: date3!)
                self.dateLbl1.text = "Requested on" + " " + finalstring
                self.dateLbl2.text = "Approved on" + " " + finalstring1
                self.dateLbl3.text = "Paid on" + " " + finalstring2
                self.dateLbl4.text = "Responded on" + " " + finalstring3
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VideosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = VideosCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeDetailCVCell", for: indexPath) as! HomeDetailCVCell
        
        cell.VideoView.layer.cornerRadius = 10
        
        let imageUrl = self.VideosArray[indexPath.row]
        if let videoURL = URL(string: imageUrl) {
            cell.VideoView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoURL, seconds: 5))
        }
        
        if VideosArray.count == 1 {
            pageController.isHidden = true
        }
        pageController.numberOfPages = VideosArray.count
        pageController.currentPage = indexPath.row
        pageController.currentPageIndicatorTintColor = UIColor.AppGreen
        pageController.pageIndicatorTintColor = .white
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageUrl = self.VideosArray[indexPath.row]
            guard let url = URL(string: imageUrl )else {return}
            let player = AVPlayer(url: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            playerController.allowsPictureInPicturePlayback = true
            playerController.delegate = self
            playerController.player?.play()
            self.present(playerController, animated: true, completion: nil)
        }
    
   }

extension MyBidDetailsVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == VideosCollectionView{
            let size = VideosCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }else{
            let size = VideosCollectionView.frame.size
            return CGSize(width: size.width/2, height: 260)
        }
      
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0.0
    }
}


