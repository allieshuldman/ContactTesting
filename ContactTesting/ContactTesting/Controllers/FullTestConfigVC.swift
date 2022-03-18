//
//  FullTestConfigVC.swift
//  FullTestConfigVC
//
//  Created by Allie Shuldman on 12/8/21.
//

import Foundation
import UIKit

class FullTestConfigVC: UIViewController {
  let numberOfRoundsLabel = BoldLabel()
  let numberOfRoundsTextField = UITextField()

  let beginButton = BlueButton()

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Full Test"

    let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)

    view.backgroundColor = .white

    numberOfRoundsLabel.text = "Number of test rounds: "
    numberOfRoundsTextField.text = "5"
    numberOfRoundsTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    numberOfRoundsTextField.layer.cornerRadius = UIConstants.cornerRadius
    numberOfRoundsTextField.keyboardType = .numberPad
    numberOfRoundsTextField.textAlignment = .center

    beginButton.setTitle("Begin Test", for: .normal)
    beginButton.addTarget(self, action: #selector(beginTest), for: .touchUpInside)

    view.addSubview(numberOfRoundsLabel)
    view.addSubview(numberOfRoundsTextField)
    view.addSubview(beginButton)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    numberOfRoundsLabel.sizeToFit()
    numberOfRoundsLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: (navigationController?.navigationBar.frame.maxY ?? 0) + 30.0,
      width: numberOfRoundsLabel.frame.width,
      height: numberOfRoundsLabel.frame.height
    )

    numberOfRoundsTextField.frame = CGRect(
      x: numberOfRoundsLabel.frame.maxX + UIConstants.leftInset,
      y: numberOfRoundsLabel.frame.minY - (UIConstants.topSpacing / 2.0),
      width: view.frame.width - UIConstants.leftInset - numberOfRoundsLabel.frame.maxX - UIConstants.leftInset,
      height: numberOfRoundsLabel.frame.height + UIConstants.topSpacing
    )

    beginButton.frame = CGRect(
      x: UIConstants.leftInset,
      y: numberOfRoundsTextField.frame.maxY + UIConstants.topSpacing,
      width: view.frame.width - 2 * UIConstants.leftInset,
      height: UIConstants.buttonHeight
    )
  }

  @objc func hideKeyboard() {
    view.endEditing(true)
  }

  @objc func beginTest() {
    let rounds: Int = {
      if let text = numberOfRoundsTextField.text, let n = Int(text), n > 0 {
        return n
      }
      else {
        return 5
      }
    }()


    let vc = FullTestVC(rounds: rounds)
    navigationController?.pushViewController(vc, animated: true)
  }
}
