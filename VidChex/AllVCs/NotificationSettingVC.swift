//
//  NotificationSettingVC.swift
//  AXL
//
//  Created by M Hayat on 10/10/2022.
//

import UIKit

class NotificationSettingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Notifications settings"
        
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
       
    }
    

    

}
