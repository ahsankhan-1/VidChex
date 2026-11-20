//
//  RecentChatVC.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import SDWebImage

class RecentChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var sideImage: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var ChatTableView: UITableView!
    
//    let rightNavigationView = UIView(frame: CGRect(x: 0 , y: 0, width: 200, height: 50))
//    let iconeImage = UIImageView(frame: CGRect(x: -12, y: 10, width: 25, height: 25))
//    let iconeName = UIImageView(frame: CGRect(x: 16, y: 12, width: 70, height: 20))
    
    var RecentchatDic:[NSDictionary] = []
    var exampleDic:[NSDictionary] = []
    var Recentchatkeys = [String]()
    var chatkeys = [String]()
    
    var searchingDic:[NSDictionary] = []
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        getUserskeys()
        ChatTableView.delegate = self
        ChatTableView.dataSource = self
        searchBar.delegate = self
        
        navigationController?.navigationBar.tintColor = .black
        
        sideImage.layer.cornerRadius = sideImage.layer.frame.height/2
        
//        iconeImage.image = UIImage(named: "line")
//        iconeImage.contentMode = UIView.ContentMode.scaleAspectFit
//        iconeImage.layer.masksToBounds = true
//        self.rightNavigationView.addSubview(iconeImage)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: rightNavigationView)
//
//
//        iconeName.image = UIImage(named: "Chat1")
//        iconeName.contentMode = UIView.ContentMode.scaleAspectFit
//        iconeName.layer.masksToBounds = true
//        self.rightNavigationView.addSubview(iconeName)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: rightNavigationView)
        
    }
