//
//  editProfileVC.swift
//  Junior At Work
//
//  Created by M Hayat on 14/04/2022.
//

import UIKit
import PMSuperButton
import SDWebImage
import FirebaseFirestore

class editProfileVC: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var FirstNameTF: UITextField!
    @IBOutlet weak var LastNameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var dateOfBirthTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var aboutTF: UITextField!
    @IBOutlet weak var saveBtn: PMSuperButton!
    
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var maleLbl: UILabel!
    @IBOutlet weak var femaleLbl: UILabel!
    @IBOutlet weak var othersLbl: UILabel!
    @IBOutlet weak var dateofbirthLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    
    var sentImage:UIImage?
    var imgUrl = ""
    var gender = ""
    var value = ""
    var userLat = ""
    var userlong = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

       hideKeyboardWhenTappedAround()
        
        self.title = "Edit Profile"
        
        
        TextFieldDesign(textfield: FirstNameTF)
        TextFieldDesign(textfield: LastNameTF)
        TextFieldDesign(textfield: emailTF)
        TextFieldDesign(textfield: dateOfBirthTF)
        TextFieldDesign(textfield: cityTF)
        TextFieldDesign(textfield: countryTF)
        TextFieldDesign(textfield: aboutTF)
        
        emailTF.isUserInteractionEnabled = false
       
        
        imagePickerView.layer.cornerRadius = imagePickerView.layer.frame.height/2
        imagePickerView.layer.borderWidth = 1
        imagePickerView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
       
        
//        if saveBtn.isSelected == false {
//        saveBtn.setTitle("edit".localized1(), for: .normal)
//        } else {
//            saveBtn.setTitle("Upload".localized1(), for: .normal)
//        }
        userImageView.layer.cornerRadius = userImageView.layer.frame.height/2
        saveBtn.layer.cornerRadius = 7
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        let imgUrl = Helper.userDic["profileImg"] as? String ?? ""
        userImageView.sd_setImage(with: URL(string: imgUrl),placeholderImage: UIImage(named: "profile"))
        FirstNameTF.text = Helper.userDic["fname"] as? String ?? ""
        LastNameTF.text = Helper.userDic["lname"] as? String ?? ""
        
        emailTF.text = Helper.userDic["email"] as? String ?? ""
        gender = Helper.userDic["gender"] as? String ?? ""
        print(gender,"gender")
        dateOfBirthTF.text = Helper.userDic["dob"] as? String ?? ""
        cityTF.text = Helper.userDic["city"] as? String ?? ""
        countryTF.text = Helper.userDic["country"] as? String ?? ""
        aboutTF.text = Helper.userDic["about"] as? String ?? ""
       
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(changeProfileImg))
        imagePickerView.isUserInteractionEnabled = true
        imagePickerView.addGestureRecognizer(tapGesture)
        
        let datepicker = UIDatePicker()
        datepicker.datePickerMode = .date
        datepicker.addTarget(self, action: #selector(dateChange(datepicker:)), for: UIControl.Event.valueChanged)
        datepicker.frame.size = CGSize(width: 0, height: 300)
        datepicker.preferredDatePickerStyle = .wheels
        dateOfBirthTF.inputView = datepicker

   //     maleBtn.isSelected = true
        if gender == "Male" {
            maleBtn.isSelected = true
            femaleBtn.isSelected = false


        }else if gender == "Female"  {

            femaleBtn.isSelected = true
            maleBtn.isSelected = false


        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        
    }
    
    @objc func changeProfileImg(){
//        if saveBtn.isSelected == false {
//            errorWithMsg(message: "Please click below button to make changes")
//        } else  {
           
            self.showAlert()
    //    }
    }
    @objc func dateChange(datepicker: UIDatePicker) {
        dateOfBirthTF.text = FormatDate(date: datepicker.date)
    }
    func FormatDate(date: Date) ->  String {
                let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    @IBAction func locatioBtnAction(_ sender: Any) {
        
//        if saveBtn.isSelected == false {
//            errorWithMsg(message: "Please click below button to make changes")
//        } else {
//            saveBtn.isSelected = true
//        let vc = storyboard?.instantiateViewController(withIdentifier: "GoogleMapVC") as! GoogleMapVC
//        navigationController?.pushViewController(vc, animated: true)
//        }
        
    }
    
    @IBAction func maleBtnaction(_ sender: Any) {
        if maleBtn.isSelected == false {
            self.gender = "Male"
            maleBtn.isSelected = true
            femaleBtn.isSelected = false
        }
    }
    
    @IBAction func femailBtnAction(_ sender: Any) {
        
        if femaleBtn.isSelected == false {
            self.gender = "Female"
            femaleBtn.isSelected = true
            maleBtn.isSelected = false
        }
    }

    @IBAction func uploadBtnAction(_ sender: Any) {

        let fname = FirstNameTF.text
        let lastname = LastNameTF.text
        let dateofbirth = dateOfBirthTF.text
        let city = cityTF.text
        let country = countryTF.text
        let disc = aboutTF.text

//            var phyAddPoints: GeoPoint?
//            let latitude = Helper.userLat
//            let longitude = Helper.userLong
//            phyAddPoints = GeoPoint(latitude: latitude, longitude:  longitude)

        let para = ["about":disc!,"city":city!,"country":country!,"dob":dateofbirth!,"gender":gender,"fname":fname!,"lname":lastname!] as [String : Any]
            Helper.dbRef.collection("userProfile").document(Helper.userId).updateData(para as [AnyHashable : Any])

            if self.value == "1" {
        uploadImage()
            } else {
                self.hideIndicator()
                self.navigationController?.popViewController(animated: true)

            }
    }
    
    func uploadImage (){
       
        self.showIndicator(caption: "Uploading..")
            let data = self.sentImage!.jpegData(compressionQuality: 20.0)
            let chatRef = Helper.storRef.child("VenueImages/\(Date().millisecondsSince1970)")
            let uploadTask = chatRef.putData(data!, metadata: nil) { mataData, error in
                guard mataData != nil else {
                    print(error!)
                    return
                }
                let size = mataData?.size
                print(size as Any)
                chatRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        print(error as Any)
                        return
                    }
                    let imgUrl = String( downloadURL.absoluteString)
             //       print(imgUrl,"imgUrl")
                    
                    let para = ["profileImg":imgUrl]
                    
                    Helper.dbRef.collection("userProfile").document(Helper.userId).updateData(para as [AnyHashable : Any])
                    
                    self.hideIndicator()
                    self.navigationController?.popViewController(animated: true)

                    
                }
            }
        uploadTask.observe(.progress) { snapshot in
            print(snapshot.progress as Any)
            }
        }


}
// MARK: - Image Picker

extension editProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showAlert() {
        let alert = UIAlertController(title: "image selection", message: "from where pick image", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo album", style: .default, handler: { (action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            present(imagePickerController, animated: true, completion: nil)
        }
    }

    // MARK: - UIImagePickerViewDelegate.

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true) {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            self.value = "1"
            self.sentImage = image
            self.userImageView.image = image
            
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
