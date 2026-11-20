//
//  SelectedCategoriDetailVC.swift
//  VidChex
//
//  Created by M Hayat on 13/10/2022.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import CoreLocation

class SelectedCategoriDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var CategoriTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filterBuildingsDic:[NSDictionary] = []
  
    var Title = ""
    var price = 0
    var filterCount = 0
    
    var searchingDic:[NSDictionary] = []
    var searching = false
    var DistanceKm = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        self.title = "Houses"
        tabBarController?.tabBar.isHidden = true
        TabBarVC.button.isHidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        Helper.filtration = ""
        
        searchBar.delegate = self
        CategoriTableView.delegate = self
        CategoriTableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Helper.filtration == "1" {
            filterData()
        }
    }
    
    @IBAction func filterBtnAction(_ sender: Any) {
        
    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as? FilterVC  {
            if let sheet = vc.sheetPresentationController {
                //  sheet.detents = [.medium() ]
                if #available(iOS 16.0, *) {
                    sheet.detents = [
                        .custom { _ in
                            return 570
                        }
                    ]
                    vc.sheetPresentationController?.preferredCornerRadius = 30
                } else {
                    sheet.detents = [.large() ]                }
                vc.sheetPresentationController?.preferredCornerRadius = 30
            }
        vc.delegate = self
            self.present(vc , animated: true)
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if searching == true {
            return searchingDic.count
        }else if Helper.filtration == "1" {
            return self.filterBuildingsDic.count
        } else {
            return  HomeVC.allBuildingsDic.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = CategoriTableView.dequeueReusableCell(withIdentifier: "CategoridetailTVCell", for: indexPath) as! CategoridetailTVCell
        
        if searching == true {
            cell.nameLbl.text = self.searchingDic[indexPath.row]["title"] as? String ?? ""
            cell.aboutLbl.text = self.searchingDic[indexPath.row]["location"] as? String ?? ""
            cell.priceLbl.text = "$" + "" + String(self.searchingDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"

            let imageUrl = self.searchingDic[indexPath.row]["videos"] as? [String]

            let video = URL(string: imageUrl![0])
            cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
            
        } else if Helper.filtration == "1" {
            cell.nameLbl.text = self.filterBuildingsDic[indexPath.row]["title"] as? String ?? ""
            cell.aboutLbl.text = self.filterBuildingsDic[indexPath.row]["location"] as? String ?? ""
            cell.priceLbl.text = "$" + "" + String(self.filterBuildingsDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
            let imageUrl = self.filterBuildingsDic[indexPath.row]["videos"] as? [String]
            let video = URL(string: imageUrl![0])
            cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
            
        } else {
            cell.nameLbl.text = HomeVC.allBuildingsDic[indexPath.row]["title"] as? String ?? ""
            cell.aboutLbl.text = HomeVC.allBuildingsDic[indexPath.row]["location"] as? String ?? ""
            cell.priceLbl.text = "$" + "" + String(HomeVC.allBuildingsDic[indexPath.row]["price"] as? Int ?? 0) + "" + ".0"
            let imageUrl = HomeVC.allBuildingsDic[indexPath.row]["videos"] as? [String]
            let video = URL(string: imageUrl![0])
            cell.UserImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: video!, seconds: 5))
            
        }
       
        cell.UserImageView.layer.cornerRadius = 7
        BackGroundViewtableCell(backGroundView: cell.BackGroundView)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeDetailsVC") as! HomeDetailsVC
        
        if searching == true {
            vc.Userid = self.searchingDic[indexPath.row]["addedBy"] as? String ?? ""
            Helper.highestBidPrice = self.searchingDic[indexPath.row]["highestBid"] as? Int ?? 0
            Helper.buildingid = self.searchingDic[indexPath.row]["id"] as? String ?? ""
            
        } else if Helper.filtration == "1" {
            vc.Userid = self.filterBuildingsDic[indexPath.row]["addedBy"] as? String ?? ""
            Helper.highestBidPrice = self.filterBuildingsDic[indexPath.row]["highestBid"] as? Int ?? 0
            Helper.buildingid = self.filterBuildingsDic[indexPath.row]["id"] as? String ?? ""
        } else {
            vc.Userid = HomeVC.allBuildingsDic[indexPath.row]["addedBy"] as? String ?? ""
            Helper.highestBidPrice = HomeVC.allBuildingsDic[indexPath.row]["highestBid"] as? Int ?? 0
            Helper.buildingid = HomeVC.allBuildingsDic[indexPath.row]["id"] as? String ?? ""
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func getMilliFromDate(dateFromDB:String,formate:String) -> Int64 {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = formate
        let date = dateFormatter.date(from:dateFromDB)
        let milli  = date!.millisecondsSince1970
        return milli
        
    }
}

//MARK: Filteration -

extension SelectedCategoriDetailVC : Category {
    
    func filterData() {
        
        self.price = Int(FilterVC.PriceUnder) ?? 0
        self.filterCount = FilterVC.FilterCount
//        print(price,"PriceUnder")
//        print(filterCount,"FilterCount")
        
        let latitude = Helper.userLat
        let longitude = Helper.userLong
        print(latitude,"latitude")
        print(longitude,"longitude")
        
        getAllBuildings()
    }

    //MARK: Get Posts -
    func getAllBuildings() {
        
        Helper.dbRef.collection("buildings").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retreiving snapshots \(error!)")
                return
            }
            self.filterBuildingsDic.removeAll()
            for document in snapshot.documents {
                let postTempDic = document.data() as NSDictionary
                if postTempDic["status"] as? Int ?? 0 == 1 {
                    let dbPrice = postTempDic["price"] as? Int ?? 0
                    //   print(dbPrice,"dbPrice")
                    //   print(self.price,"price")
                    let geoPoint = postTempDic["latlng"] as! GeoPoint
                    let latitude = geoPoint.latitude
                    let longitude = geoPoint.longitude
                    
                    let location1 = CLLocation(latitude: Helper.userLat, longitude: Helper.userLong)
                    let location2 = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
                    let distance = location1.distance(from: location2) / 1600
                    self.DistanceKm = Int(distance)
                //    print(self.DistanceKm,"DistanceKm")
                    
                    if self.DistanceKm <= 500 {
                        print(self.DistanceKm,"DistanceMilles")
                        if self.price > dbPrice {
                            if self.filterCount == 1 {
                                self.filterBuildingsDic.append(postTempDic)
                                removeNoData()
                                self.CategoriTableView.reloadData()
                            } else if self.filterCount == 2 {
                                self.filterBuildingsDic.append(postTempDic)
                                removeNoData()
                                self.CategoriTableView.reloadData()
                            } else if self.filterCount == 3 {
                                self.filterBuildingsDic.append(postTempDic)
                                self.filterBuildingsDic = self.filterBuildingsDic.sorted(by: {
                                    (e1: NSDictionary?, e2: NSDictionary?) -> Bool in
                                    return ((e2!.value(forKey: "price") as! Int)) > (e1!.value(forKey: "price") as! Int)
                                })
                                removeNoData()
                                self.CategoriTableView.reloadData()
                            } else if self.filterCount == 4 {
                                self.filterBuildingsDic.append(postTempDic)
                                self.filterBuildingsDic = self.filterBuildingsDic.sorted(by: {
                                    (e1: NSDictionary?, e2: NSDictionary?) -> Bool in
                                    return ((e2!.value(forKey: "price") as! Int)) < (e1!.value(forKey: "price") as! Int)
                                })
                                removeNoData()
                                self.CategoriTableView.reloadData()
                            }
                        } else {
                            if self.price > dbPrice {
                                if self.filterCount == 1 {
                                    self.filterBuildingsDic.append(postTempDic)
                                    removeNoData()
                                    self.CategoriTableView.reloadData()
                                } else if self.filterCount == 2 {
                                    self.filterBuildingsDic.append(postTempDic)
                                    removeNoData()
                                    self.CategoriTableView.reloadData()
                                } else if self.filterCount == 3 {
                                    self.filterBuildingsDic.append(postTempDic)
                                    self.filterBuildingsDic = self.filterBuildingsDic.sorted(by: {
                                        (e1: NSDictionary?, e2: NSDictionary?) -> Bool in
                                        return ((e2!.value(forKey: "price") as! Int)) > (e1!.value(forKey: "price") as! Int)
                                    })
                                    removeNoData()
                                    self.CategoriTableView.reloadData()
                                } else if self.filterCount == 4 {
                                    self.filterBuildingsDic.append(postTempDic)
                                    self.filterBuildingsDic = self.filterBuildingsDic.sorted(by: {
                                        (e1: NSDictionary?, e2: NSDictionary?) -> Bool in
                                        return ((e2!.value(forKey: "price") as! Int)) < (e1!.value(forKey: "price") as! Int)
                                    })
                                    removeNoData()
                                    self.CategoriTableView.reloadData()
                                }
                            }
                        }
                    } else {
                        print(self.DistanceKm,"DistanceMilles")
                        if self.filterBuildingsDic == [] {
                            self.CategoriTableView.reloadData()
                            self.hideIndicator()
                            showNoData(table: self.CategoriTableView,deatilText: "No Data Found",animationName: " ")
                        }
                            
                        }
                    }
                }
            }
            
            if self.filterBuildingsDic == [] {
                self.CategoriTableView.reloadData()
                self.hideIndicator()
                showNoData(table: self.CategoriTableView,deatilText: "No Data Found",animationName: " ")
            }
        }
    }
    
// MARK: - Search Extension

extension SelectedCategoriDetailVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(searchText: searchText)
    }
    func filterContent(searchText: String) {
        searchingDic = HomeVC.allBuildingsDic.filter { job in
            let jobTitle = (job["title"] as? String) ?? ""
            return (jobTitle.lowercased().contains(searchText.lowercased()))
        }
        if searchText == "" {
            searching = false
            self.searchingDic = []
            self.CategoriTableView.reloadData()
        } else {
            searching = true
        self.CategoriTableView.reloadData()
        }
    }
}



