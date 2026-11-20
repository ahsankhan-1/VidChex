//
//  SellingHistoryTVCell.swift
//  VidChex
//
//  Created by M Hayat on 19/10/2022.
//

import UIKit

class SellingHistoryTVCell: UITableViewCell {
    
    @IBOutlet weak var BackGroundView: UIView!
    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var soldLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
