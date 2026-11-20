//
//  Helper.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import FirebaseDatabase
import FirebaseStorage
import Foundation
import UIKit
import FirebaseFirestore
import Firebase

class Helper {
    
    static var dbRef =  Firestore.firestore()
    static var storRef = Storage.storage().reference()
    static var dbChatRef = Database.database().reference()
    static var dbChatStrRef = Storage.storage().reference()
    static var userId = ""
    static var userDic: NSDictionary = [:]
    static var PostType = ""
    static var CurrentBodyWeight = ""
    static var TypeofLift = ""
    static var WeightLifted = ""
    static var Reps = ""
    static var acctFrom = ""
    static var highestBid = 0
    static var filtration = ""
    static var buildingid = ""
    static var highestBidPrice = 0
    static var buildingtitle = ""
    static var highestBiderName = ""
    
    
    
    static var userLat = 0.0
    static var userLong = 0.0
    static var userAdd = ""
    static var userCity = ""
    static var userCountry = ""
    static var PlacesKey = "AIzaSyCjxRhtdw74nJ9YdYaGjvY5IZUEA5Ux0JA"
    static var UstrLanguage = ""
    
    static var ImageArrayOfUrls = [String]()
    static var VlogPPhotoArray = [UIImage]()
}

