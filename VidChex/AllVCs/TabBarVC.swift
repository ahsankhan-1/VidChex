//
//  TabBarVC.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import UIKit


class TabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    
    static var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set("2", forKey: "status")
        
        addCenterButton()
        self.delegate = self
       
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//                let tabbarIndex = tabBarController.viewControllers!.firstIndex(of: viewController)!
//                if UserDefaults.standard.bool(forKey: "isUserLoggedIn") == false {
//                    if  tabbarIndex == 3{
//
//                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginPopVC") as! LoginPopVC
//                        vc.providesPresentationContextTransitionStyle = true
//                        vc.definesPresentationContext = true
//                        vc.modalPresentationStyle = .pageSheet
//                        vc.sheetPresentationController?.preferredCornerRadius = 40
//
//                        if let sheet = vc.sheetPresentationController {
//                            sheet.detents = [.medium()]
//                        }
//                        self.present(vc, animated: true, completion: nil)
//
//                        print("oooooooo")
//                        addCenterButton()
//                        return false
//                    } else {
//                        print("mmmmmm")
//                        return true
//                    }
//                }
//                return true
//            }
        
        func addCenterButton(){
        
            TabBarVC.button.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
            TabBarVC.button.setImage(UIImage(named: "plus"), for: .normal)
//            TabBarVC.button.setTitle("+", for: .normal)
//            TabBarVC.button.titleLabel?.font = UIFont(name: "Arial", size: 30)
            TabBarVC.button.backgroundColor = UIColor.AppGreen
        
            TabBarVC.button.layer.cornerRadius =  TabBarVC.button.layer.frame.height/2
            TabBarVC.button.layer.masksToBounds = true
            TabBarVC.button.layer.shadowOffset = CGSize(width: 0, height: 0.3)
            TabBarVC.button.layer.shadowColor = UIColor.darkGray.cgColor
            TabBarVC.button.layer.shadowRadius = 2.0
            TabBarVC.button.layer.shadowOpacity = 0.8
            
            let tap1 = UITapGestureRecognizer(target:self,action:#selector(self.centerButtonAction))
            TabBarVC.button.isUserInteractionEnabled = true
            TabBarVC.button.addGestureRecognizer(tap1)
            
            let size = CGFloat(60)
            view.addSubview(TabBarVC.button)
            
            let constraints = [
                TabBarVC.button.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
                TabBarVC.button.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: -15),
                TabBarVC.button.heightAnchor.constraint(equalToConstant: size),
                TabBarVC.button.widthAnchor.constraint(equalToConstant: size)
            ]
            for constraint in constraints {
                constraint.isActive = true
            }
            
            TabBarVC.button.layer.masksToBounds = false
            TabBarVC.button.translatesAutoresizingMaskIntoConstraints = false
            
           
         //   TabBarVC.button.display(self)
        }
        
        @objc func centerButtonAction(){
          
           
         //   if UserDefaults.standard.bool(forKey: "isUserLoggedIn") == true {
                self.tabBarController?.setTabBarVisible(visible: false, duration: 0.3, animated: true)
                if let navigation = self.viewControllers?[self.selectedIndex] as? UINavigationController {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                    if let chatViewController = storyboard.instantiateViewController(withIdentifier: "AddNewHouseVC") as? AddNewHouseVC {
                        navigation.pushViewController(chatViewController, animated: true)
                    }
                }
//            }
//            else{
//                Toast.show(message: "Please sign in first", controller: self)
//            }
        }
    }

    extension UITabBarController {
        func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
            if (tabBarIsVisible() == visible) {
                return }
            let frame = self.tabBar.frame
            let height = frame.size.height
            let offsetY = (visible ? -height : height)
            
            // animation
            UIViewPropertyAnimator(duration: duration, curve: .linear) {
                
                // self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
                self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
                self.view.setNeedsDisplay()
                self.view.layoutIfNeeded()
            }.startAnimation()
            
            if (visible){
                TabBarVC.button.isHidden = false
                
            }else{
                
                TabBarVC.button.isHidden = true
            }
        }
        
        func tabBarIsVisible() ->Bool {
            return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
        }
    }

    extension UITabBar {
    static func setTransparentTabbar() {
        print("teeba")
      UITabBar.appearance().backgroundImage = UIImage()
      UITabBar.appearance().shadowImage     = UIImage()
      UITabBar.appearance().clipsToBounds   = true
     }
    }

