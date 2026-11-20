//
//  PushNotification.swift
//  Healthy ECO (Client App)
//
//  Created by Ahsan on 03/06/2021.
//

import UIKit

class PushNotificationSender {
    static func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body, "sound" : "sound"],
                                           "data" : ["user" : "test_id","title" : title, "body" : body]]
        print(paramString)
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAi0hPpvg:APA91bEjbmbMZScE_z5ue7t5Ac6vRKygaBBoveM0EIZSBRVjF8WsI6hkMsewE6fC-mJhLgadfwRgBiw2RnpzDe5rt_vcQOiRxiHojPGFapLZDAQVcSDmK085Ob8jsJb5DsKHkjVUv4R8", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        print("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription,"happing error")
            }
        }
        task.resume()
    }
}
