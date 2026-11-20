//
//  EmailOTPVC.swift
//  VidChex
//
//  Created by M Hayat on 28/12/2022.
//

import UIKit
import AEOTPTextField
import FirebaseAuth
import FirebaseFirestore
import Alamofire

class EmailOTPVC: UIViewController {
    
    @IBOutlet weak var otpTF: AEOTPTextField!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var DoneBtn: UIButton!
    

    var otpCode = ""
    var secondsRemaining = 59
    var otptestcode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        otptestcode =  generateRandomDigits(4)
     //   self.navigationController?.isNavigationBarHidden = true
        otpTF.keyboardType = .numberPad
        resendBtn.setTitle("60s", for: .normal)
        otpTF.otpDelegate = self
        otpTF.configure(with: 4)
        otpTF.otpFontSize = 16
        otpTF.otpTextColor = .white
        otpTF.otpCornerRaduis = 5
        otpTF.otpFilledBorderColor = .clear
        otpTF.otpFilledBackgroundColor = #colorLiteral(red: 0.03529411765, green: 0.6196078431, blue: 0.5019607843, alpha: 1)
        otpTF.becomeFirstResponder()
    //    otpTimer()
        DoneBtn.layer.cornerRadius = 7
        
        print(otptestcode,"testCode")
        Toast.showToast(message: "test code = \(otptestcode)", controller: self)
        SendCode()

    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resendBtnAction(_ sender: Any) {
        
//        resendBtn.setTitle("60s", for: .normal)
//        otpTimer()
//        DoneBtn.isUserInteractionEnabled = false
        
        SendCode()
        
    }
    
    func SendCode() {
        
        self.otptestcode = "\(generateRandomDigits(4))"
        let dict = ["to":SignupVC.email,"subject":"Email Verification!","message":"Your verification code for sign up VidChex is \(self.otptestcode)"]
        self.otpTimer()
        AF.request("https://Apis.appistaan.com/mailapi/index.php?key=sk286292djd926d", method: .post, parameters: dict).responseString { (response) in
            switch response.result{
            case .success(_):
                print("yes")
                self.hideIndicator()
                print(self.otptestcode,"testCode")
                Toast.showToast(message: "test code = \(self.otptestcode)", controller: self)
                
           //     self.codeTF.isHidden = false
          //      self.verifyBtn.isHidden = false
             //   UserDefaults.standard.set(randomNumber, forKey: "code")
                // UserDefaults.standard.set(self.emailTF.text, forKey: "email")
                //                    _ = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { timer in
                //                        UserDefaults.standard.set("", forKey: "code")
                //                        UserDefaults.standard.set("", forKey: "email")
                //                       }
            case .failure(_):
                print("fail")
                self.hideIndicator()
                self.errorWithTitleMsg(title: "Verification Code Sending Failed!", message: "")
            }
        }
        
    }
    
    
    
    @IBAction func doneBtnAction(_ sender: Any) {
        
//        let code = UserDefaults.standard.string(forKey: "code")
//        print(code ?? "","code0000")
        if otpTF.text != self.otptestcode {
            Toast.showToast(message: "Invalid OTP", controller: self)
        } else {
            showIndicator(caption: "Please wait...")
        Auth.auth().createUser(withEmail:SignupVC.email,password:SignupVC.password) { [self] authResult, error in
                guard authResult != nil, error == nil else {
                    self.hideIndicator()
                    errorWithMsg(message: (error?.localizedDescription)!)
                    return
                }
                Helper.userId = Auth.auth().currentUser!.uid
                UserDefaults.standard.set(Helper.userId, forKey: "id")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                
               
            let para = ["about":"","address":"","authFrom":"email","city":"","complete":true,"country":"","createdOn":NSDate.now,"dob":"","email":SignupVC.email,"fname":SignupVC.firstname,"gender":"","latlng":"","lname":SignupVC.lastname,"online":"","profileImg":"","token":"","typing":"noOne","uid":Helper.userId,"updatedOn":NSDate.now] as [String : Any]
                
                Helper.dbRef.collection("userProfile").document(Helper.userId).setData(para)
            
            Helper.dbRef.collection("userProfile").document( Helper.userId).updateData(["token":AppDelegate.token])
                self.hideIndicator()
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileNavigation")
                vc!.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
    
            
            }
        }
    }
    
    func otpTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { Timer in
            if self.secondsRemaining > 0 {
                //  print("\(self.secondsRemaining) seconds")
                self.resendBtn.setTitle("\(self.secondsRemaining)s", for: .normal)
                self.resendBtn.isUserInteractionEnabled = false
                self.secondsRemaining -= 1
            } else {
                Timer.invalidate()
                self.resendBtn.isUserInteractionEnabled = true
                self.resendBtn.setTitle("Resend Code", for: .normal)
                self.secondsRemaining = 59
            }
        }
    }
    
}

extension EmailOTPVC: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        otpCode = code
     //   print(otpCode)
        if otpCode != "" {
            DoneBtn.isUserInteractionEnabled = true
        }
    }
}

