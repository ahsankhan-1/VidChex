//
//  SellingHistoryVC.swift
//  VidChex
//
//  Created by M Hayat on 19/10/2022.
//

import UIKit

class SellingHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var SellingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Selling History"
        
        SellingTableView.delegate = self
        SellingTableView.dataSource = self
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SellingTableView.dequeueReusableCell(withIdentifier: "SellingHistoryTVCell", for: indexPath) as! SellingHistoryTVCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.UserImageView.layer.cornerRadius = 7
        BackGroundViewtableCell(backGroundView: cell.BackGroundView)
        
        return cell
    }

}
