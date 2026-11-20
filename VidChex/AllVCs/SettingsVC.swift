//
//  SettingsVC.swift
//  VidChex
//
//  Created by M Hayat on 13/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var SettingsTableView: UITableView!
    
    
    var  itemName = ["Notifications","Term & Conditions","Privacy Policy","About","Delete Account"]
    
    var itemsImg = ["bell","accept","svgexport-7 (31) 1","info","Delete Account"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        
        SettingsTableView.delegate = self
        SettingsTableView.dataSource = self
        
       
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        TabBarVC.button.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsTableView.dequeueReusableCell(withIdentifier: "SettingsTVCell", for: indexPath) as! SettingsTVCell
        
        cell.ImageView.image = UIImage(named: itemsImg[indexPath.row])
        cell.nameLbl.text = itemName[indexPath.row]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backView.layer.cornerRadius = 5
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationSettingVC") as!
            NotificationSettingVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 1 {
            
            UIApplication.shared.open(URL(string:"https://sites.google.com/view/vidchex-terms-and-conditions/home")!)
            
        } else if indexPath.row == 2 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "AboutVC") as!
                AboutVC
                self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 3 {
            UIApplication.shared.open(URL(string:"https://sites.google.com/view/vidchex-privacy-policy/home")!)
            
        } else if indexPath.row == 4 {
            
            let alertControllar = UIAlertController(title: "", message: "Do you really want to your Delete Account?", preferredStyle: .alert)
            
            let loginbutton = UIAlertAction(title: "Yes", style: .default) { (action) in
                
                let user = Auth.auth().currentUser!
                
                user.delete { error in
                    if error != nil {
                        // An error happened.
                    } else {
                        // Account deleted.
                        print("user deleted")
                        
                        //MARK: delete User -
                                    
                        Helper.dbRef.collection("buildings").whereField("addedBy", isEqualTo : Helper.userId).addSnapshotListener { querySnapshot, err in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    
                                    let postTempDic = document.data() as NSDictionary
                                    let visitkey = postTempDic["id"] as? String ?? ""
                                    Helper.dbRef.collection("buildings").document(visitkey).delete()
                                }
                            }
                        }
                        //MARK: delete User Notification Data -
                        
                        Helper.dbRef.collection("notifications").whereField("senderId", isEqualTo : Helper.userId).addSnapshotListener { querySnapshot, err in
                            if let err = err {
                            print("Error getting documents: \(err)")
                            } else {
                             
                                for document in querySnapshot!.documents {
                                    let postTempDic = document.data() as NSDictionary
                                    let Notificationkey = postTempDic["id"] as? String ?? ""
                                    Helper.dbRef.collection("notifications").document(Notificationkey).delete()
                                }
                            }
                        }
                        Helper.dbRef.collection("bids").whereField("uid", isEqualTo : Helper.userId).addSnapshotListener { querySnapshot, err in
                            if let err = err {
                            print("Error getting documents: \(err)")
                            } else {
                             
                                for document in querySnapshot!.documents {
                                    let postTempDic = document.data() as NSDictionary
                                    let Notificationkey = postTempDic["id"] as? String ?? ""
                                    Helper.dbRef.collection("bids").document(Notificationkey).delete()
                                }
                            }
                        }
                        
                    Helper.dbRef.collection("userProfile").document(Helper.userId).delete()
                    }
                }
                UserDefaults.standard.set("", forKey: "id")
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                UserDefaults.standard.set("0", forKey: "status")
                let vc = self.storyboard?.instantiateViewController(identifier: "SignInVC") as? SignInVC
                vc?.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            }
            
            let canclebutton = UIAlertAction(title: "No", style: .cancel) { (action) in
                print ("Operation Has Been Cancelled By User")
            }
            
            alertControllar.addAction(loginbutton)
            alertControllar.addAction(canclebutton)
            self.present (alertControllar,animated: true,completion: nil)
            
        }
    }


}
