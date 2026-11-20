//
//  NotificationVC.swift
//  VidChex
//
//  Created by M Hayat on 20/01/2023.


import UIKit
import FirebaseFirestore

class NotificationVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var NotificationTableView: UITableView!
    
    var AllNotificationDic:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notifications"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NotificationTableView.dataSource = self
        NotificationTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getUserNotificationData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllNotificationDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NotificationTableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        cell.nameLbl.text = self.AllNotificationDic[indexPath.row]["title"] as? String ?? ""
        cell.titleLbl.text = self.AllNotificationDic[indexPath.row]["content"] as? String ?? ""
        if self.AllNotificationDic[indexPath.row]["read"] as? Bool  == true {
            cell.OpenImageView.image = UIImage(named: "open message")
        } else {
            cell.OpenImageView.image = UIImage(named: "email")
        }
        
        BackGroundViewtableCell(backGroundView: cell.backGroundView)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let buildingid = self.AllNotificationDic[indexPath.row]["productId"] as? String ?? ""
        let id = self.AllNotificationDic[indexPath.row]["id"] as? String ?? ""
        print(id,"id")
        if self.AllNotificationDic[indexPath.row]["type"] as? String ?? "" == "1" {
            
            
            let NotificationPara = ["read":true]
            Helper.dbRef.collection("notifications").document(id).updateData(NotificationPara)
            
            showIndicator(caption: "Please wait...")
            Helper.dbRef.collection("buildings").document(buildingid).getDocument { snapshot, error in
                guard let snap = snapshot?.data(), error == nil else {
                    print(error?.localizedDescription as Any)
                    print("No Data Found in Dictionary")
                    self.hideIndicator()
                    return
                }
                let dic = snap as NSDictionary
                
                if dic["status"] as? Int ?? 0 == 1 {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "myListingsVC") as! myListingsVC
                    vc.Userid = dic["addedBy"] as? String ?? ""
                    Helper.buildingid = dic["id"] as? String ?? ""
                    vc.buildingid = dic["id"] as? String ?? ""
                    self.hideIndicator()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyListingsDetailsVC") as! MyListingsDetailsVC
                    vc.Userid = dic["addedBy"] as? String ?? ""
                    Helper.buildingid = dic["id"] as? String ?? ""
                    vc.buildingid = dic["id"] as? String ?? ""
                    self.hideIndicator()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        } else if self.AllNotificationDic[indexPath.row]["type"] as? String ?? "" == "2" {
            let NotificationPara = ["read":true]
            Helper.dbRef.collection("notifications").document(id).updateData(NotificationPara)
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "MyBidDetailsVC") as! MyBidDetailsVC
            vc.Userid = self.AllNotificationDic[indexPath.row]["receiverId"] as? String ?? ""
            Helper.buildingid = self.AllNotificationDic[indexPath.row]["productId"] as? String ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if self.AllNotificationDic[indexPath.row]["type"] as? String ?? "" == "3" {
            
            let id = self.AllNotificationDic[indexPath.row]["id"] as? String ?? ""
            print(id,"id")
            let NotificationPara = ["read":true]
            Helper.dbRef.collection("notifications").document(id).updateData(NotificationPara)
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "MyListingsDetailsVC") as! MyListingsDetailsVC
            vc.Userid = self.AllNotificationDic[indexPath.row]["receiverId"] as? String ?? ""
            Helper.buildingid = self.AllNotificationDic[indexPath.row]["productId"] as? String ?? ""
            vc.buildingid = self.AllNotificationDic[indexPath.row]["productId"] as? String ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            let NotificationPara = ["read":true]
            Helper.dbRef.collection("notifications").document(id).updateData(NotificationPara)
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "MyListingsDetailsVC") as! MyListingsDetailsVC
            vc.Userid = self.AllNotificationDic[indexPath.row]["receiverId"] as? String ?? ""
            Helper.buildingid = self.AllNotificationDic[indexPath.row]["productId"] as? String ?? ""
            vc.buildingid = self.AllNotificationDic[indexPath.row]["productId"] as? String ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getUserNotificationData() {
        self.AllNotificationDic.removeAll()
        let collectionRef = Firestore.firestore().collection("notifications")
        let query = collectionRef.order(by: "createdOn", descending: true)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents found.")
                    return
                }
                
                var sortedDict = [NSDictionary]()
                for document in documents {
                    let dict = document.data() as NSDictionary
                    if dict["receiverId"] as? String ?? "" == Helper.userId {
                        sortedDict.append(dict)
                        self.AllNotificationDic.append(dict)
                        removeNoData()
                        self.NotificationTableView.reloadData()
                        self.hideIndicator()
                    }
                    if self.AllNotificationDic == [] {
                        showNoData(table: self.NotificationTableView,deatilText: "No Notifications",animationName: " ")
                        self.hideIndicator()
                        self.NotificationTableView.reloadData()
                    }
                }
                print(sortedDict,"sortedDict")
            }
        }
        showNoData(table: self.NotificationTableView,deatilText: "No Notifications",animationName: " ")
        self.hideIndicator()
        self.NotificationTableView.reloadData()
    }
}
