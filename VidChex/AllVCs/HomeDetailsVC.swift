//
//  HomeDetailsVC.swift
//  VidChex
//
//  Created by M Hayat on 20/10/2022.
//

import UIKit
import Kingfisher
import SDWebImage
import Alamofire
import AVKit

class HomeDetailsVC: UIViewController,AVPlayerViewControllerDelegate, UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var VideosCollectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBOutlet weak var FirstView: UIView!
    @IBOutlet weak var highestBidLbl: UILabel!
    @IBOutlet weak var bidUserNameLbl: UILabel!
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
    
    @IBOutlet weak var AddCartBtn: UIButton!
    
    var UserDic:NSDictionary = [:]
    var HighestBidbuildingDic:NSDictionary = [:]
    var HighestBidDic:[NSDictionary] = [ ]
    var Userid = ""
    static var recevireid = ""
    static var token = ""
    static var buildingtitle = ""
    var deleteArray = [String]()
    var addedBy = ""
    var VideosArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UserData()
        getAllBuildings()
        getdeletArray()
        
        print(Helper.buildingid,"buildingid")
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        VideosCollectionView.delegate = self
        VideosCollectionView.dataSource = self
        
        AddCartBtn.layer.cornerRadius = 7
        UserImageView.layer.cornerRadius = 7
        View1.layer.cornerRadius = View1.layer.frame.height/2
        View2.layer.cornerRadius = View2.layer.frame.height/2
        View3.layer.cornerRadius = View3.layer.frame.height/2
        View4.layer.cornerRadius = View4.layer.frame.height/2
        
        VidChex.BackGroundView(backGroundView: FirstView)
        VidChex.BackGroundView(backGroundView: detailsView)
        
