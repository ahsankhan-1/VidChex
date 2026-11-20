//
//  AcceptedBidVC.swift
//  VidChex
//
//  Created by M Hayat on 03/01/2023.
//

import UIKit
import Kingfisher
import AVKit


class AcceptedBidVC: UIViewController,UITableViewDelegate,UITableViewDataSource, AVPlayerViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
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
    @IBOutlet weak var MainTableView: UITableView!
    
    
    var buildingid = ""
    var UserDic:[NSDictionary] = []
    var AcceptedDic:NSDictionary = [:]
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
        
        View1.layer.cornerRadius = View1.layer.frame.height/2
        View2.layer.cornerRadius = View2.layer.frame.height/2
        View3.layer.cornerRadius = View3.layer.frame.height/2
        View4.layer.cornerRadius = View4.layer.frame.height/2
        BackGroundView(backGroundView: detailsView)
        
//        let tapGesture = UITapGestureRecognizer()
//        tapGesture.addTarget(self, action: #selector(changeProfileImg))
//        detailsImageView.isUserInteractionEnabled = true
//        detailsImageView.addGestureRecognizer(tapGesture)
    
        
    }
    @objc func changeProfileImg(){
        
        let imageUrl = self.AcceptedDic["videos"] as? [String]
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
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  UserDic.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = MainTableView.dequeueReusableCell(withIdentifier: "AcceptedBidTVCell", for: indexPath) as! AcceptedBidTVCell
        
        cell.nameLbl.text = self.UserDic[indexPath.row]["name"] as? String ?? ""
        cell.priceLbl.text = "$" + "" + String(self.UserDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
        
        BackGroundViewtableCell(backGroundView: cell.backGroundView)
       
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return cell
        }
    
    func UserData() {
        
        self.UserDic.removeAll()
        showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("buildings").document(self.buildingid).addSnapshotListener { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
            
            let dic = snap
          if let idData = dic["bid"] as? [String: Any] {
              self.UserDic.append(idData as NSDictionary)
              self.hideIndicator()
              self.MainTableView.reloadData()
            }
           
            
        }
        self.hideIndicator()
        self.MainTableView.reloadData()
    }

    func BuildingData() {
        
        Helper.dbRef.collection("buildings").document(self.buildingid).addSnapshotListener { snapshot, error in
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
            self.AcceptedDic = dic
            
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

extension AcceptedBidVC: UICollectionViewDelegateFlowLayout{
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
