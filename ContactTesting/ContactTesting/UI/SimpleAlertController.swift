//
//  UIAlertController.swift
//  UIAlertController
//
//  Created by Allie Shuldman on 10/21/21.
//

import UIKit

extension UIAlertController {
  convenience init(title: String) {
    self.init(title: title, message: nil, preferredStyle: .alert)
    addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
  }
}
