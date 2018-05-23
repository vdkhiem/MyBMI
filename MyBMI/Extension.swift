//
//  Extension.swift
//  MyBMI
//
//  Created by Tran Quynh Tran on 23/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // This function allows to hide keypad to tap anywhere on screen
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