//        let tapGesture = UITapGestureRecognizer()
//        tapGesture.addTarget(self, action: #selector(changeProfileImg))
//        detailsImageView.isUserInteractionEnabled = true
//        detailsImageView.addGestureRecognizer(tapGesture)
        
        let tapGesture1 = UITapGestureRecognizer()
        tapGesture1.addTarget(self, action: #selector(selectUserDetails))
        BackGroundView.addGestureRecognizer(tapGesture1)
        
        if Userid == Helper.userId {
            AddCartBtn.isHidden = true
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
        vc.status = HighestBidbuildingDic["status"] as? Int ?? 0
        vc.CurrentBuildingid = HighestBidbuildingDic["id"] as? String ?? ""
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func changeProfileImg(){
        
        let imageUrl = self.HighestBidbuildingDic["videos"] as? [String]
        let VideoUrl = imageUrl![0]
        guard let url = URL(string: VideoUrl )else {return}
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.allowsPictureInPicturePlayback = true
        playerController.delegate = self
        playerController.player?.play()
        self.present(playerController, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteBidAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete these documents?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.showIndicator(caption: "Deleting documents...")
            let batch = Helper.dbRef.batch()
            
            Helper.dbRef.collection("buildings").document(Helper.buildingid).delete()
            
            batch.commit() { error in
                if let error = error {
                    print("Error deleting documents: \(error)")
                    self.hideIndicator()
                    
                    //       self.showAlert(title: "Error", message: "Failed to delete documents.")
                } else {
                    print("Documents successfully deleted.")
                    self.hideIndicator()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func getdeletArray() {
        showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("bids").whereField("buildingId", isEqualTo:Helper.buildingid).getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let buildingdict = document.data() as NSDictionary
                    print(buildingdict,"buildingdict")
                    let uid = buildingdict["uid"] as? String ?? ""
                    let id = buildingdict["id"] as? String ?? ""
                    if uid == Helper.userId {
                    self.deleteArray.append(id)
                    print(self.deleteArray,"deleteArray")
                        
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    
    
    @IBAction func addCartAction(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddBidVC") as! AddBidVC
        self.addChild(vc)
        vc.view.frame = self.view.frame
        vc.postkey = Helper.buildingid
        vc.highestBid = String(self.HighestBidbuildingDic["highestBid"] as? Int ?? 0)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
    }
    
    @IBAction func buyAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PurchaseVC") as! PurchaseVC
        vc.bed = String(self.HighestBidbuildingDic["rooms"] as? Int ?? 0)
        vc.bathroom = String(self.HighestBidbuildingDic["washrooms"] as? Int ?? 0)
        vc.kitchen = String(self.HighestBidbuildingDic["kitchens"] as? Int ?? 0)
        vc.garage = String(self.HighestBidbuildingDic["garages"] as? Int ?? 0)
        vc.price = String(self.HighestBidbuildingDic["price"] as? Int ?? 0)
        vc.desc = self.HighestBidbuildingDic["desc"] as? String ?? ""
        vc.location = self.HighestBidbuildingDic["location"] as? String ?? ""
        vc.uid = self.HighestBidbuildingDic["uid"] as? String ?? ""
        vc.buildingId = Helper.buildingid
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func UserData() {
        showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("userProfile").document(self.Userid).addSnapshotListener { snapshot, error in
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
            HomeDetailsVC.token = dic["token"] as? String ?? ""
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
        
        showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("buildings").document(Helper.buildingid).getDocument { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
            let dic = snap as NSDictionary
            
            HomeDetailsVC.recevireid = dic["addedBy"] as? String ?? ""
            self.priceLbl.text = "$" + " " + String(dic["price"] as? Int ?? 0) + "" + ".0"
            self.locationLbl.text = dic["location"] as? String ?? ""
            self.Lbl1.text = String(dic["rooms"] as? Int ?? 0)
            self.Lbl2.text = String(dic["washrooms"] as? Int ?? 0)
            self.Lbl3.text = String(dic["kitchens"] as? Int ?? 0)
            self.Lbl4.text = String(dic["garages"] as? Int ?? 0)
            self.descLbl.text = dic["desc"] as? String ?? ""
            HomeDetailsVC.buildingtitle = dic["title"] as? String ?? ""
            
            let imageUrl = dic["videos"] as! [String]
            self.VideosArray = imageUrl
            let VideoUrl = imageUrl[0]
            let video = URL(string: VideoUrl)
            self.HighestBidbuildingDic = dic
            self.getHighestBiddata()
            self.hideIndicator()
            
            self.VideosCollectionView.reloadData()
            
        }
    }
    
    func getHighestBiddata() {
        
//        showIndicator(caption: "Please wait...")
        self.HighestBidDic.removeAll()
        Helper.dbRef.collection("bids").whereField("buildingId", isEqualTo: Helper.buildingid).addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let buildingdict = document.data() as NSDictionary
                    self.HighestBidDic.append(buildingdict)
                }
                let highestprice = self.HighestBidDic.compactMap { $0["price"] as? Int }.max() ?? 0
                print("Highest price: \(highestprice)")
                
                Helper.dbRef.collection("bids").whereField("price", isEqualTo:highestprice).addSnapshotListener { querySnapshot, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let buildingdict = document.data() as NSDictionary
                            self.HighestBidDic.append(buildingdict)
                            
                            
                            let heighestbid = buildingdict["price"] as? Int ?? 0
                            self.highestBidLbl.text = "$" + " " + "\(heighestbid)" + "" + ".0"
                            Helper.highestBidPrice = heighestbid
                            let biderName = buildingdict["name"] as? String ?? ""
                            Helper.highestBiderName = biderName
                            let fullName = (Helper.userDic["fname"] as? String ?? "" ) + " " + (Helper.userDic["lname"] as? String ?? "" )
                            if fullName == biderName {
                                self.bidUserNameLbl.text = "by you"
                            }else {
                                self.bidUserNameLbl.text = biderName
                            }
                            
                            print(Helper.highestBidPrice,"highestBidPrice")
                            print(Helper.highestBiderName,"highestBiderName")
                            
                            self.hideIndicator()
                            
                        }
                        
                    }
                }
                
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

extension HomeDetailsVC: UICollectionViewDelegateFlowLayout {
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

