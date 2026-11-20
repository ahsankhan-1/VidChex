//
//  SignInVC.swift
//  VidChex
//  Created by M Hayat on 26/12/2022.

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Firebase
import AuthenticationServices
import Alamofire
import CryptoKit
import GoogleSignIn


class SignInVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    
    @IBOutlet weak var signupBtn: UILabel!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    var currentNonce :String?
    var nonce = ""
    var appleFname = ""
    var appleLname = ""
    var appleEmail = ""
    
    //  let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        shadowtextField(textField: emailTF)
        shadowtextFieldRightPadding(textField: passwordTF)
        loginBtn.layer.cornerRadius = 10
        googleBtn.layer.cornerRadius = googleBtn.layer.frame.height/2
        appleBtn.layer.cornerRadius = appleBtn.layer.frame.height/2
        
        emailTF.delegate = self
        passwordTF.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        return true
    }
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.emailTF:
            self.passwordTF.becomeFirstResponder()
        default:
            self.passwordTF.resignFirstResponder()
        }
    }
    
    //    func checkInterNetConnection(){
    //        reachability.whenReachable = { reachability in
    //            if reachability.connection == .wifi{
    //                print("Reach able via wifi")
    //            }else{
    //                print("Reachable via cellular")
    //            }
    //        }
    //
    //        reachability.whenReachable = { _ in
    //            print("not reachable")
    //            self.errorWithTitleMsg(title: "No Internet", message: "This app requires wifi/internet")
    //        }
    //
    //        do{
    //           try reachability.startNotifier()
    //        }
    //        catch{
    //            print("unable to start notifier")
    //        }
    //    }
    
    @IBAction func showpasswordAction(_ sender: Any) {
        if eyeBtn.isSelected == true {
            eyeBtn.isSelected = false
            passwordTF.isSecureTextEntry = true
        } else {
            eyeBtn.isSelected = true
            passwordTF.isSecureTextEntry = false
        }
    }
    @IBAction func forgotAction(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func signupAction(_ sender: Any) {
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        guard let email = emailTF.text, !email.isEmpty else {
              Toast.showToast(message: "Please give email", controller: self)
              return
          }
          
          guard let password = passwordTF.text, !password.isEmpty else {
              Toast.showToast(message: "Please give password", controller: self)
              return
          }
          
          showIndicator(caption: "Please wait..")
          
          Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              guard let self = self else { return }
              
              if authResult != nil {
                  Helper.dbRef.collection("userProfile").whereField("email", isEqualTo: email).getDocuments { querySnapshot, error in
                      if let error = error {
                          self.hideIndicator()
                          self.errorWithMsg(message: error.localizedDescription)
                          return
                      }
                      
                      if querySnapshot?.documents.isEmpty == true {
                          self.hideIndicator()
                          // Handle the case when the email is not found
                      } else {
                          if let document = querySnapshot?.documents.first {
                              let dict = document.data()
                              if let userId = dict["uid"] as? String {
                                  Helper.userId = userId
                                  UserDefaults.standard.set(Helper.userId, forKey: "id")
                                  UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                                  Helper.dbRef.collection("userProfile").document(userId).updateData(["token": AppDelegate.token])
                                  
                                  self.hideIndicator()
                                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                                  vc?.modalPresentationStyle = .fullScreen
                                  self.present(vc!, animated: true, completion: nil)
                              }
                          }
                      }
                  }
              } else {
                  self.hideIndicator()
                  self.errorWithMsg(message: error?.localizedDescription ?? "Unknown error")
              }
          }
        
    }
    
    //MARK: Apple login -
    
    @IBAction func loginWithApple(_ sender: UIButton) {
        
        startSignInWithAppleFlow()
        
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    //    @objc func handleAppleLogin() {
    //        let appleIDProvider = ASAuthorizationAppleIDProvider()
    //        let request = appleIDProvider.createRequest()
    //        request.requestedScopes = [.fullName, .email]
    //
    //        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    //        authorizationController.delegate = self
    //        authorizationController.performRequests()
    //    }
    
    //MARK: Google login -
    
    @IBAction func googlelogin(_ sender: Any) {
        
        // Set up sign-in configuration
        guard (FirebaseApp.app()?.options.clientID) != nil else {
            print("FirebaseApp is not configured.")
            return
        }
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { GidUser, error in
            if error == nil {
                
                
                let email = GidUser!.user.profile!.email
                let firstName = (GidUser!.user.profile!.givenName)!
                let lastName = (GidUser!.user.profile!.familyName)!
                let idtoken = GidUser!.user.idToken
                let accesstoken = GidUser!.user.accessToken
                let imgUrl = GidUser!.user.profile!.imageURL(withDimension: 320)
                
                let credential = GoogleAuthProvider.credential(withIDToken: GidUser!.user.idToken!.tokenString, accessToken: GidUser!.user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential, completion: { (authResult, error) in
                    if (error != nil){
                        return
                    }else{
                        
                        let id = authResult!.user.uid
                        Helper.userId = id
                        print(Helper.userId,"Helper.userId")
                        
                        self.showIndicator(caption:"Please wait...")
                        
                        Helper.dbRef.collection("userProfile").whereField("email", isEqualTo : email).getDocuments { [self] querySnapshot, err in
                            if  querySnapshot!.documents == [] {
                                self.hideIndicator()
                               SignUpWithGoogle(email: email, firstName: firstName, lastName: lastName)
                            } else {
                                for document in querySnapshot!.documents {
                                    let dict = document.data()
                                    Helper.userId = (dict["uid"] as? String ?? "")
                                    
                                    let auth = dict["authFrom"] as? String ?? ""
                                    if auth == "google" {
                                        
                                        UserDefaults.standard.set(Helper.userId, forKey: "id")
                                        print(Helper.userId,"userId")
                                        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                                        Helper.dbRef.collection("userProfile").document( Helper.userId).updateData(["token":AppDelegate.token])
                                        
                                        self.hideIndicator()
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                                        vc!.modalPresentationStyle = .fullScreen
                                        self.present(vc!, animated: true, completion: nil)
                                    } else {
                                        self.hideIndicator()
                                    Toast.showToast(message: "This email is already in use", controller: self)
                                    }
                                    
                                }
                            }
                        }
                    }
                })
                
            }else{
                print(error!.localizedDescription,"getting error")
            }
        }
    }
    //MARK: SignUp With Google -
    
    func SignUpWithGoogle(email:String,firstName:String,lastName:String) {
        
        Helper.userId = Auth.auth().currentUser!.uid
        print(Helper.userId,"Helper.userId")
        UserDefaults.standard.set(Helper.userId, forKey: "id")
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()

        let para = ["about":"","address":"","authFrom":"google","city":"","complete":true,"country":"","createdOn":NSDate.now,"dob":"","email":email,"fname":firstName,"gender":"","latlng":"","lname":lastName,"online":"","profileImg":"","token":"","typing":"noOne","uid":Helper.userId,"updatedOn":NSDate.now] as [String : Any]

        Helper.dbRef.collection("userProfile").document(Helper.userId).setData(para)

        Helper.dbRef.collection("userProfile").document( Helper.userId).updateData(["token":AppDelegate.token])
        
        self.hideIndicator()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileNavigation")
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)

    }
    
    
}

