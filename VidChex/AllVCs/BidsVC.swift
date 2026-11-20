//
//  BidsVC.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import UIKit
import Foundation
import Kingfisher

class BidsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var BidTableView: UITableView!
    @IBOutlet weak var segmentControll: CustomSegmentedControl!
    @IBOutlet weak var BidsTableView: UITableView!
    
    
    let rightNavigationView = UIView(frame: CGRect(x: 0 , y: 0, width: 410, height: 60))
    let iconeImage = UIImageView(frame: CGRect(x: 10, y: 7, width: 30, height: 30))
    let iconeName = UIImageView(frame: CGRect(x: 40, y: 7, width: 100, height:25))
    
    var listingBidsDic:[NSDictionary] = []
    var myBidsDic:[NSDictionary] = []
    var Array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
              
        
        backView.layer.borderWidth = 1
        backView.layer.cornerRadius = backView.layer.frame.height/2
        backView.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.6196078431, blue: 0.5019607843, alpha: 1)
        
        segmentControll.layer.cornerRadius = segmentControll.layer.frame.height/2
        segmentControll.selectedSegmentIndex = 0
        
        BidsTableView.delegate = self
        BidsTableView .dataSource = self
        
        iconeImage.image = UIImage(named: "line")
        iconeImage.contentMode = UIView.ContentMode.scaleAspectFit
        iconeImage.layer.masksToBounds = true
        self.rightNavigationView.addSubview(iconeImage)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavigationView)
        
        iconeName.image = UIImage(named: "Bids")
        iconeName.contentMode = UIView.ContentMode.scaleAspectFit
        iconeName.layer.masksToBounds = true
        self.rightNavigationView.addSubview(iconeName)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavigationView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
        TabBarVC.button.isHidden = false
        getAllBuildings()
        
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        if segmentControll.selectedSegmentIndex == 0 {
            if self.myBidsDic.isEmpty {
                showNoData(table: self.BidsTableView,deatilText: "No data found",animationName: " ")
                self.BidsTableView.reloadData()
            } else {
                removeNoData()
                self.BidTableView.reloadData()
            }
            
        } else {
            
            if self.listingBidsDic.isEmpty {
                showNoData(table: self.BidsTableView,deatilText: "No data found",animationName: " ")
                
                self.BidsTableView.reloadData()
            } else {
                removeNoData()
                self.BidTableView.reloadData()
            }
         //   self.BidsTableView.reloadData()
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentControll.selectedSegmentIndex == 0 {
            return self.myBidsDic.count
            
        } else {
            return self.listingBidsDic.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = BidsTableView.dequeueReusableCell(withIdentifier: "BidsTVCell", for: indexPath) as! BidsTVCell
        
        if segmentControll.selectedSegmentIndex == 0 {
            cell.activeLbl.text = "Active"
            cell.bidLbl.text = "My Bid"
            cell.activeLbl.textColor = #colorLiteral(red: 0.03529411765, green: 0.6196078431, blue: 0.5019607843, alpha: 1)
            
            cell.nameLbl.text = self.myBidsDic[indexPath.row]["title"] as? String ?? ""
            cell.aboutLbl.text = self.myBidsDic[indexPath.row]["location"] as? String ?? ""
            cell.bidPriceLbl.text = "$" + "" + String(self.myBidsDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
            cell.priceLbl.text = "$" + " " + String(self.myBidsDic[indexPath.row]["highestBid"] as? Int ?? 0) + "" + ".0"
            let imageUrl = self.myBidsDic[indexPath.row]["videos"] as? [String]
            let video = URL(string: imageUrl![0])
            cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
            
        }else {
            cell.activeLbl.text = "Active"
            cell.bidLbl.text = "Highest Bid"
            cell.activeLbl.textColor = #colorLiteral(red: 0.8666666667, green: 0.3882352941, blue: 0.431372549, alpha: 1)
            
            cell.nameLbl.text = self.listingBidsDic[indexPath.row]["title"] as? String ?? ""
            cell.aboutLbl.text = self.listingBidsDic[indexPath.row]["location"] as? String ?? ""
            cell.bidPriceLbl.text = "$" + "" + String(self.listingBidsDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
            cell.priceLbl.text = "$" + "" + String(self.listingBidsDic[indexPath.row]["highestBid"] as? Int ?? 0) + "" + ".0"
            
            let imageUrl = self.listingBidsDic[indexPath.row]["videos"] as? [String]
            let video = URL(string: imageUrl![0])
            cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
            
        }
        
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.UserImageView.layer.cornerRadius = 7
        BackGroundViewtableCell(backGroundView: cell.BackGroundView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentControll.selectedSegmentIndex == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "MyBidDetailsVC") as! MyBidDetailsVC
            vc.Userid = self.myBidsDic[indexPath.row]["addedBy"] as? String ?? ""
           
            Helper.highestBidPrice = self.myBidsDic[indexPath.row]["highestBid"] as? Int ?? 0
            Helper.buildingid = self.myBidsDic[indexPath.row]["id"] as? String ?? ""
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if segmentControll.selectedSegmentIndex == 1 {
            
            if self.listingBidsDic[indexPath.row]["status"] as? Int ?? 0 == 1 {
                let vc = storyboard?.instantiateViewController(withIdentifier: "myListingsVC") as! myListingsVC
                vc.Userid = self.listingBidsDic[indexPath.row]["addedBy"] as? String ?? ""
                vc.buildingid = self.listingBidsDic[indexPath.row]["id"] as? String ?? ""
                Helper.buildingid = self.listingBidsDic[indexPath.row]["id"] as? String ?? ""
                vc.highestBidPrice = String(self.listingBidsDic[indexPath.row]["highestBid"] as? Int ?? 0)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "MyListingsDetailsVC") as! MyListingsDetailsVC
                vc.Userid = self.listingBidsDic[indexPath.row]["addedBy"] as? String ?? ""
                vc.buildingid = self.listingBidsDic[indexPath.row]["id"] as? String ?? ""
                Helper.buildingid = self.listingBidsDic[indexPath.row]["id"] as? String ?? ""
                vc.highestBidPrice = String(self.listingBidsDic[indexPath.row]["highestBid"] as? Int ?? 0)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    //MARK: Get Posts -
    func getAllBuildings() {
        
        showIndicator(caption: "Please wait...")
        self.listingBidsDic.removeAll()
        self.myBidsDic.removeAll()
        
        Helper.dbRef.collection("buildings").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retreiving snapshots \(error!)")
                return
            }
            for document in snapshot.documents {
                let postTempDic = document.data() as NSDictionary
                
                if postTempDic["addedBy"] as? String ?? "" == Helper.userId {
                        self.listingBidsDic.append(postTempDic)
                        removeNoData()
                        self.BidTableView.reloadData()
                        self.hideIndicator()
                    
                }
                
                let bidid = postTempDic["id"] as? String ?? ""
                let citiesRef = Helper.dbRef.collection("bids")
                let query1 = citiesRef.whereField("buildingId", isEqualTo: bidid)
                let query2 = query1.whereField("uid", isEqualTo: Helper.userId)

                query2.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let dict = document.data() as NSDictionary
                            let buildingId = dict["buildingId"] as? String ?? ""
                            self.Array.append(buildingId)
                        }
                        let uniqueStrings = self.uniqueElementsFrom(array:self.Array)
                        if uniqueStrings.contains(bidid) {
                        self.myBidsDic.append(postTempDic)
                            removeNoData()
                        self.hideIndicator()
                        self.BidTableView.reloadData()
                            
                        } else {
                            if self.myBidsDic.isEmpty {
                            showNoData(table: self.BidsTableView,deatilText: "No data found",animationName: " ")
                                self.hideIndicator()
                                self.BidsTableView.reloadData()
                                }
                        }                       
                    }
                }
            }
        }
        showNoData(table: self.BidTableView,deatilText: "No data found",animationName: " ")
        self.hideIndicator()
        self.BidTableView.reloadData()
    }
    
    func uniqueElementsFrom(array: [String]) -> [String] {
      var set = Set<String>()
      let result = array.filter {
        guard !set.contains($0) else {
          return false
        }
        set.insert($0)
        return true
      }
      return result
    }
}
