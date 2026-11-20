//
//  SoldPopUpVC.swift
//  VidChex
//
//  Created by M Hayat on 03/01/2023.
//

import UIKit

class SoldPopUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            //   self.showIndicator(caption: "Please wait..")
        let vc = self.storyboard!.instantiateViewController(withIdentifier:"TabBarVC")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            //   self.hideIndicator()
        }

    }
    

}
