//
//  BuyingHistoryVC.swift
//  VidChex
//
//  Created by M Hayat on 19/10/2022.
//

import UIKit

class BuyingHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    
   
    @IBOutlet weak var BuyingTableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Buying History"
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        BuyingTableView.delegate = self
        BuyingTableView.dataSource = self
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        
        
        
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = BuyingTableView.dequeueReusableCell(withIdentifier: "BuyingHistoryTVCell", for: indexPath) as! BuyingHistoryTVCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.UserImageView.layer.cornerRadius = 7
        BackGroundViewtableCell(backGroundView: cell.BackGroundView)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "BuyingHistoryDetailVC") as! BuyingHistoryDetailVC
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}
