//
//  FilterVC.swift
//  VidChex
//
//  Created by M Hayat on 03/01/2023.
//

import UIKit
import iOSDropDown

protocol Category {
    func filterData()
}
class FilterVC: UIViewController {
    
    
    @IBOutlet weak var LocationLbl: UILabel!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var priceTF: DropDown!
    @IBOutlet weak var popularBtn: UIButton!
    @IBOutlet weak var newitemBtn: UIButton!
    @IBOutlet weak var PricehighBtn: UIButton!
    @IBOutlet weak var pricelowBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
   var price = ["1000","10000","1000000","5000000","10000000"]
    
    var delegate:Category?
    static var PriceUnder = ""
    static var FilterCount = 0
    var count = 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstView.layer.cornerRadius = firstView.layer.frame.height/2
        applyBtn.layer.cornerRadius = 7
        PricehighBtn.isSelected = true
        
        
        priceTF.optionArray = price
        priceTF.didSelect{(selectedText , index ,id) in
        self.priceTF.text = selectedText
        }
        priceTF.optionArray = self.price
        priceTF.selectedIndex = 0
        priceTF.text = "$" + " " + self.price[0]
        

    }
    @IBAction func locationBtnAction(_ sender: Any) {
    
        print("0000")
        let vc = storyboard?.instantiateViewController(withIdentifier: "GooglemapVC") as! GooglemapVC
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func Btn1Action(_ sender: Any) {
        popularBtn.isSelected = true
        newitemBtn.isSelected = false
        PricehighBtn.isSelected = false
        pricelowBtn.isSelected = false
        self.count = 1
    }
    
    @IBAction func Btn2Action(_ sender: Any) {
        popularBtn.isSelected = false
        newitemBtn.isSelected = true
        PricehighBtn.isSelected = false
        pricelowBtn.isSelected = false
        self.count = 2
    }
    
    @IBAction func Btn3Action(_ sender: Any) {
        popularBtn.isSelected = false
        newitemBtn.isSelected = false
        PricehighBtn.isSelected = true
        pricelowBtn.isSelected = false
        self.count = 3
    }
    
    @IBAction func Btn4Action(_ sender: Any) {
        popularBtn.isSelected = false
        newitemBtn.isSelected = false
        PricehighBtn.isSelected = false
        pricelowBtn.isSelected = true
        self.count = 4
    }
    
    @IBAction func applyBtnAction(_ sender: Any) {
        
        FilterVC.PriceUnder = priceTF.text!
        FilterVC.FilterCount = self.count
        Helper.filtration = "1"
        delegate?.filterData()
        dismiss(animated: true)
        
    }
    


}
