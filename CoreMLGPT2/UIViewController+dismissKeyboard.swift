//
//  ViewController+dismissKeyboard.swift
//  CoreMLGPT2
//
//  Created by Ker Lee Yap on 7/22/23.
//  From https://medium.com/@vvishwakarma/dismiss-hide-keyboard-when-touching-outside-of-uitextfield-swift-166d9d1efb68
//

import Foundation
import UIKit

extension UIViewController {
func dismissKeyboard() {
       let tap: UITapGestureRecognizer = UITapGestureRecognizer( target:     self, action:    #selector(UIViewController.dismissKeyboardTouchOutside))
       tap.cancelsTouchesInView = false
       view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
       view.endEditing(true)
    }
}
