//
//  ProgressBar.swift
//  ProgressBar
//
//  Created by Allie Shuldman on 10/22/21.
//

import UIKit

class ProgressBar: UIView {

  private let progressBar: UIProgressView = {
    let progressView = UIProgressView()
    progressView.backgroundColor = .lightGray
    progressView.tintColor = .progressBlue
    progressView.layer.cornerRadius = UIConstants.cornerRadius
    progressView.clipsToBounds = true
    return progressView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .white
    layer.borderWidth = 2
    layer.borderColor = UIColor(red: 0.0, green: 0.32, blue: 0.44, alpha: 1.0).cgColor
    layer.cornerRadius = UIConstants.cornerRadius

    addSubview(progressBar)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    progressBar.translatesAutoresizingMaskIntoConstraints = false
    progressBar.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    progressBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    progressBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75).isActive = true
    progressBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
  }

  func setProgress(_ amount: Float) {
    DispatchQueue.main.async {
      self.progressBar.progress = amount
    }
  }
}
