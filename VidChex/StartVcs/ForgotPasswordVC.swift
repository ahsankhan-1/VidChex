//
//  ForgotPasswordVC.swift
//  VidChex
//
//  Created by M Hayat on 28/12/2022.
//

import UIKit
import FirebaseAuth
import PMSuperButton
import AuthenticationServices

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var sendBtn: PMSuperButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()

        self.navigationController?.isNavigationBarHidden = true
        sendBtn.layer.cornerRadius = 7
        shadowtextField(textField: emailTF)
       
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        if emailTF.text == ""{
            Toast.showToast(message: "Please Enter email", controller: self)
           
        }else{
            Auth.auth().sendPasswordReset(withEmail: emailTF.text!, completion: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                     //   Toast.showToast(message: "invalid email adress", controller: self)
                        self.errorWithTitleMsg(title: "invalid email adress", message: error.localizedDescription)
                    } else {
                        
                   //     self.errorWithTitleMsg(title: "reset link sent", message: "")
                    //    self.errorWithMsg(message: "reset link sent")
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                }
            })
        }
    }
    
//    func validate(YourEMailAddress: String) -> Bool {
//        let REGEX: String
//        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
//        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: YourEMailAddress)
//    }
   

}

// implement the ASAuthorizationControllerDelegate protocol
extension ForgotPasswordVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        // handle the authorization response
        if let details = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            print(details.user)
            print(details.fullName)
            print(details.email)
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // handle the error
        print(error.localizedDescription)
    }
    }

