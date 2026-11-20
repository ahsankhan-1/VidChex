//
//  Extension.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import Foundation
import UIKit
import SDWebImage
import AVFoundation

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension UIViewController {
    func generateThumbnail(for videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 2, preferredTimescale: 60) // You can change the time as needed to capture the thumbnail
        do {
            let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: imageRef)
            completion(thumbnail)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            completion(nil)
        }
    }
}

// MARK: - Error Functions Extension

extension UIViewController {
    func errorWithMsg(message: String = "") {
        let alert = UIAlertController(title: "Sorry", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

    func errorWithTitleMsg(title: String = "Sorry", message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func backVCAlert(title:String = "Update Successful",message:String = ""){
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
      }))
        present(refreshAlert, animated: true, completion: nil)
    }
}

// MARK: - Date Extension

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleToFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension UIViewController{
    func timestampToStringAgo(timestamp: Int64) -> String{
        let actualTime = Int64(Date().timeIntervalSince1970*1000)
        var lastSeenTime = actualTime - timestamp
        lastSeenTime /= 1000 //seconds
        var lastTimeString = ""
        if lastSeenTime < 60 {
            if lastSeenTime == 10 {
                lastTimeString = "now"
            } else {
                lastTimeString = "now"
            }
        } else {
            lastSeenTime /= 60
            if lastSeenTime < 60 {
                if lastSeenTime == 1 {
                    lastTimeString =  String(lastSeenTime) + " mins ago"
                } else {
                    lastTimeString =  String(lastSeenTime) + " mins ago"
                }
            } else {
                lastSeenTime /= 60
                if lastSeenTime < 24 {
                    if lastSeenTime == 1 {
                        lastTimeString = String(lastSeenTime) + " hour ago"
                    } else {
                        lastTimeString = String(lastSeenTime) + " hours ago"
                    }
                } else {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM, d"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    lastTimeString = formatter.string(from: Date(milliseconds: timestamp))
                }
            }
        }
        return lastTimeString
    }
    
}

extension UIImageView {
    func ImageURL(_ url: String) {
        
        DispatchQueue.main.async {
            let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = .black
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = true
            
            activityIndicator.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
            self.addSubview(activityIndicator)
            
            self.sd_setImage(with: URL(string: url)) { (image, error, cacheType, url) in
                activityIndicator.stopAnimating()
            }
        }
    }
}


