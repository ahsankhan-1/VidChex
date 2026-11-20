//
//  CartVC.swift
//  VidChex
//
//  Created by M Hayat on 19/10/2022.
//

import UIKit

class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    
    @IBOutlet weak var CartTableView: UITableView!
    
    let floatingButton = UIButton()
    
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        CartTableView.delegate = self
        CartTableView.dataSource = self
        
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        
        
        floatingButton.setTitle("Checkout", for: .normal)
        floatingButton.backgroundColor = #colorLiteral(red: 0.03529411765, green: 0.6196078431, blue: 0.5019607843, alpha: 1)
        floatingButton.layer.cornerRadius = 7
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.widthAnchor.constraint(equalToConstant: 170).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100).isActive = true
        
        floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -30).isActive = true
        
        
        
        
        let tapGesture1 = UITapGestureRecognizer()
        tapGesture1.addTarget(self, action: #selector(FloatingAction))
        floatingButton.isUserInteractionEnabled = true
        floatingButton.addGestureRecognizer(tapGesture1)
        
        
        
    }
    
    @objc func FloatingAction() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CheckoutBuyingVC") as! CheckoutBuyingVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    
    @IBAction func clearAllAction(_ sender: Any) {
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = CartTableView.dequeueReusableCell(withIdentifier: "CartTVCell", for: indexPath) as! CartTVCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.UserImageView.layer.cornerRadius = 7
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "BuyingVC") as! BuyingVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    //    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    //        self.lastContentOffset = scrollView.contentOffset.y
    //    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        if self.lastContentOffset < scrollView.contentOffset.y {
    //
    //            // did move up
    //            floatingButton.isHidden = false
    //
    //        } else if self.lastContentOffset > scrollView.contentOffset.y {
    //
    //            // did move down
    //            floatingButton.isHidden = false
    //
    //        } else {
    //            // didn't move
    //        }
    //    }
    
    
}
