//
//  CartTVCell.swift
//  VidChex
//
//  Created by M Hayat on 19/10/2022.
//

import UIKit

class CartTVCell: UITableViewCell {
    
    
    @IBOutlet weak var BackGroundView: UIView!
    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var subtractBtn: UIButton!
    
    var deletePressed : (() -> ()) = {}
    var addPressed : (() -> ()) = {}
    var subtractPressed : (() -> ()) = {}
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
     
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
        deletePressed()
        
    }
    
    @IBAction func AddAction(_ sender: Any) {
        
        addPressed()
        
    }
    
    @IBAction func subtractAction(_ sender: Any) {
        
        subtractPressed()
        
    }
    

}
