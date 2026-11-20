//
//  HomeVC.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import UIKit
import FirebaseFirestore
import SDWebImage
import Kingfisher
import Reachability

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var HomeTableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    let leftNavigationView = UIView(frame: CGRect(x: 0 , y: 0, width: 200, height: 50))
    let NavigationView = UIView(frame: CGRect(x: 0 , y: 0, width: 50, height: 40))
    let iconeImage = UIImageView(frame: CGRect(x: -16, y: 0, width: 180, height: 55))
    let NotiImage = UIImageView(frame: CGRect(x: 16, y: 5, width: 35, height: 35))
    
    static var allBuildingsDic:[NSDictionary] = []
    static var highestBidDic:[NSDictionary] = []
    static var buildingCount = 0
    
    var searchingDic:[NSDictionary] = []
    var searching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        DispatchQueue.main.async {
            if AppDelegate.isNotification == true{
                let vc = self.storyboard?.instantiateViewController(identifier: "NotificationVC") as! NotificationVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        UserData()
   
        
        searchbar.delegate = self
        HomeTableView.delegate = self
        HomeTableView.dataSource = self
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        iconeImage.image = UIImage(named: "VidChex")
        iconeImage.contentMode = UIView.ContentMode.scaleAspectFit
        iconeImage.layer.masksToBounds = true
        self.leftNavigationView.addSubview(iconeImage)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftNavigationView)
        

    //    NotiImage.image = UIImage(named: "show noti")
        NotiImage.layer.cornerRadius = NotiImage.layer.frame.height/2
        NotiImage.contentMode = UIView.ContentMode.scaleToFill
        NotiImage.layer.masksToBounds = true
        self.NavigationView.addSubview(NotiImage)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: NavigationView)
        
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(NotificationVC))
        NotiImage.isUserInteractionEnabled = true
        NotiImage.addGestureRecognizer(tapGesture)

    }
    @objc func NotificationVC(){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        TabBarVC.button.isHidden = false
        getAllNotifications()
        getAllBuildings()
        HomeTableView.reloadData()
    }
    
    @IBAction func SeeAllBtnAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(identifier: "SelectedCategoriDetailVC") as! SelectedCategoriDetailVC
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
 
    //MARK: TableView View -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching == true {
            return searchingDic.count
        } else {
            return HomeVC.allBuildingsDic.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = HomeTableView.dequeueReusableCell(withIdentifier: "HomeTVCell", for: indexPath) as! HomeTVCell
        
        if searching == true {
            cell.nameLbl.text = self.searchingDic[indexPath.row]["title"] as? String ?? ""
            cell.aboutLbl.text = self.searchingDic[indexPath.row]["location"] as? String ?? ""
            cell.priceLbl.text = "$" + "" + String(self.searchingDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
            let imageUrl = self.searchingDic[indexPath.row]["videos"] as? [String]
            let video = URL(string: imageUrl![0])
            cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
            
        } else {
            
            cell.nameLbl.text = HomeVC.allBuildingsDic[indexPath.row]["title"] as? String ?? ""
            cell.aboutLbl.text = HomeVC.allBuildingsDic[indexPath.row]["location"] as? String ?? ""
            cell.priceLbl.text = "$" + "" + String(HomeVC.allBuildingsDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
            let imageUrl = HomeVC.allBuildingsDic[indexPath.row]["videos"] as? [String]
            let video = URL(string: imageUrl![0])
            cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
           
        }
        
        cell.UserImageView.layer.cornerRadius = 7
        BackGroundViewtableCell(backGroundView: cell.BackGroundView)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeDetailsVC") as! HomeDetailsVC
        
        if self.searching == true {
            vc.Userid = self.searchingDic[indexPath.row]["addedBy"] as? String ?? ""
            Helper.highestBidPrice = self.searchingDic[indexPath.row]["highestBid"] as? Int ?? 0
            Helper.buildingid = self.searchingDic[indexPath.row]["id"] as? String ?? ""
            } else {
            vc.Userid = HomeVC.allBuildingsDic[indexPath.row]["addedBy"] as? String ?? ""
                Helper.highestBidPrice = HomeVC.allBuildingsDic[indexPath.row]["highestBid"] as? Int ?? 0
                Helper.buildingid = HomeVC.allBuildingsDic[indexPath.row]["id"] as? String ?? ""
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: User Data -
    
    func UserData() {
          showIndicator(caption: "Please wait...")
        Helper.dbRef.collection("userProfile").document(Helper.userId).addSnapshotListener { snapshot, error in
            guard let snap = snapshot?.data(), error == nil else {
                print(error?.localizedDescription as Any)
                print("No Data Found in Dictionary")
                self.hideIndicator()
                return
            }
          let dic = snap as NSDictionary
            Helper.userDic = dic
            print(Helper.userDic,"userDic")
            self.hideIndicator()
        }
    }
    //MARK: get All Notifications -
    func getAllNotifications() {
        
        Helper.dbRef.collection("notifications").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retreiving snapshots \(error!)")
                return
            }
            for document in snapshot.documents {
                let postTempDic = document.data() as NSDictionary
                if postTempDic["receiverId"] as? String ?? "" == Helper.userId {
                    
                    if postTempDic["read"] as? Bool == false {
                        self.NotiImage.image = UIImage(named: "show noti")
                        break
                    } else {
                        self.NotiImage.image = UIImage(named: "noti")
                    }
                }
            }
        }
        self.NotiImage.image = UIImage(named: "noti")
    }
    
    //MARK: Get Posts -
    func getAllBuildings() {
        
        showIndicator(caption: "Please wait...")
        HomeVC.allBuildingsDic.removeAll()
        Helper.dbRef.collection("buildings").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retreiving snapshots \(error!)")
                return
            }
            for document in snapshot.documents {
            let postTempDic = document.data() as NSDictionary
            if (postTempDic["status"] as? Int ?? 0) == 1 {
                    HomeVC.allBuildingsDic.append(postTempDic)
                    removeNoData()
                    self.HomeTableView.reloadData()
                    HomeVC.buildingCount = 0
                   self.hideIndicator()
                }
            }
        }
        
        showNoData(table: self.HomeTableView,deatilText: "No Post Yet",animationName: " ")
        self.hideIndicator()
          self.HomeTableView.reloadData()
    }
    
    func getMilliFromDate(dateFromDB:String,formate:String) -> Int64 {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = formate
        let date = dateFormatter.date(from:dateFromDB)
        let milli  = date!.millisecondsSince1970
        return milli
        
    }
}

// MARK: - Search Extension

extension HomeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(searchText: searchText)
    }
    func filterContent(searchText: String) {
        
        searchingDic = HomeVC.allBuildingsDic.filter { job in
            let jobTitle = (job["title"] as? String) ?? ""
            let location = (job["location"] as? String) ?? ""
            return (jobTitle.lowercased().contains(searchText.lowercased()) || location.lowercased().contains(searchText.lowercased()))
        }
        if searchText == "" {
            searching = false
            self.searchingDic = []
            HomeTableView.reloadData()
        } else {
            searching = true
        self.HomeTableView.reloadData()
        }
    }
}
