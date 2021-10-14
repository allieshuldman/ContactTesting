//
//  PrettyButton.swift
//  PrettyButton
//
//  Created by Allie Shuldman on 10/4/21.
//

import UIKit

class GrayButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)

    self.frame = frame

    backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1.0)
    titleLabel?.textAlignment = .center
    setTitleColor(.darkGray, for: .normal)
    setTitleColor(.gray, for: .highlighted)
    layer.cornerRadius = Constants.cornerRadius
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
