//
//  BuyingHistoryDetailVC.swift
//  VidChex
//
//  Created by M Hayat on 21/10/2022.
//

import UIKit

class BuyingHistoryDetailVC: UIViewController {
    
    @IBOutlet weak var detailsImageView: UIImageView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var sizeLbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var amountpaidLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsImageView.layer.cornerRadius = 10
        BackGroundView(backGroundView: detailsView)
        colorView.layer.cornerRadius = 5
        sizeLbl.layer.cornerRadius = sizeLbl.layer.frame.height/2
        sizeLbl.layer.masksToBounds = true
        
    }
    
}
