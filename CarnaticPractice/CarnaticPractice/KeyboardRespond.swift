//
//  KeyboardRespond.swift
//  CarnaticPractice
//
//  Created by Vyas Narasimhan and Kaushik Narasimhan on 4/23/20.
//  Copyright © 2020 Vyas Narasimhan and Kaushik Narasimhan. All rights reserved.
//

import Foundation
import SwiftUI

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    var _center: NotificationCenter
    init(center: NotificationCenter = .default) {
        _center = center
        _center.addObserver(self, selector: #selector(keyboardShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _center.addObserver(self, selector: #selector(keyboardHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                withAnimation {
                   currentHeight = keyboardSize.height
                }
        }
    }
    @objc func keyboardHide(notification: Notification) {
        withAnimation {
           currentHeight = 0
        }
    }
}
