//
//  AllCategoriesVC.swift
//  VidChex
//
//  Created by M Hayat on 13/10/2022.
//

import UIKit

class AllCategoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    
    @IBOutlet weak var AllCategoriesTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Categories"
        
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        AllCategoriesTableView.delegate = self
        AllCategoriesTableView.dataSource = self
        
        
       
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = AllCategoriesTableView.dequeueReusableCell(withIdentifier: "AllCategoriesTVCell", for: indexPath) as! AllCategoriesTVCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.UserImageView.layer.cornerRadius = cell.UserImageView.layer.frame.height/2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SelectedCategoriDetailVC") as! SelectedCategoriDetailVC
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