//    override func viewWillAppear(_ animated: Bool) {
//        tabBarController?.tabBar.isHidden = false
//        TabBarVC.button.isHidden = false
//
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        TabBarVC.button.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        ChatTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        ChatTableView.contentInset = UIEdgeInsets.zero
    }
    
    //MARK: Table View -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching == true {
            return searchingDic.count
        } else {
            return self.RecentchatDic.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ChatTableView.dequeueReusableCell(withIdentifier: "RecentChatTVCell", for: indexPath) as! RecentChatTVCell
        
        if searching == true {
            let imgUrl = self.searchingDic[indexPath.row]["profileImg"] as? String ?? ""
            cell.UserImageView.sd_setImage(with: URL(string: imgUrl),placeholderImage: UIImage(named: "profile"))
            let fullName = (self.searchingDic[indexPath.row]["fname"] as? String ?? "" ) + " " + (self.searchingDic[indexPath.row]["lname"] as? String ?? "" )
            cell.nameLbl.text = fullName
           
            if self.searchingDic[indexPath.row]["online"] as? String ?? "" == "online" {
                cell.onlineImage.tintColor = UIColor.AppGreen
            } else {
                cell.onlineImage.tintColor = UIColor.AppGray
                
            }
        } else {
            let imgUrl = self.RecentchatDic[indexPath.row]["profileImg"] as? String ?? ""
            cell.UserImageView.sd_setImage(with: URL(string: imgUrl),placeholderImage: UIImage(named: "profile"))
            let fullName = self.RecentchatDic[indexPath.row]["fullName"] as? String ?? ""
            cell.nameLbl.text = fullName
            cell.lastmessageLbl.text = self.RecentchatDic[indexPath.row]["lastMsg"] as? String ?? ""
            let time = self.RecentchatDic[indexPath.row]["date"] as? Int ?? 0
            cell.dateLbl.text = timestampToStringAgo(timestamp: Int64(time))
           
            if self.RecentchatDic[indexPath.row]["online"] as? String ?? "" == "online" {
                cell.onlineImage.tintColor = UIColor.AppGreen
            } else {
                cell.onlineImage.tintColor = UIColor.AppGray
                
            }
        }
        
        cell.UserImageView.layer.cornerRadius = cell.UserImageView.layer.frame.height/2
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    //MARK: TableView didSelect -
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        if searching == true {
            vc.recevireId = self.searchingDic[indexPath.row]["id"] as? String ?? ""
            vc.online = self.searchingDic[indexPath.row]["online"] as? String ?? ""
        } else {
            vc.recevireId = self.RecentchatDic[indexPath.row]["id"] as? String ?? ""
            vc.online = self.RecentchatDic[indexPath.row]["online"] as? String ?? ""
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: get Users keys -
    func getUserskeys(){
        
        showIndicator(caption: "Please wait...")
          self.Recentchatkeys.removeAll()
        Helper.dbChatRef.child("chatList").child(Helper.userId).observe( .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let keys = Array(dictionary.keys)
                self.Recentchatkeys = keys.sorted(by: <)
                print(self.Recentchatkeys,"Recentchatkeys")
                let connectedRef = Database.database().reference(withPath: ".info/connected")
                connectedRef.observe(.value, with: { (snapshot) in
                    if snapshot.value as? Bool ?? false {
                        
                        self.retriveMessageData()
                        //   self.hideIndicator()
                        
                    } else {
                        print("error loading")
                        return
                    }
                })
            }
            showNoData(table: self.ChatTableView,deatilText: "No messages yet.",animationName: " ")
            self.hideIndicator()
            self.ChatTableView.reloadData()
        }) {
            (error) in
            print(error.localizedDescription)
            let alert = UIAlertController(title: "No Network", message: "Please connect to internet and try again", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        }
        
//        showNoData(table: self.ChatTableView,deatilText: "No messages yet.",animationName: " ")
//        self.hideIndicator()
    }
    //MARK: retrive MessageData -
    func retriveMessageData(){
        
        self.RecentchatDic.removeAll()
        for key in self.Recentchatkeys{
            Helper.dbChatRef.child("chatList").child(Helper.userId).child(key).observe(.value) { snapShopt in
                guard snapShopt.exists() else {
                    print("Post are not found")
                    return
                }
                let Snap = snapShopt.value as! NSDictionary
                let usersid = Snap["id"] as? String ?? ""
                
                Helper.dbRef.collection("userProfile").document(usersid).getDocument { snapshot, error in
                    guard let snap = snapshot?.data(), error == nil else {
                        print(error?.localizedDescription as Any)
                        print("No Data Found in Dictionary")
                        self.hideIndicator()
                        return
                    }
                    
                    let dic =  snap
                    let name = (dic["fname"] as! String) + " " + (dic["lname"] as! String)
                    let profileImg = dic["profileImg"] as? String ?? ""
                    let online = dic["online"] as? String ?? ""
                    
                    Snap.setValue(name, forKey: "fullName")
                    Snap.setValue(profileImg, forKey: "profileImg")
                    Snap.setValue(online, forKey: "online")
                    
                    self.RecentchatDic.append(Snap)
                    removeNoData()
                    self.hideIndicator()
                    self.ChatTableView.reloadData()
                    
                }
            }
        }
    }
    
    func reloadData(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [self] in
            let contentOffset = ChatTableView.contentOffset
            ChatTableView.reloadData()
            ChatTableView.layoutIfNeeded()
            ChatTableView.setContentOffset(contentOffset, animated: false)
            
            let scrollPoint = CGPoint(x: 0, y: self.ChatTableView.contentSize.height - self.ChatTableView.frame.size.height)
            self.ChatTableView.setContentOffset(scrollPoint, animated: true)
        }
    }
}

// MARK: - Search Extension

extension RecentChatVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(searchText: searchText)
    }
    func filterContent(searchText: String) {
        
        searchingDic = HomeVC.allBuildingsDic.filter { job in
            let jobTitle = ((job["fname"] as? String) ?? "") + ((job["lname"] as? String) ?? "")
            return (jobTitle.lowercased().contains(searchText.lowercased()))
        }
        if searchText == "" {
            searching = false
            self.searchingDic = []
            ChatTableView.reloadData()
        } else {
            searching = true
        self.ChatTableView.reloadData()
        }
    }
}
