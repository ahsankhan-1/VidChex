//
//  BuyingVC.swift
//  VidChex
//
//  Created by M Hayat on 20/10/2022.
//

import UIKit

class BuyingVC: UIViewController {

    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var subtractBtn: UIButton!
    
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var ProductPriceLbl: UILabel!
    @IBOutlet weak var TransactionChargesLbl: UILabel!
    @IBOutlet weak var adminTaxLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    
    @IBOutlet weak var paypalBtn: UIButton!
    @IBOutlet weak var stripeBtn: UIButton!
    @IBOutlet weak var googlepayBtn: UIButton!
    
    @IBOutlet weak var paypalView: UIView!
    @IBOutlet weak var stripeView: UIView!
    @IBOutlet weak var googlepayView: UIView!
    
    @IBOutlet weak var buyBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Buying"
        
        UserImageView.layer.cornerRadius = 7
        sizeLbl.layer.cornerRadius = sizeLbl.layer.frame.height/2
        sizeLbl.layer.masksToBounds = true
        
        paypalBtn.isSelected = true
        
        colorView.layer.cornerRadius = 5
        
        paypalView.layer.cornerRadius = 5
        paypalView.layer.borderWidth = 0.5
        paypalView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        stripeView.layer.cornerRadius = 5
        stripeView.layer.borderWidth = 0.5
        stripeView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        
       
        googlepayView.layer.cornerRadius = 5
        googlepayView.layer.borderWidth = 0.5
        googlepayView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        buyBtn.layer.cornerRadius = 7


        
    }
    @IBAction func addAction(_ sender: Any) {
        
    }
    @IBAction func subtractAction(_ sender: Any) {
        
    }
    
    @IBAction func paypalAction(_ sender: Any) {
        
        paypalBtn.isSelected = true
        stripeBtn.isSelected = false
        googlepayBtn.isSelected = false
        
        
    }
    @IBAction func stripeAction(_ sender: Any) {
        
        paypalBtn.isSelected = false
        stripeBtn.isSelected = true
        googlepayBtn.isSelected = false
        
    }
    
    @IBAction func googlepayAction(_ sender: Any) {
        
        paypalBtn.isSelected = false
        stripeBtn.isSelected = false
        googlepayBtn.isSelected = true
        
    }
    
    @IBAction func buyAction(_ sender: Any) {
        
        
    }
    

}
