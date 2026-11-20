//
//  AddNewHouseVC.swift
//  VidChex
//
//  Created by M Hayat on 29/12/2022.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import iOSDropDown
import Photos
import FirebaseFirestore
import PhotosUI

class AddNewHouseVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource, PHPickerViewControllerDelegate {
    
    
    
    @IBOutlet weak var buildingTypeTF: DropDown!
    @IBOutlet weak var HomeCategoryTF: DropDown!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var enterRoomTF: UITextField!
    @IBOutlet weak var enterKitchenTF: UITextField!
    @IBOutlet weak var enterWashroomTF: UITextField!
    @IBOutlet weak var garageTF: DropDown!
    @IBOutlet weak var enterlocationTF: UITextField!
    @IBOutlet weak var SearchlocationView: UIView!
    
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var VideosCollectionView: UICollectionView!
    
    
    var category = ["Home","Apartment","Condo"]
    var type = ["Building"]
    var garage = ["Yes","No"]
    
    var controller = UIImagePickerController()
    let videoFileName = "/video.mp4"
    var sentImage : UIImage?
    var UrL:URL?
    var videoArray = [String]()
    var videoUrl = ""
    var check = ""
    var maxLen:Int = 8
    var garageCount = 0
    var phyAddPoints: GeoPoint?
    
    var VideoUrlArray :[String] = []
    var thumnailVid: [UIImage] = []
    var selectedVideos: [(URL, UIImage?)] = []
    let placeholderImage = UIImage(named: "house pic")
    var currentTime : Int64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VideosCollectionView.delegate = self
        VideosCollectionView.dataSource = self
        
        self.title = "Add New Building"
        publishBtn.layer.cornerRadius = 7
        self.tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        titleTF.keyboardType = .default
        priceTF.keyboardType = .numberPad
        enterRoomTF.keyboardType = .numberPad
        enterKitchenTF.keyboardType = .numberPad
        enterWashroomTF.keyboardType = .numberPad
        enterlocationTF.keyboardType = .default
        priceTF.delegate = self
        
        descTextView.delegate = self
        descTextView.text = "Write a caption..."
        descTextView.textColor = UIColor.lightGray
        descTextView.layer.cornerRadius = 5
        descTextView.layer.borderWidth = 0.3
        descTextView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.750824783)
        
        
        let tapGesture1 = UITapGestureRecognizer()
        tapGesture1.addTarget(self, action: #selector(searchLocation))
        SearchlocationView.isUserInteractionEnabled = true
        SearchlocationView.addGestureRecognizer(tapGesture1)
        
        self.buildingTypeTF.optionArray = self.type
        self.buildingTypeTF.didSelect { (selectedText , index ,id) in
            self.buildingTypeTF.text = selectedText
        }
        self.buildingTypeTF.optionArray = self.type
        self.buildingTypeTF.selectedIndex = 0
        self.buildingTypeTF.text = self.type[0]
        
        self.HomeCategoryTF.optionArray = self.category
        self.HomeCategoryTF.didSelect{(selectedText , index ,id) in
            self.HomeCategoryTF.text = selectedText
        }
        self.HomeCategoryTF.optionArray = self.category
        self.HomeCategoryTF.selectedIndex = 0
        self.HomeCategoryTF.text = self.category[0]
        
        self.garageTF.optionArray = self.garage
        self.garageTF.didSelect{(selectedText , index ,id) in
            self.garageTF.text = selectedText
            
        }
        self.garageTF.optionArray = self.garage
        self.garageTF.selectedIndex = 0
        self.garageTF.text = self.garage[0]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enterlocationTF.text = Helper.userAdd
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == self.priceTF){
            let currentText = textField.text! + string
            return currentText.count <= maxLen
        }
        
        return true;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = "Write a caption..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func searchLocation(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "GooglemapVC") as! GooglemapVC
        vc.ViewController = "Navigate"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func pickVideoBtn(_ sender: Any) {
        showAlert()
        
    }
    
    func showAlert() {
        
        let alert = UIAlertController(title: "Choose Source", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self] _ in
            self?.showMediaPicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.recordVideo()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func showMediaPicker() {
        var configuration = PHPickerConfiguration()
        let remainPic = 10 - self.selectedVideos.count
        configuration.selectionLimit = remainPic
        configuration.filter = .videos
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func recordVideo() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.videoQuality = .typeHigh // You can adjust the quality as needed
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    
    @IBAction func searchLocationAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GooglemapVC") as! GooglemapVC
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func publishBtnAction(_ sender: Any) {
        
        let type = self.buildingTypeTF.text
        let category = self.HomeCategoryTF.text
        let title = self.titleTF.text
        let price = self.priceTF.text
        let rooms = self.enterRoomTF.text
        let kitchen = self.enterKitchenTF.text
        let washroom = self.enterWashroomTF.text
        let garage = self.garageTF.text
        let location = self.enterlocationTF.text
        let desc = self.descTextView.text
        
        if title == "" {
            Toast.showToast(message: "Please give title", controller: self)
        } else if price == "" {
            Toast.showToast(message: "Please give price", controller: self)
        } else if rooms == "" {
            Toast.showToast(message: "Please add rooms", controller: self)
        } else if kitchen == "" {
            Toast.showToast(message: "Please add kitchens", controller: self)
        } else if washroom == "" {
            Toast.showToast(message: "Please add washrooms", controller: self)
        } else if location == "" {
            Toast.showToast(message: "Please add location", controller: self)
        } else if desc == "" {
            Toast.showToast(message: "Please add description", controller: self)
        } else if selectedVideos.isEmpty {
            Toast.showToast(message: "Please Add video", controller: self)
        } else {
            
            let videoURLs = getVideoURLsFromTuples(selectedVideos: selectedVideos)
                self.uploadVideos(videoURLs: videoURLs)
            
        }
    }
    func getVideoURLsFromTuples(selectedVideos: [(URL, UIImage?)]) -> [URL] {
        return selectedVideos.map { $0.0 }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { videoURL, error in
                    if let videoURL = videoURL as? URL {
                        self.hideIndicator()
                        print("videoURL", videoURL)
                        
                        if let thumbnail = self.generateThumbnailForVideo(at: videoURL) {
                            print("thumbnail", thumbnail)
                            self.selectedVideos.append((videoURL, thumbnail))
                        } else {
                            print("Failed to generate thumbnail for video.")
                            self.selectedVideos.append((videoURL, self.placeholderImage))
                        }
                        
                        DispatchQueue.main.async {
                            self.VideosCollectionView.reloadData()
                        }
                    } else if let error = error {
                        print("Error loading video: \(error)")
                    }
                }
            }
        }
    }
    
    func generateThumbnailForVideo(at videoURL: URL) -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        
        // Check if the asset can be loaded
        if !asset.isPlayable {
            print("The video is not playable.")
            return nil
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            // Handle the recorded video URL here
            print("Recorded video URL: \(videoURL)")
            if let thumbnail = self.generateThumbnailForVideo(at: videoURL) {
                print("thumbnail", thumbnail)
                self.selectedVideos.append((videoURL, thumbnail))
            } else {
                print("Failed to generate thumbnail for video.")
                self.selectedVideos.append((videoURL, self.placeholderImage))
            }
            
            DispatchQueue.main.async {
                self.VideosCollectionView.reloadData()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosCVCell", for: indexPath) as! VideosCVCell
        cell.VideoView.layer.cornerRadius = 7
        cell.crossBtn.layer.cornerRadius = cell.crossBtn.frame.height / 2
        cell.crossBtn.tag = indexPath.row
        let (_, thumbnail) = selectedVideos[indexPath.row]
        // Set the thumbnail image
        cell.VideoView.image = thumbnail
        
        cell.deleteAction = { [self] in
            selectedVideos.remove(at: cell.crossBtn.tag)
            DispatchQueue.main.async {
                self.VideosCollectionView.reloadData()
            }
        }
        
        return cell
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 1000.0, height: 1000.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
            
        })
        
        return thumbnail
    }
    
    func uploadVideos(videoURLs: [URL]) {
        
        self.showIndicator(caption: "Uploading...")
        var count2 = 0
        for videoURL in videoURLs {
            currentTime = Int64(NSDate().timeIntervalSince1970 * 1000)
            let data: Data
            do {
                data = try Data(contentsOf: videoURL)
                let videoSendData = Helper.storRef.child("videos/\(String(describing: self.currentTime)).mp4")
                videoSendData.putData(data, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                        print("Video uploading error")
                        self.hideIndicator()
                        Toast.showToast(message: "Video uploading error", controller: self)
                        return
                    }
                    // Get the download URL for the uploaded video
                    videoSendData.downloadURL { (url, error) in
                        guard let downloadUrl = url else {
                            self.hideIndicator()
                            Toast.showToast(message: "Video URL error", controller: self)
                            return
                        }
                        let videoUrl = downloadUrl.absoluteString
                        self.VideoUrlArray.append(videoUrl)
                        count2 = count2 + 1
                        if count2 == videoURLs.count {
                            self.Uploaddata()
                        }
                        self.hideIndicator()
                    }
                }
            } catch {
                print("Error converting videoURL to Data: \(error.localizedDescription)")
                self.hideIndicator()
                // Handle the error as needed
            }
        }
