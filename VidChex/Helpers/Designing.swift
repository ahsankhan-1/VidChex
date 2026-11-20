//
//  Designing.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseFirestore
import Lottie
import iProgressHUD

let animationView = LottieAnimationView(name: "loadiing")
var animationViewForData = LottieAnimationView()
let detailLbl = UILabel(frame: CGRect(x: 0, y: 130, width: 150, height: 20))

func TextFieldDesign(textfield: UITextField) {
    textfield.layer.cornerRadius = 3
  //  textfield.layer.borderWidth = 1
  //  textfield.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    textfield.tintColor = #colorLiteral(red: 0, green: 0.7803921569, blue: 0.7450980392, alpha: 0.5045648032)

    let leftpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 16))
    textfield.leftView = leftpaddingView
    textfield.leftViewMode = .always
    let rightpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
    textfield.rightView = rightpaddingView
    textfield.rightViewMode = .always
    
}

func BackGroundViewtableCell(backGroundView: UIView) {
    
   backGroundView.layer.cornerRadius = 7
   backGroundView.layer.shadowOpacity = 0.5
   backGroundView.layer.shadowRadius = 2.0
   backGroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
   backGroundView.layer.shadowOffset = CGSize(width: 0.0, height: 1)
   backGroundView.layer.masksToBounds = false
    
}

func shadowtextField(textField: UITextField){
   
    textField.backgroundColor = .white
    textField.font = .systemFont(ofSize: 14)
    textField.textColor = .black
    textField.layer.cornerRadius = textField.layer.frame.height/2
    textField.layer.borderWidth = 0.0
    textField.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    textField.layer.shadowOpacity = 0.3
    textField.layer.shadowRadius = 2.5
    textField.layer.shadowOffset = CGSize(width: 0, height: 1)
    textField.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    let leftpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 16))
    textField.leftView = leftpaddingView
    textField.leftViewMode = .always
    let rightpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
    textField.rightView = rightpaddingView
    textField.rightViewMode = .always
         
}

func shadowtextFieldRightPadding(textField: UITextField){
   
    textField.backgroundColor = .white
    textField.font = .systemFont(ofSize: 14)
    textField.textColor = .black
    textField.layer.cornerRadius = textField.layer.frame.height/2
    textField.layer.borderWidth = 0.0
    textField.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    textField.layer.shadowOpacity = 0.3
    textField.layer.shadowRadius = 2.5
    textField.layer.shadowOffset = CGSize(width: 0, height: 1)
    textField.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    let leftpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 16))
    textField.leftView = leftpaddingView
    textField.leftViewMode = .always
    let rightpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
    textField.rightView = rightpaddingView
    textField.rightViewMode = .always
         
}

func BackGroundView(backGroundView: UIView) {
    
    backGroundView.layer.cornerRadius = 10
    backGroundView.layer.shadowOpacity = 1.0
    backGroundView.layer.shadowRadius = 8
    backGroundView.layer.shadowColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.9176470588, alpha: 0.7614513675)
    backGroundView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    backGroundView.layer.masksToBounds = false
    
}

func ShadowTextView(textView: UITextView) {
    
    textView.layer.cornerRadius = 5
    textView.layer.shadowOpacity = 0.5
    textView.layer.shadowRadius = 2
    textView.layer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.9013565771)
    textView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    textView.layer.masksToBounds = false
    
}


func showNoData(table:UITableView,deatilText:String = "no Data found",animationName:String = "noData") {
    animationViewForData.translatesAutoresizingMaskIntoConstraints = false
    animationViewForData = .init(name:animationName)
    animationViewForData.loopMode = .loop
    animationViewForData.play()
    detailLbl.font = UIFont.systemFont(ofSize: 17.0)
    detailLbl.text = deatilText
    detailLbl.textAlignment = .center
    detailLbl.translatesAutoresizingMaskIntoConstraints = false
    table.addSubview(detailLbl)
    table.addSubview(animationViewForData)
    
    table.addConstraint(NSLayoutConstraint(item: animationViewForData, attribute: .centerX, relatedBy: .equal, toItem: table, attribute: .centerX, multiplier: 1.0, constant: 1))
    table.addConstraint(NSLayoutConstraint(item: animationViewForData, attribute: .centerY, relatedBy: .equal, toItem: table, attribute: .centerY, multiplier: 0.8, constant: 1))
    animationViewForData.addConstraint(NSLayoutConstraint(item: animationViewForData, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120))
    animationViewForData.addConstraint(NSLayoutConstraint(item: animationViewForData, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120))
    
    table.addConstraint(NSLayoutConstraint(item: detailLbl, attribute: .centerX, relatedBy: .equal, toItem: table, attribute: .centerX, multiplier: 1.0, constant: 1))
    table.addConstraint(NSLayoutConstraint(item: detailLbl, attribute: .centerY, relatedBy: .equal, toItem: table, attribute: .centerY, multiplier: 1.0, constant: 1))
    detailLbl.addConstraint(NSLayoutConstraint(item: detailLbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 180))
    detailLbl.addConstraint(NSLayoutConstraint(item: detailLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 180))
}

func removeNoData() {
    animationViewForData.stop()
    animationViewForData.removeFromSuperview()
    detailLbl.removeFromSuperview()
}

func generateRandomDigits(_ digitNumber: Int) -> String {
        var number = ""
        for i in 0..<digitNumber {
            var randomNumber = arc4random_uniform(10)
            while randomNumber == 0 && i == 0 {
                randomNumber = arc4random_uniform(10)
            }
            number += "\(randomNumber)"
            print(number,"number")
            print(randomNumber,"randomNumber")
        }
        return number
    }
