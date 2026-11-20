//
//  AppDelegate.swift
//  VidChex
//
//  Created by M Hayat on 11/10/2022.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import IQKeyboardManagerSwift
import PayPalCheckout
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    static var token = ""
    static var isNotification:Bool?
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        GMSServices.provideAPIKey("AIzaSyCENh_345PjNp1qXCRoSsColEiw1OEYm_E")
        GMSPlacesClient.provideAPIKey("AIzaSyCjxRhtdw74nJ9YdYaGjvY5IZUEA5Ux0JA")
        
        IQKeyboardManager.shared.enable = true
                
        let config = CheckoutConfig(
            clientID:"Af5g1pYqZiu_0eLqLSsnhqIZqOMS77ILtzK4oEx1dRW2Rs2_dJXTD0XnKOqgJqEgY4b4bsHGsMKtbQg3",
            returnUrl:"ideaLogics.VidChex://paypalpay".lowercased(),
            environment:.sandbox
        )
        Checkout.set(config: config)
        
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
                
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: - Get Topic notification
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if fcmToken != nil{
           // print("fcm token",fcmToken)
            AppDelegate.token = fcmToken!
            Helper.userId = UserDefaults.standard.string(forKey: "id") ?? ""
            if Helper.userId != "" {
                Helper.dbRef.collection("userProfile").document(Helper.userId).updateData(["token":fcmToken!])
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        AppDelegate.isNotification = true
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC {
            if let window = self.window, let rootViewController = window.rootViewController {
                var currentController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }
                currentController.present(controller, animated: true, completion: nil)
            }
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        AppDelegate.isNotification = true
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC {
            if let window = self.window, let rootViewController = window.rootViewController {
                var currentController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }
                currentController.present(controller, animated: true, completion: nil)
            }
        }
        completionHandler(.alert)
    }
}

