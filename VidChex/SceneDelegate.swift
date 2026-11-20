//
//  SceneDelegate.swift
//  VidChex
//
//  Created by M Hayat on 11/10/2022.


import UIKit
import Firebase
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window.windowScene = windowScene
        
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") == true {
            if UserDefaults.standard.string(forKey: "status") == "0" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SigninNavigation") as? UIViewController else {
                    fatalError("Could not instantiate HomeVC!")
                }
                window.rootViewController = vc
                
            } else if UserDefaults.standard.string(forKey: "status") == "1" {
                
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileNavigation") as? UIViewController else {
                    fatalError("Could not instantiate HomeVC!")
                }
                window.rootViewController = vc
                
            } else if UserDefaults.standard.string(forKey: "status") == "2" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC") as? UIViewController  else {
                    fatalError("Could not instantiate HomeVC!")
                }
                window.rootViewController = vc
            }
        } else {
            //MARK: - if not logged in
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SigninNavigation") as? UIViewController else {
                fatalError("Could not instantiate HomeVC!")
            }
            window.rootViewController = vc
            
            
        }
        self.window = window
        window.makeKeyAndVisible()
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
     //   print("sceneWillEnterForeground")
        Helper.userId = UserDefaults.standard.string(forKey: "id") ?? ""
        if Helper.userId != "" {
            print(Helper.userId,"userId")
            let para = ["online":"online"]
            Firestore.firestore().collection("userProfile").document(Helper.userId).updateData(para)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        Helper.userId = UserDefaults.standard.string(forKey: "id") ?? ""
        let date1 = Date().millisecondsSince1970
        if Helper.userId != "" {
            let para = ["online":"\(date1)"]
            Firestore.firestore().collection("userProfile").document(Helper.userId).updateData(para)
            print("sceneDidEnterBackground")
        }
    }
}

