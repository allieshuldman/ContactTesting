//
//  ImportantLabel.swift
//  ImportantLabel
//
//  Created by Allie Shuldman on 10/5/21.
//

import UIKit

class BoldLabel: UILabel {
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    font = .preferredFont(forTextStyle: .headline)
    numberOfLines = 0
    lineBreakMode = .byWordWrapping
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
