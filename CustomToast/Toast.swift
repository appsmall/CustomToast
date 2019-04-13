//
//  Toast.swift
//  CustomToast
//
//  Created by apple on 28/03/19.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class Toast: NSObject {
    
    private static let shared = Toast()
    
    static func sharedInstance() -> Toast {
        return shared
    }
    
    
    lazy private var contentView : UIView = {
        let view = UIView()
        view.backgroundColor = cardViewColor ?? UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1.0)
        return view
    }()
    
    private let font = UIFont(name: "Futura", size: 15)
    
    lazy private var messageLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = textFont ?? font
        label.textAlignment = .center
        label.textColor = textColor ?? UIColor.white
        label.backgroundColor = UIColor.clear
        label.text = stringText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // This view is the overlay view comes into effect when user open the filter screen.
    private var overlay : UIView?
    private var bottomConstraint: NSLayoutConstraint!
    private var stringHeight: CGFloat!
    
    // Stored Values (which comes from the main controller)
    private var viewController: UIViewController?
    private var overlayColor: UIColor?
    private var cardViewColor: UIColor?
    private var textColor: UIColor?
    private var stringText: String = ""
    private var textFont: UIFont?
    private var endTime: Float?
    
    private var completionHandler: ((Bool) -> ())!
    
   
    
    /* MARK:- CALLING METHOD
     METHOD DESC:
                1. This method is used to call from the main view controller class
     */
    func open(vc: UIViewController, text: String, endTime: Float?, overlayColor: UIColor?, cardViewColor: UIColor?, textColor: UIColor?, textFont: UIFont?, onCompletion: ((Bool) -> Void)? = nil) {
        self.viewController = vc
        self.overlayColor = overlayColor
        self.cardViewColor = cardViewColor
        self.textColor = textColor
        self.stringText = text
        self.textFont = textFont
        self.endTime = endTime
        
        messageLabel.text = text
        setupOverlayView(vc: vc, text: text)
        cornerView()
        
        if let onCompletion = onCompletion {
            self.completionHandler = onCompletion
        }
    }
    
    
    
    /*
     MARK:- MAIN METHODS
     METHOD DESC:
            1. Setup overlayView
            2. Setup Constraints of overlayView
     */
    fileprivate  func setupOverlayView(vc: UIViewController, text: String) {
        if let window = UIApplication.shared.keyWindow {
            overlay = createOverlayViewForScreen()
            if let overlay = overlay{
                window.addSubview(overlay)
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let this = self else{
                        return
                    }
                    this.overlay!.alpha = this.overlay!.alpha > 0 ? 0 : 0.5
                    
                    this.setupContentView(vc, text)
                    this.viewController?.view.layoutIfNeeded()
                    this.perform(#selector(this.showToastViewWithAnimation), with: nil, afterDelay: 0.0)
                }
            }
        }
    }
    
    fileprivate func createOverlayViewForScreen() -> UIView?{
        if let mainWindow = UIApplication.shared.keyWindow {
            let backgroundView = UIView(frame: mainWindow.frame)
            backgroundView.center = mainWindow.center
            backgroundView.alpha = 0
            backgroundView.backgroundColor = overlayColor ?? UIColor.black
            return backgroundView
        }
        return nil
    }
    
    /*
        METHOD DESC:
                1. This method is used to setup the ContentView and MessageLabel
                2. Setup Constraints of ContentView and MessageLabel
    */
    fileprivate func setupContentView(_ vc: UIViewController, _ text: String) {
        overlay!.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20).isActive = true
        contentView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20).isActive = true
        
        contentView.addSubview(messageLabel)
        messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        let width: CGFloat = vc.view.frame.width - 40 - 20
        stringHeight = calculateEstimatedHeight(width: width, text: text) + 32
        contentView.heightAnchor.constraint(equalToConstant: stringHeight).isActive = true
        
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: stringHeight)
        bottomConstraint.isActive = true
    }
    
    
    /*
     METHOD DESC :
            1. If the user set value into "endTime" variable, then call the 'hideToastViewWithAnimation' method after delay (set "endTime" value into delay).
            2. If the user set "Nil" value into "endTime" variable, then use the static value "5.0 sec" time into delay.
     */
    @objc fileprivate func showToastViewWithAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: { [unowned self] in
            self.bottomConstraint.constant = -20
            self.overlay?.layoutIfNeeded()
        }, completion: { [unowned self] (_) in
            
            if let endTime = self.endTime {
                self.perform(#selector(self.hideToastViewWithAnimation), with: nil, afterDelay: TimeInterval(endTime))
            }
            else {
                self.perform(#selector(self.hideToastViewWithAnimation), with: nil, afterDelay: TimeInterval(5.0))
            }
        })
    }
    
    
    /*
        METHOD DESC :
                1. This method is used to hide the ToastView
                2. Update bottom constraint of contentView
                3. Set overlayView alpha to 0.0
                4. Remove overlayView from superview
     */
    @objc fileprivate func hideToastViewWithAnimation(viewController: Any) {
        self.bottomConstraint.constant = self.stringHeight + 20
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: { [unowned self] in
            self.overlay?.layoutIfNeeded()
            self.overlay?.alpha = 0.0
            }, completion: { [unowned self] (_) in
                UIView.animate(withDuration: 0.2, animations: { [unowned self] in
                    
                    if let completionHandler = self.completionHandler {
                        // If the user uses open() with completionHandler, then entered into this condition. Otherwise, do nothing.
                        completionHandler(true)
                    }
                    
                    }, completion: { [unowned self] (_) in
                        self.removeViews()
                })
        })
    }
    
    /*
     METHOD DESC :
            1. Remove views from the superview
            2. Set views objects to nil
     */
    fileprivate func removeViews() {
        self.overlay?.removeFromSuperview()
        self.overlay = nil
    }
}


// MARK:- EXTERNAL USAGE METHODS
extension Toast {
    // This method is used to corner the view
    fileprivate func cornerView() {
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
    }
    
    // This method is used to calculate the height of the UILabel by calculating with text string, UILabel.Constraints and the font size of UILabel.
    fileprivate func calculateEstimatedHeight(width: CGFloat, text:String) -> CGFloat{
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attribute = [NSAttributedString.Key.font: font]
        let estimatedHeight = NSString(string: text).boundingRect(with: size, options: options, attributes: attribute as [NSAttributedString.Key : Any], context: nil)
        return estimatedHeight.height
    }
}