//MARK: Apple login extension -

    extension SignInVC:ASAuthorizationControllerPresentationContextProviding {
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
        }
    }
    
    extension SignInVC:ASAuthorizationControllerDelegate {
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Sign in with Apple Faild: \(error.localizedDescription)")
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    print(currentNonce as Any )
                    return
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                print(appleIDCredential, "idcred")
                print(idTokenString, "hh-idtoken")
                self.appleFname = appleIDCredential.fullName?.givenName ?? ""
                self.appleLname = appleIDCredential.fullName?.familyName ?? ""
                self.appleEmail = appleIDCredential.email ?? ""
                
                print("User first name: \(self.appleFname)")
                print("User last name: \(self.appleLname )")
                print("User email: \(self.appleEmail)")
                //print("User ID: \(uid ?? "")")
                
//                UserDefaults.standard.set(self.appleFname, forKey: "fullName")
//                UserDefaults.standard.set(self.appleLname, forKey: "fullName")
//                UserDefaults.standard.set(self.appleEmail, forKey: "fullName")
                
                UserDefaults.standard.synchronize()
                
                //  print(appleIDCredential.fullName, "applefname")
                print(self.appleLname, "appleL")
                
                // Initialize a Firebase credential.
                let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                // Sign in with Firebase
                //   ShowIndicator()
                
                print("aff","Login as apple")
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if (error != nil) {
                        self.hideIndicator()
                        print(error!.localizedDescription)
                        self.errorWithMsg(message: "Error")
                        return
                    }else{
                        print("aff","elseSignUp")
                        Helper.userId = (authResult?.user.uid)!
                        let currentUser = (authResult?.user)!
                        print("user sign sucessfully ","user d id \(Helper.userId)  ",currentUser)
                        
                        Helper.dbRef.collection("userProfile").whereField("email", isEqualTo : self.appleEmail).getDocuments { [self] querySnapshot, err in
                            if  querySnapshot!.documents == [] {
                                self.hideIndicator()
                                SignUpWithApple(email:self.appleEmail, firstName:self.appleFname, lastName:self.appleLname)
                            } else {
                                for document in querySnapshot!.documents {
                                    let dict = document.data()
                                    Helper.userId = (dict["uid"] as? String ?? "")
                                    
                                    let auth = dict["authFrom"] as? String ?? ""
                                    if auth == "apple" {
                                        
                                        UserDefaults.standard.set(Helper.userId, forKey: "id")
                                        print(Helper.userId,"userId")
                                        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                                        Helper.dbRef.collection("userProfile").document( Helper.userId).updateData(["token":AppDelegate.token])
                                        
                                        self.hideIndicator()
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                                        vc!.modalPresentationStyle = .fullScreen
                                        self.present(vc!, animated: true, completion: nil)
                                    } else {
                                        self.hideIndicator()
                                    Toast.showToast(message: "This email is already in use", controller: self)
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        //MARK: SignUp With Apple -
        
        func SignUpWithApple(email:String,firstName:String,lastName:String) {
            
            Helper.userId = Auth.auth().currentUser!.uid
            print(Helper.userId,"Helper.userId")
            UserDefaults.standard.set(Helper.userId, forKey: "id")
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.synchronize()

            let para = ["about":"","address":"","authFrom":"apple","city":"","complete":true,"country":"","createdOn":NSDate.now,"dob":"","email":email,"fname":firstName,"gender":"","latlng":"","lname":lastName,"online":"","profileImg":"","token":"","typing":"noOne","uid":Helper.userId,"updatedOn":NSDate.now] as [String : Any]

            Helper.dbRef.collection("userProfile").document(Helper.userId).setData(para)

            Helper.dbRef.collection("userProfile").document( Helper.userId).updateData(["token":AppDelegate.token])
            
            self.hideIndicator()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileNavigation")
            vc!.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true, completion: nil)

        }

    }
