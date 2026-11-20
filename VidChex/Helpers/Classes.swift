//
//  Classes.swift
//  VidChex
//
//  Created by M Hayat on 12/10/2022.
//

import Foundation
import UIKit


class TextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 8)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
        
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
        
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
class UILabelPadding: UILabel {

    let padding = UIEdgeInsets(top: 16, left: 16, bottom: 25, right: 16)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }

}
class TimeLablePadding: UILabel {

    let padding = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }

}

class MyOwnTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
}

class MyOwnCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
//MARK: - TextView for sms Auto resize

class TextViewAutoHeight: UITextView {
    //MARK: attributes
    var  maxHeight:CGFloat?
    var  heightConstraint:NSLayoutConstraint?

    //MARK: initialize

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUpInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setUpConstraint()
    }

    //MARK: private

    private func setUpInit() {
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutConstraint.Attribute.height {
                self.heightConstraint = constraint as? NSLayoutConstraint
                break
            }
        }
    }

    private func setUpConstraint() {
        var finalContentSize:CGSize = self.contentSize
        finalContentSize.width  += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0
        finalContentSize.height += (self.textContainerInset.top  + self.textContainerInset.bottom) / 2.0

        fixTextViewHeigth(finalContentSize: finalContentSize)
    }

    private func fixTextViewHeigth(finalContentSize:CGSize) {
        if let maxHeight = self.maxHeight {
            var  customContentSize = finalContentSize;

            customContentSize.height = min(customContentSize.height, CGFloat(maxHeight))

            self.heightConstraint?.constant = customContentSize.height;

            if finalContentSize.height <= self.frame.height {
                let textViewHeight = (self.frame.height - self.contentSize.height * self.zoomScale)/2.0

                self.contentOffset = CGPoint(x: 0, y: -(textViewHeight < 0.0 ? 0.0 : textViewHeight))

            }
        }
    }
}

class Toast {
    
    static func showToast(message: String, controller: UIViewController) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.label
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 5
        toastContainer.clipsToBounds  =  true
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.systemBackground
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 2
        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 8)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -8)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -8)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 8)
        toastContainer.addConstraints([a1, a2, a3, a4])

        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
        controller.view.addConstraints([c1, c2, c3])

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}

class CustomSegmentedControl: UISegmentedControl{
    private let segmentInset: CGFloat = 5       //your inset amount
    private let segmentImage: UIImage? = UIImage(color: (UIColor.AppGreen ?? UIColor.AppGreen)!)    //your color

    override func layoutSubviews(){
        super.layoutSubviews()

        //background
        layer.cornerRadius = bounds.height/2
        //foreground
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView
        {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
            foregroundImageView.image = segmentImage    //substitute with our own colored image
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")    //this removes the weird scaling animation!
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height/2
        }
    }
}

extension UIImage{
    
    //creates a UIImage given a UIColor
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
