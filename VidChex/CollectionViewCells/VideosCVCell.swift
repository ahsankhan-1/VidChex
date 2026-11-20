//
//  VideosCVCell.swift
//  VidChex
//
//  Created by M Hayat on 24/10/2023.
//

import UIKit

class VideosCVCell: UICollectionViewCell {
    
    @IBOutlet weak var VideoView: UIImageView!
    @IBOutlet weak var crossBtn: UIButton!
    
    
    var deleteAction = {}
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        
        deleteAction()
        
    }
    
}
