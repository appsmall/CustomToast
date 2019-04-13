//
//  ViewController.swift
//  CustomToast
//
//  Created by apple on 28/03/19.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let demoText = "You are now connected with internet."

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func openToastBtnPressed(_ sender: UIButton) {
        /*Toast.sharedInstance().open(vc: self, text: demoText, endTime: 1.0, overlayColor: nil, cardViewColor: UIColor.green, textColor: nil, onCompletion: { (status) in
            print(status)
        })*/
        
        Toast.sharedInstance().open(vc: self, text: demoText, endTime: 2.0, overlayColor: nil, cardViewColor: UIColor.green, textColor: UIColor.black, textFont: nil)
        
    }
    
}

