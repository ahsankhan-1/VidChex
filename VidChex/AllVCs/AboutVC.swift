//
//  AboutVC.swift
//  VidChex
//
//  Created by M Hayat on 14/10/2022.
//

import UIKit
import MessageUI

class AboutVC: UIViewController,MFMailComposeViewControllerDelegate {
    
    let composeVC = MFMailComposeViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "About"
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        composeVC.mailComposeDelegate = self
        
        
    }
    
    @IBAction func Btn1Action(_ sender: Any) {
  
        
        UIApplication.shared.openURL(URL(string:"https://www.fivecomproperties.com/")!)
        
    }
    
    @IBAction func Btn2Action(_ sender: Any) {
        
        sendEmail()
        
//        if MFMailComposeViewController.canSendMail() {
//               let composeVC = MFMailComposeViewController()
//               composeVC.setToRecipients(["5conpropertiesllc@gmail.com"])
//               composeVC.setSubject("VidChex Help")
//               composeVC.mailComposeDelegate = self
//               self.present(composeVC, animated: true, completion: nil)
//           } else {
//               // Show error message if the user's device cannot send email
//               print("Device cannot send mail")
//           }
     }
    
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//           controller.dismiss(animated: true, completion: nil)
//       }
    
    func sendEmail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients(["recipient@example.com"])
            mailComposeViewController.setSubject("Subject")
            mailComposeViewController.setMessageBody("Body", isHTML: false)
            
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                
                errorWithTitleMsg(message: "Mail services are not available")
                print("Mail services are not available")
            }
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }


}
