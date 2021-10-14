//
//  Spinner.swift
//  Spinner
//
//  Created by Allie Shuldman on 10/12/21.
//

import Foundation
import UIKit

class Spinner: UIActivityIndicatorView {
  override init(style: UIActivityIndicatorView.Style) {
    super.init(style: style)

    backgroundColor = UIColor(red: 0.0, green: 0.32, blue: 0.44, alpha: 1.0)
    color = .white
    layer.cornerRadius = 10
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
