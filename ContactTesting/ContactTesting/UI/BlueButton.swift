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

    backgroundColor = Colors.lightBlue
    titleLabel?.textAlignment = .center
    setTitleColor(Colors.darkBlue, for: .normal)
    setTitleColor(.gray, for: .highlighted)
    layer.cornerRadius = UIConstants.cornerRadius
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
