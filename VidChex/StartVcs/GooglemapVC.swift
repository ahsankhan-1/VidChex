//
//  GooglemapVC.swift
//  VidChex
//
//  Created by M Hayat on 28/12/2022.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import FirebaseFirestore
import CoreLocation

class GooglemapVC: UIViewController,GMSMapViewDelegate {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searckTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    var fromBack = true
    let marker = GMSMarker()
    var fromBusinessInfo = ""
    var thisLat = 0.0
    var thisLong = 0.0
    var thisAdd = ""
    var thiscity = ""
    var thisRating = ""
    var Country = ""
    var lat = 0.0
    var long = 0.0
    var ViewController = ""
    
    var receiverId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        saveBtn.layer.cornerRadius = saveBtn.layer.frame.height/2
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        
        TextFieldDesign(textfield: searckTF)
        
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        mapView.addSubview(saveBtn)
    
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func locationTaped(_ sender: Any) {
        gotoPlaces()
        
    }
    func gotoPlaces() {
        searckTF.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    @IBAction func SaveAction(_ sender: Any) {
        
        if searckTF.text == "" {
            Toast.showToast(message: "Please search location first", controller: self)
        }else {
            Helper.userAdd = thisAdd
            Helper.userLat = thisLat
            Helper.userLong = thisLong
            Helper.userCity = thiscity
            Helper.userCountry = Country
            self.navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - Extension Map
extension GooglemapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.thisLat = locValue.latitude
        self.thisLong = locValue.longitude
        print( self.thisLat,"userLat-------")
        print(self.thisLong,"userLong........")
        
        getAddressForLatLng(latitude:  self.thisLat, longitude: self.thisLong)
        
        guard let location = locations.first else {
            return
            
        }
         
        if fromBack == true || fromBusinessInfo == "true"{
            if Helper.userLat == 0.0 && Helper.userLong == 0.0{
                Helper.userLat = location.coordinate.latitude
                Helper.userLong = location.coordinate.longitude
                self.lat = Double(location.coordinate.latitude)
                self.long = Double(location.coordinate.longitude)
                
                print(Helper.userLat,"userLat")
                print(Helper.userLong,"userLong")
                print(self.lat,"lat")
                print(self.long,"long")
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                
            }else{
                marker.position = CLLocationCoordinate2D(latitude: Double(Helper.userLat) ?? location.coordinate.latitude, longitude: Double(Helper.userLong) ?? location.coordinate.longitude)
                let fancy = GMSCameraPosition.camera(withLatitude: Double(Helper.userLat) ?? 0,longitude: Double(Helper.userLong) ?? 0,zoom: 15,bearing: 0,viewingAngle: 0)
                let markerImage = UIImage(named: "ResIcon-1")!
                let markerView = UIImageView(image: markerImage)
                marker.iconView = markerView
                mapView.camera = fancy
                marker.map = mapView
            }
            
        }else{
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func getAddressForLatLng(latitude: Double, longitude: Double)  {
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=AIzaSyCjxRhtdw74nJ9YdYaGjvY5IZUEA5Ux0JA")//Here pass your latitude, longitude
        print(url!)
        let data = NSData(contentsOf: url! as URL)
        
        if data != nil {
            let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            print(json)
            
            let status = json["status"] as! String
            if status == "OK" {
                
                if let result = json["results"] as? NSArray   {
                    if result.count > 0 {
                        if let addresss:NSDictionary = result[0] as? NSDictionary {
                            let add =  addresss["formatted_address"] as! String
//                            thisAdd = add
//                            print(thisAdd,"thisAdd")
                            if add != "" {
                            if let address = addresss["address_components"] as? NSArray {
                                    var newaddress = ""
                                    var number = ""
                                    var street = ""
                                    var city = ""
                                    var state = ""
                                    var zip = ""
                                    var country = ""
                                    
                                    if(address.count > 0) {
                                        number =  (address.object(at: 1) as! NSDictionary)["short_name"] as! String
                                        print(number,"number")
                                    }
                                    if(address.count > 1) {
                                        street = (address.object(at: 2) as! NSDictionary)["short_name"] as! String
                                        print(street,"street")
                                    }
                                    if(address.count > 2) {
                                        city = (address.object(at: 3) as! NSDictionary)["short_name"] as! String
                                        print(city,"city")
                                    }
                                    if(address.count > 3) {
                                        state = (address.object(at: 4) as! NSDictionary)["short_name"] as! String
                                        
                                        thiscity = state
                                        print(thiscity,"thiscity")
                                    }
                                    if(address.count > 4) {
                                        zip =  (address.object(at: 5) as! NSDictionary)["short_name"] as! String
                                        print(zip,"zip")
                                    }
                                    if(address.count > 5) {
                                        country =  (address.object(at: 6) as! NSDictionary)["long_name"] as! String
                                            self.Country = country
                                        print(self.Country,"Country")
                                    }
                                    newaddress = "\(number), \(street), \(city), \(state) \(zip), \(country)"
//                                    thisAdd = newaddress
                                    print(newaddress,"newaddress")
                                thisAdd = "\(state) \(zip), \(country)"
                                print(thisAdd,"thisAdd")
                                    
                                }
                                
                            }else{
                                print("No formatted address")
                            }
                        }
                    }
                }
            }else{
                print("No Address found!")
            }
        }
    }
}

extension GooglemapVC : GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        self.mapView.clear()
        let cord2D = CLLocationCoordinate2D(latitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude))
        let marker = GMSMarker()
        marker.position =  cord2D
        let markerImage = UIImage(named: "ResIcon-1")!
        let markerView = UIImageView(image: markerImage)
        marker.iconView = markerView
        marker.map = self.mapView
        self.mapView.camera = GMSCameraPosition(target: cord2D, zoom: 15, bearing: 0, viewingAngle: 0)
        
        
        let geoCoder = CLGeocoder()
                   let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                   geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
        
                       // Place details
                       var placeMark: CLPlacemark!
                       placeMark = placemarks?[0]
        
                       // City
                       if let city = placeMark.locality {
                           print(city,"city")
                           self.thiscity = city
                           print(self.thiscity,"thiscity")
                       }
                       
                       // Country
                       if let country = placeMark.country {
                           print(country,"country")
                           self.Country = country
                           print(self.Country,"Country")
        
                       }
                       if placeMark.name == placeMark.locality{
                           self.searckTF.text = "\(placeMark.locality ?? "")" + "," + (placeMark.administrativeArea ?? "") + "," + (placeMark.country ?? "")
                       } else{
                       self.searckTF.text = "\(placeMark.name ?? "")" + "," + "\(placeMark.locality ?? "")" + "," + (placeMark.administrativeArea ?? "") + "," + (placeMark.country ?? "")
                       }
                   })
        
        
        thisAdd = place.formattedAddress!
        thisLat = place.coordinate.latitude
        thisLong = place.coordinate.longitude
        
        print(thisAdd,"thisAdd......")
        print(thisLat,"thisLat")
        print(thisLong,"thisLong")
        
        
        }
      
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
        
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
