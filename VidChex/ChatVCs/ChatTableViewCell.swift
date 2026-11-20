//
//  ChatTableViewCell.swift
//  VidChex
//
//  Created by M Hayat on 13/01/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sendLbl: UILabel!
    @IBOutlet weak var receiveLbl: UILabel!
    @IBOutlet weak var seenLbl: UILabel!
    @IBOutlet weak var recevertimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
