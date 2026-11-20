//
//  LogoutVC.swift
//  AXL
//
//  Created by M Hayat on 10/10/2022.
//

import UIKit

class LogoutVC: UIViewController {

    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        cancelBtn.layer.cornerRadius = 12
        logoutBtn.layer.cornerRadius = 7
        
        mainView.layer.cornerRadius = 10
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowRadius = 3.0
        mainView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        mainView.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        mainView.layer.masksToBounds = false
        
       
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        removeAnimation()
    }
    
    @IBAction func logoutBtnAction(_ sender: Any) {
       
        UserDefaults.standard.set("", forKey: "id")
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set("0", forKey: "status")
        let vc = self.storyboard?.instantiateViewController(identifier: "SigninNavigation")
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
        
    }

}
