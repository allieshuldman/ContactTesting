//
//  EmptyHistoryVC.swift
//  EmptyHistoryVC
//
//  Created by Allie Shuldman on 11/19/21.
//

import Foundation

class EmptyHistoryVC: UIViewController {
  let label = BoldLabel(frame: .zero)

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
    label.text = "No Events"

    view.addSubview(label)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    label.sizeToFit()
    label.frame = CGRect(
      x: 0,
      y: (view.frame.maxY - label.frame.height) / 2.0,
      width: view.frame.width,
      height: label.frame.height
    )
    label.textAlignment = .center
  }
}