//        self.hideIndicator()
//        Toast.showToast(message: "Uploading Failed", controller: self)
    }
    
    func Uploaddata() {
                
        let type = self.buildingTypeTF.text
     //   let category = self.HomeCategoryTF.text
        let title = self.titleTF.text
        let price = Int(self.priceTF.text ?? "")
        let rooms = Int(self.enterRoomTF.text ?? "")
        let kitchen = Int(self.enterKitchenTF.text ?? "")
        let washroom = Int(self.enterWashroomTF.text!)
        let garage = self.garageTF.text ?? ""
        let location = self.enterlocationTF.text
        let desc = self.descTextView.text
        
        let ref = Helper.dbRef.collection("buildings")
        let postKey = ref.document().documentID
        
        if garage == "Yes" {
            self.garageCount = 1
        }else {
            self.garageCount = 0
        }
        
        let latitude = Helper.userLat
        let longitude = Helper.userLong
        self.phyAddPoints = GeoPoint(latitude: latitude, longitude:  longitude)
        
        let parametter = ["buildingId":"","createdOn":NSDate.now,"id":"","name":"","price":0,"uid":""] as [String : Any]
        
        let para = ["addedBy":Helper.userId,"approvedOn":nil,"bid":parametter,"buyerPaidOn":nil,"categoryId":"1","createdOn":NSDate.now,"desc":desc!,"garages":self .garageCount,"highestBid":0,"id":postKey,"kitchens":kitchen!,"location":location!,"latlng":self.phyAddPoints!,"price":price!,"rooms":rooms!,"sellerPaidOn":nil,"status":1,"title":title!,"type":type!,"updatedOn":NSDate.now,"videos":self.VideoUrlArray,"washrooms":washroom!] as [String : Any?]
        
        Helper.dbRef.collection("buildings").document(postKey).setData(para as [String : Any]){error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
               print("No Uploading")
                return
            }
            
            self.hideIndicator()
            Toast.showToast(message: "Video Upload Successfull", controller: self)
            HomeVC.buildingCount = 1
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
            vc!.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true, completion: nil)
            
        }
                
    }
        
 }
        
      
