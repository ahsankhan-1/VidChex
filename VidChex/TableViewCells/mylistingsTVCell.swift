//
//  mylistingsTVCell.swift
//  VidChex
//
//  Created by M Hayat on 03/01/2023.
//

import UIKit

class mylistingsTVCell: UITableViewCell {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    
    var AcceptPressed: (() -> ()) = {}

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    @IBAction func acceptBtnAction(_ sender: Any) {
        AcceptPressed()
        
    }
    
    

}
