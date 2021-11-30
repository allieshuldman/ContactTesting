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

    backgroundColor = .progressBlue
    color = .white
    layer.cornerRadius = 10
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
