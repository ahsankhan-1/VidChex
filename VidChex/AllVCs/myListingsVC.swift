//
//  myListingsVC.swift
//  VidChex
//
//  Created by M Hayat on 03/01/2023.
//

import UIKit
import Kingfisher
import AVKit
import FirebaseFirestore

class myListingsVC: UIViewController,UITableViewDelegate,UITableViewDataSource, AVPlayerViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var VideosCollectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
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
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var MainTableView: UITableView!

    var buildingid = ""
    var UserDic:[NSDictionary] = []
    var MylistingDic:NSDictionary = [:]
    var Userid = ""
    var highestBidPrice = ""
    var VideosArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserData()
        BuildingData()
        
        MainTableView.delegate = self
        MainTableView.dataSource = self
        VideosCollectionView.delegate = self
        VideosCollectionView.dataSource = self
        
        tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        deleteBtn.layer.cornerRadius = deleteBtn.frame.height/2
        View1.layer.cornerRadius = View1.layer.frame.height/2
        View2.layer.cornerRadius = View2.layer.frame.height/2
        View3.layer.cornerRadius = View3.layer.frame.height/2
        View4.layer.cornerRadius = View4.layer.frame.height/2
        BackGroundView(backGroundView: detailsView)
  
    }
   
    @IBAction func deleteBtnAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Delete building", message: "Do you really want to delete?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { action in
            self.showIndicator(caption: "Deleting documents...")
            let batch = Helper.dbRef.batch()
            
            Helper.dbRef.collection("buildings").document(self.buildingid).delete()
            
            batch.commit() { error in
                if let error = error {
                    print("Error deleting documents: \(error)")
                    self.hideIndicator()
                 print("Failed to delete documents.")
                } else {
                    print("Documents successfully deleted.")
                    self.hideIndicator()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
        
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


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDic.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = MainTableView.dequeueReusableCell(withIdentifier: "mylistingsTVCell", for: indexPath) as! mylistingsTVCell
        
        cell.nameLbl.text = self.UserDic[indexPath.row]["name"] as? String ?? ""
        cell.priceLbl.text = "$" + "" + String(self.UserDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
        let recevireid = self.UserDic[indexPath.row]["uid"] as? String ?? ""
        let buildingId = self.UserDic[indexPath.row]["buildingId"] as? String ?? ""
       
        cell.AcceptPressed = {
            
            let price = self.UserDic[indexPath.row]["price"] as? Int ?? 0
            let alertControllar = UIAlertController(title: "Bid value:$\(price).0", message: "Do you really want to accept the bid?", preferredStyle: .alert)
            let loginbutton = UIAlertAction(title: "OK", style: .default) { (action) in
                
                self.UserData(recieverId: recevireid) { token in
                    guard token != nil else {return}
                    let imgUrl = Helper.userDic["profileImg"] as? String ?? ""
                    let Name = (Helper.userDic["fname"] as? String ?? "" ) + " " + (Helper.userDic["lname"] as? String ?? "" )
                    let ref = Helper.dbRef.collection("buildings")
                    let autoid = ref.document().documentID
                    print(Helper.buildingid,"buildingid")
                    let parametter = ["buildingId":Helper.buildingid,"createdOn":NSDate.now,"id":autoid,"name":Name,"price":price,"uid":Helper.userId] as [String : Any]
                    let param = ["bid":parametter,"highestBid":price,"approvedOn":NSDate.now,"status":3] as [String : Any]
                    Helper.dbRef.collection("buildings").document(Helper.buildingid).updateData(param)
                    
                    let Ref = Helper.dbRef.collection("notifications")
                    let autoId = Ref.document().documentID
                    
                    let NotificationPara = ["content":"Your bid is accepted","createdOn":NSDate.now,"id":autoId,"productId":buildingId,"read":false,"receiverId":recevireid,"senderId":Helper.userId,"senderImg":imgUrl,"title":"Congratulations","type":"2"] as [String : Any]
                    Helper.dbRef.collection("notifications").document(autoId).setData(NotificationPara)
                    
                    let title = "Congratulations"
                    let body = "Your bid is accepted"
                    PushNotificationSender.sendPushNotification(to:token!, title: title, body: body)
                    
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            let canclebutton = UIAlertAction(title: "CANCEL", style: .cancel) { (action) in
                print ("Operation Has Been Cancelled By User")
            }
            alertControllar.addAction(loginbutton)
            alertControllar.addAction(canclebutton)
            self.present (alertControllar,animated: true,completion: nil)
            
        }
        
        cell.acceptBtn.layer.cornerRadius = 5
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return cell
        }
    
    func UserData() {
        self.UserDic.removeAll()
        showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("bids").whereField("buildingId", isEqualTo : self.buildingid).getDocuments { []querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let buildingdict = document.data() as NSDictionary
                    self.UserDic.append(buildingdict)
                    
                    self.UserDic = self.UserDic.sorted(by: {
                        (e1: NSDictionary?, e2: NSDictionary?) -> Bool in
                        return ((e2!.value(forKey: "price") as! Double)) < (e1!.value(forKey: "price") as! Double)
                    })
                    
                    self.hideIndicator()
                    self.MainTableView.reloadData()
                    
                }
            }
        }
        self.hideIndicator()
        self.MainTableView.reloadData()
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
            let heighestbid = String(dic["highestBid"] as? Int ?? 0)
            self.priceLbl.text = "$" + " " + heighestbid + "" + ".0"
            
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
            self.MylistingDic = dic
            self.VideosCollectionView.reloadData()
            
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

extension myListingsVC: UICollectionViewDelegateFlowLayout{
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
