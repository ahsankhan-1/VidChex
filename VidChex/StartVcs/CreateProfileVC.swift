//
//  CreateProfileVC.swift
//  VidChex
//
//  Created by M Hayat on 28/12/2022.
//

import UIKit
import iOSDropDown
import PMSuperButton
import FirebaseFirestore

class CreateProfileVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var profileimageView: UIImageView!
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var genderTF: DropDown!
    @IBOutlet weak var dateofBirthTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var addLocationView: UIView!
    @IBOutlet weak var AddLocationBtn: UIButton!
    @IBOutlet weak var aboutTF: UITextField!
    @IBOutlet weak var createBtn: PMSuperButton!
    
    var sentImage:UIImage?
    var imgUrl = ""
    
    var gender = ["Gender","Male","Female"]
    
    var phyAddPoints: GeoPoint?
    
    static var googleEmail = ""
    static var googleName = ""
    static var last = ""
    static var GoogleImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        UserDefaults.standard.set("1", forKey: "status")
       
        shadowtextField(textField: dateofBirthTF)
        shadowtextField(textField: countryTF)
        shadowtextField(textField: cityTF)
        shadowtextField(textField: addressTF)
        shadowtextField(textField: aboutTF)
        createBtn.layer.cornerRadius = 7
        mainView.layer.cornerRadius = mainView.layer.frame.height/2
        mainView.layer
            .borderWidth = 1
        mainView.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.6196078431, blue: 0.5019607843, alpha: 1)
        profileimageView.layer.cornerRadius = profileimageView.layer
            .frame.height/2
        
        countryTF.isUserInteractionEnabled = false
        cityTF.isUserInteractionEnabled = false
        
        genderTF.backgroundColor = .white
        genderTF.font = .systemFont(ofSize: 14)
        genderTF.textColor = .black
        genderTF.layer.cornerRadius = genderTF.layer.frame.height/2
        genderTF.layer.borderWidth = 0.0
        genderTF.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        genderTF.layer.shadowOpacity = 0.3
        genderTF.layer.shadowRadius = 2.5
        genderTF.layer.shadowOffset = CGSize(width: 0, height: 1)
        genderTF.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        let leftpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 16))
        genderTF.leftView = leftpaddingView
        genderTF.leftViewMode = .always
        genderTF.rightViewMode = .always
        
        
        let datepicker = UIDatePicker()
        datepicker.datePickerMode = .date
        datepicker.addTarget(self, action: #selector(dateChange(datepicker:)), for: UIControl.Event.valueChanged)
        datepicker.frame.size = CGSize(width: 0, height: 300)
        datepicker.preferredDatePickerStyle = .wheels
        datepicker.maximumDate = Date()
        dateofBirthTF.inputView = datepicker
        
        
        let locationGesture = UITapGestureRecognizer()
        locationGesture.addTarget(self, action: #selector(goSearchLocationVC))
        addLocationView.isUserInteractionEnabled = true
        addLocationView.addGestureRecognizer(locationGesture)
        
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(changeProfileImg))
        imagePicker.isUserInteractionEnabled = true
        imagePicker.addGestureRecognizer(tapGesture)
        
        self.genderTF.optionArray = self.gender
        self.genderTF.didSelect{(selectedText , index ,id) in
            self.genderTF.text = selectedText
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addressTF.text = Helper.userAdd
        cityTF.text = Helper.userCity
        countryTF.text = Helper.userCountry
        
    }
    
    @objc func dateChange(datepicker: UIDatePicker) {
        dateofBirthTF.text = FormatDate(date: datepicker.date)
    }
    func FormatDate(date: Date) ->  String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    @objc func goSearchLocationVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GooglemapVC") as! GooglemapVC
        vc.ViewController = "Navigate"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func changeProfileImg(){
        self.getImage(fromSourceType: .photoLibrary)
       // self.showAlert()
    }
    
    @IBAction func createAction(_ sender: Any) {
        
        let gender = genderTF.text
        let dateofbirth = dateofBirthTF.text
        let location = addressTF.text
        let city = cityTF.text
        let country = countryTF.text
        let disc = aboutTF.text
        
        if genderTF.text == "" {
            errorWithMsg(message: "Please Select Gender")
        } else if dateofBirthTF.text == "" {
            errorWithMsg(message: "Please Enter Date Of Birth")
        } else if addressTF.text == "" {
            errorWithMsg(message: "Please Enter Location")
        } else if dateofBirthTF.text == "" {
            errorWithMsg(message: "Please Enter Date Of Birth")
        } else if aboutTF.text == "" {
            errorWithMsg(message: "Please Enter Discreption")
        }else if sentImage == nil{
            errorWithMsg(message: "Select image")
        }else {
            
            let latitude = Helper.userLat
            let longitude = Helper.userLong
            self.phyAddPoints = GeoPoint(latitude: latitude, longitude:  longitude)
            
            let para = ["about":disc!,"address":location!,"city":city!,"country":country!,"dob":dateofbirth!,"gender":gender!,"latlng":self.phyAddPoints!] as [String : Any]
            Helper.dbRef.collection("userProfile").document(Helper.userId).updateData(para as [AnyHashable : Any])
            
            uploadImage()
            
        }
    }
    
    func uploadImage (){
        
        self.showIndicator(caption: "Uploading...")
        let data = self.sentImage!.jpegData(compressionQuality: 20.0)
        let chatRef = Helper.storRef.child("VenueImages/\(Date().millisecondsSince1970)")
        let uploadTask = chatRef.putData(data!, metadata: nil) { mataData, error in
            guard mataData != nil else {
                print(error!)
                self.hideIndicator()
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
                print(imgUrl,"imgUrl")
                
                let para = ["profileImg":imgUrl]
                Helper.dbRef.collection("userProfile").document(Helper.userId).updateData(para as [AnyHashable : Any])
                self.hideIndicator()
                
                let vc = self.storyboard?.instantiateViewController(identifier:"TabBarVC")
                vc?.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
                
            }
        }
        uploadTask.observe(.progress) { snapshot in
            print(snapshot.progress as Any)
        }
    }
}

// MARK: - Image Picker

extension CreateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showAlert() {
        let alert = UIAlertController(title: "Image Selection", message: "From where pick image", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: { (action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
            self.sentImage = image
            self.profileimageView.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
