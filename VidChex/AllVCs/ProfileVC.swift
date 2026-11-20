//
//  ProfileVC.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var ProfileTableView: UITableView!
    
    var  itemName = ["Settings","Help","Share","Logout"]
    var itemsImg = ["settings","help","share","logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        editProfileBtn.layer.cornerRadius = 7
        userImageView.layer.cornerRadius = userImageView.layer.frame.height/2
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.6196078431, blue: 0.5019607843, alpha: 1)
        ProfileTableView.delegate = self
        ProfileTableView.dataSource = self
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
        TabBarVC.button.isHidden = false
        UserData()
    }
    
    @IBAction func editProfileAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "editProfileVC") as! editProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ProfileTableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
        
        cell.ImageView.image = UIImage(named: itemsImg[indexPath.row])
        cell.nameLbl.text = itemName[indexPath.row]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backView.layer.cornerRadius = 5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 2 {
            if let name = URL(string: "https://itunes.apple.com/us/app/myapp/idxxxxxxxx?ls=1&mt=8"), !name.absoluteString.isEmpty {
              let objectsToShare = [name]
              let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
              self.present(activityVC, animated: true, completion: nil)
            } else {
              // show alert for not available
            }
           
        } else if indexPath.row == 3 {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LogoutVC") as! LogoutVC
            self.addChild(vc)
            vc.view.frame = self.view.frame
            // vc.delegate = self
            self.view.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
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
            let imageurl = dic["profileImg"] as? String ?? ""
            let imgUrl = dic["profileImg"] as? String ?? ""
            self.userImageView.sd_setImage(with: URL(string: imgUrl),placeholderImage: UIImage(named: "profile"))
            let fullName = (dic["fname"] as? String ?? "" ) + " " + (dic["lname"] as? String ?? "" )
            self.nameLbl.text = fullName
            self.hideIndicator()
          
        }
    }
}
