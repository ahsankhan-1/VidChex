//
//  SuccessfullPaymentVC.swift
//  VidChex
//
//  Created by M Hayat on 18/01/2023.
//

import UIKit

class SuccessfullPaymentVC: UIViewController {
    
    @IBOutlet var backGroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        backGroundView.layer.cornerRadius = 20
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
            vc?.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            
        }
       
    }
    


}
