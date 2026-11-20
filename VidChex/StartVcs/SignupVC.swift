//
//  SignupVC.swift
//  VidChex
//
//  Created by M Hayat on 28/12/2022.
//

import UIKit

class SignupVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var eyeBtn1: UIButton!
    @IBOutlet weak var eyeBtn2: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    static var firstname = ""
    static var lastname = ""
    static var email = ""
    static var password = ""
    static var confirmPassword = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        self.navigationController?.isNavigationBarHidden = true
        shadowtextField(textField: firstNameTF)
        shadowtextField(textField: lastNameTF)
        shadowtextField(textField: emailTF)
        shadowtextFieldRightPadding(textField: passwordTF)
        shadowtextFieldRightPadding(textField: confirmPasswordTF)
        signupBtn.layer.cornerRadius = 7
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        confirmPasswordTF.delegate = self
        
        UserDefaults.standard.set("0", forKey: "status")
        
    }
    
    @IBAction func eyeAction1(_ sender: Any) {
        if eyeBtn1.isSelected == true {
            eyeBtn1.isSelected = false
            passwordTF.isSecureTextEntry = true
        } else {
            eyeBtn1.isSelected = true
            passwordTF.isSecureTextEntry = false
        }
    }
    
    @IBAction func eyeAction2(_ sender: Any) {
        
        if eyeBtn2.isSelected == true {
            eyeBtn2.isSelected = false
            confirmPasswordTF.isSecureTextEntry = true
        } else {
            eyeBtn2.isSelected = true
            confirmPasswordTF.isSecureTextEntry = false
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signupAction(_ sender: Any) {
        
        SignupVC.firstname = self.firstNameTF.text ?? ""
        SignupVC.lastname = self.lastNameTF.text ?? ""
        SignupVC.email = self.emailTF.text ?? ""
        SignupVC.password = self.passwordTF.text ?? ""
        SignupVC.confirmPassword = self.confirmPasswordTF.text ?? ""
        
        if SignupVC.firstname == "" {
            Toast.showToast(message: "Please give first name", controller: self)
        } else if SignupVC.lastname == ""{
            Toast.showToast(message: "Please give last name", controller: self)
        } else if validate(YourEMailAddress: SignupVC.email) != true {
            Toast.showToast(message: "Invalid email", controller: self)
        } else if SignupVC.password == "" {
            Toast.showToast(message: "Please give password", controller: self)
        } else if SignupVC.confirmPassword == "" {
            Toast.showToast(message: "Invalid email", controller: self)
        } else if SignupVC.confirmPassword != SignupVC.password {
            Toast.showToast(message: "Password does not match", controller: self)
        } else {
            
            showIndicator(caption: "Please wait...")
            
            Helper.dbRef.collection("userProfile").whereField("email", isEqualTo : emailTF.text!).getDocuments { [self] querySnapshot, err in
                if  querySnapshot!.documents == [] {
                    
                    self.hideIndicator()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "EmailOTPVC") as! EmailOTPVC
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.hideIndicator()
                    Toast.showToast(message: "This email is already in use", controller: self)
                }
            }
        }
    }
    
    func validate(YourEMailAddress: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: YourEMailAddress)
    }
}
