//
//  Indicator.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import Foundation
import iProgressHUD



// MARK: - Activity Indicator Extension

extension UIViewController {
   
   static let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    func showIndicator(caption: String = "Please wait") {
        UIViewController.customView.dismissProgress()
        let iprogress = iProgressHUD()
        iprogress.isShowModal = true
        iprogress.isShowCaption = true
        iprogress.boxColor = UIColor.white
        iprogress.alphaBox = 0.3
        iprogress.captionColor = .black
        iprogress.indicatorColor = .black
        iprogress.modalColor = .black
        iprogress.captionSize = 16
        iprogress.boxCorner = 20
        iprogress.iprogressStyle = .vertical
        iprogress.isTouchDismiss = false
        iprogress.indicatorSize = 40
        iprogress.captionDistance = 25
        iprogress.boxSize = 35
        iprogress.indicatorStyle = .ballScaleRippleMultiple
        iprogress.attachProgress(toViews: UIViewController.customView)
        UIViewController.customView.updateCaption(text: caption)
        UIViewController.customView.showProgress()
        UIApplication.shared.keyWindow?.addSubview(UIViewController.customView)
    }
    func hideIndicator() {
        UIViewController.customView.dismissProgress()
        UIViewController.customView.removeFromSuperview()
    }
    
    
    static let customView2 = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

    func ShowMiniIndicator() {
        let iprogress = iProgressHUD()
        iprogress.isShowModal = true
        iprogress.isTouchDismiss = false
        iprogress.boxSize = 28
        iprogress.isShowBox = false
        iprogress.isShowCaption = false
        iprogress.indicatorColor = .red
        iprogress.isBlurBox = false
        iprogress.boxColor = UIColor.black
        iprogress.indicatorStyle = .circleStrokeSpin
        iprogress.indicatorSize = 40
        iprogress.attachProgress(toViews: view)
        iprogress.attachProgress(toViews: UIViewController.customView2)
        UIViewController.customView2.showProgress()
        UIApplication.shared.keyWindow?.addSubview(UIViewController.customView2)
    }
    func hideMiniIndicator() {
        UIViewController.customView2.dismissProgress()
        UIViewController.customView2.removeFromSuperview()
    }

    func showAnimation(){
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        })
    }
    func removeAnimation(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        })
        {_ in
            self.view.removeFromSuperview()
        }
    }
    
    
    
    
}
