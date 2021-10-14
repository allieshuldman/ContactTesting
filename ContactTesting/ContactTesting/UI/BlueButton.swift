//
//  ImportantButton.swift
//  ImportantButton
//
//  Created by Allie Shuldman on 10/5/21.
//

import UIKit

class BlueButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)

    self.frame = frame

    backgroundColor = UIColor(red: 0.72, green: 0.92, blue: 1.0, alpha: 1.0)
    titleLabel?.textAlignment = .center
    setTitleColor(UIColor(red: 0.0, green: 0.32, blue: 0.44, alpha: 1.0), for: .normal)
    setTitleColor(.gray, for: .highlighted)
    layer.cornerRadius = Constants.cornerRadius
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
