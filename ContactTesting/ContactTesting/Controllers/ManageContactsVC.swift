//
//  AddContactsVC.swift
//  AddContactsVC
//
//  Created by Allie Shuldman on 11/19/21.
//

import Foundation
import UIKit

class ManageContactsVC: UIViewController {
  let numberOfContactsInMemoryLabel = BoldLabel()
  let numberOfContactsInContainerLabel = BoldLabel()
  let numberOfContactsOnDeviceLabel = BoldLabel()
  let batchSizeLabel = BoldLabel()

  let batchSizeTextField = UITextField()

  let addContactsToDeviceButton = GrayButton()
  let deleteContactsFromDeviceButton = GrayButton()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.becomeFirstResponder()

    let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)

    view.backgroundColor = .white
    title = "Manage Contacts"
    setUpView()
  }

  func setUpView() {
    setUpLabels()

    addContactsToDeviceButton.setTitle("Add contacts to device", for: .normal)
    addContactsToDeviceButton.addTarget(self, action: #selector(didTapAddContactsToDevice), for: .touchUpInside)

    deleteContactsFromDeviceButton.setTitle("Delete contacts from device", for: .normal)
    deleteContactsFromDeviceButton.addTarget(self, action: #selector(didTapDeleteContacts), for: .touchUpInside)

    batchSizeTextField.text = "  \(PersistentDataController.shared.batchSize)"
    batchSizeTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    batchSizeTextField.layer.cornerRadius = UIConstants.cornerRadius
    batchSizeTextField.keyboardType = .numberPad

    view.addSubview(numberOfContactsInMemoryLabel)
    view.addSubview(numberOfContactsInContainerLabel)
    view.addSubview(numberOfContactsOnDeviceLabel)
    view.addSubview(batchSizeLabel)
    view.addSubview(batchSizeTextField)
    view.addSubview(addContactsToDeviceButton)
    view.addSubview(deleteContactsFromDeviceButton)
  }

  func setUpLabels() {
    numberOfContactsInMemoryLabel.text = "Number of contacts in memory: \(ContactListParser.shared.inMemoryContacts.count)"
    numberOfContactsInContainerLabel.text = "Number of contacts in container: \(ContactStoreManager.shared.getNumberOfTestContactsOnDevice())"
    numberOfContactsOnDeviceLabel.text = "Number of contacts on device: \(ContactStoreManager.shared.getNumberOfContactsOnDevice())"

    batchSizeLabel.text = "Add/delete batch size:"
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    numberOfContactsInMemoryLabel.sizeToFit()
    numberOfContactsInMemoryLabel.frame =  CGRect(
     x: UIConstants.leftInset,
     y: (navigationController?.navigationBar.frame.maxY ?? 0) + 10.0,
     width: view.frame.width - 2 * UIConstants.leftInset,
     height: numberOfContactsInMemoryLabel.frame.height
    )

    numberOfContactsInContainerLabel.sizeToFit()
    numberOfContactsInContainerLabel.frame =  CGRect(
     x: UIConstants.leftInset,
     y: numberOfContactsInMemoryLabel.frame.maxY + UIConstants.topSpacing,
     width: view.frame.width - 2 * UIConstants.leftInset,
     height: numberOfContactsInContainerLabel.frame.height
    )

    numberOfContactsOnDeviceLabel.sizeToFit()
    numberOfContactsOnDeviceLabel.frame =  CGRect(
     x: UIConstants.leftInset,
     y: numberOfContactsInContainerLabel.frame.maxY + UIConstants.topSpacing,
     width: view.frame.width - 2 * UIConstants.leftInset,
     height: numberOfContactsOnDeviceLabel.frame.height
    )

    batchSizeLabel.sizeToFit()
    batchSizeLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: numberOfContactsOnDeviceLabel.frame.maxY + UIConstants.topSpacing,
      width: batchSizeLabel.frame.width,
      height: batchSizeLabel.frame.height
    )

    batchSizeTextField.frame = CGRect(
      x: batchSizeLabel.frame.maxX + UIConstants.leftInset,
      y: batchSizeLabel.frame.minY - (UIConstants.topSpacing / 2.0),
      width: view.frame.width - UIConstants.leftInset - batchSizeLabel.frame.maxX - UIConstants.leftInset,
      height: batchSizeLabel.frame.height + UIConstants.topSpacing
    )

    addContactsToDeviceButton.frame = CGRect(
      x: UIConstants.leftInset,
      y: batchSizeLabel.frame.maxY + UIConstants.topSpacing,
      width: view.frame.width - 2 * UIConstants.leftInset,
      height: UIConstants.buttonHeight
    )

    deleteContactsFromDeviceButton.frame = CGRect(
      x: UIConstants.leftInset,
      y: addContactsToDeviceButton.frame.maxY + UIConstants.topSpacing,
      width: view.frame.width - 2 * UIConstants.leftInset,
      height: UIConstants.buttonHeight
    )
  }

  // MARK: Motion Handling

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if event?.subtype == .motionShake {
      let deleteAllPopup = UIAlertController(title: "Delete ALL Contacts from ALL Contianers?", message: "This will delete every possibe contact in your contact book", preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
        let spinner = Spinner(style: .large)

        DispatchQueue.main.async { [weak self] in
          guard let strongSelf = self else {
            return
          }

          strongSelf.view.addSubview(spinner)

          spinner.translatesAutoresizingMaskIntoConstraints = false
          spinner.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor).isActive = true
          spinner.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor).isActive = true
          spinner.heightAnchor.constraint(equalToConstant: 100).isActive = true
          spinner.widthAnchor.constraint(equalToConstant: 100).isActive = true

          spinner.startAnimating()
        }
        
        let _ = ContactStoreManager.shared.deleteAllContacts(progressIndicatorHandler: nil)

        DispatchQueue.main.async {
          spinner.stopAnimating()
          spinner.removeFromSuperview()
        }
      })

      deleteAllPopup.addAction(cancelAction)
      deleteAllPopup.addAction(deleteAction)
      present(deleteAllPopup, animated: true, completion: nil)
    }
  }

  func generateNewTextForLabel(label: UILabel?, n: Int) {
    if let labelText = label?.text, let indexOfColon = labelText.firstIndex(of: ":") {
      label?.text = labelText[labelText.startIndex..<indexOfColon] + " \(n)"
    }
  }

  @objc func hideKeyboard() {
    if let batchSizeString = batchSizeTextField.text, let batchSize = Int(batchSizeString) {
      PersistentDataController.shared.batchSize = batchSize
    }

    view.endEditing(true)
  }

  // MARK: - Button Handlers

  @objc func didTapAddContactsToDevice() {
    showAddPopup { [weak self] desiredAmount in
      guard let strongSelf = self else {
        return
      }

      let alreadyExportedContacts = PersistentDataController.shared.getExportedCount()
      guard desiredAmount < ContactListParser.shared.inMemoryContacts.count - alreadyExportedContacts else {
        return
      }

      let startIndex = alreadyExportedContacts
      let endIndex = startIndex + desiredAmount - 1
      let contactsSlice = Array(ContactListParser.shared.inMemoryContacts[startIndex...endIndex])

      let progressBar = ProgressBar()
      strongSelf.view.addSubview(progressBar)
      progressBar.translatesAutoresizingMaskIntoConstraints = false
      progressBar.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor).isActive = true
      progressBar.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor).isActive = true
      progressBar.heightAnchor.constraint(equalToConstant: 150).isActive = true
      progressBar.widthAnchor.constraint(equalToConstant: strongSelf.view.frame.width * 0.5).isActive = true

      let queue = DispatchQueue(label: "AddContactsDispatchQueue")
      queue.async {
        let progressIndicatorHandler: (Float) -> Void = { progress in
          DispatchQueue.main.async {
            progressBar.setProgress(progress)
          }
        }

        let startTime = Date()
        let result = ContactStoreManager.shared.addContactsToDevice(contactsSlice, progressIndicatorHandler: progressIndicatorHandler)
        let endTime = Date()
        let timeInterval = String(endTime.timeIntervalSince(startTime)).prefix(10)

        DispatchQueue.main.async {
          let alertTitle = "\(result.description)\n\(timeInterval) (s)"
          let alertController = UIAlertController(title: alertTitle)
          strongSelf.present(alertController, animated: true, completion: nil)

          strongSelf.setUpLabels()
          progressBar.removeFromSuperview()
        }
      }
    }
  }

  @objc func didTapDeleteContacts() {
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else {
        return
      }

      let progressBar = ProgressBar()
      strongSelf.view.addSubview(progressBar)
      progressBar.translatesAutoresizingMaskIntoConstraints = false
      progressBar.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor).isActive = true
      progressBar.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor).isActive = true
      progressBar.heightAnchor.constraint(equalToConstant: 150).isActive = true
      progressBar.widthAnchor.constraint(equalToConstant: strongSelf.view.frame.width * 0.5).isActive = true

      let dispatchQueue = DispatchQueue(label: "DeleteContactsDispatchQueue")
      dispatchQueue.async { [weak self] in
        guard let strongSelf = self else {
          return
        }

        let progressIndicatorHandler: (Float) -> Void = { progress in
           progressBar.setProgress(progress)
        }

        let startTime = Date()
        let result = ContactStoreManager.shared.deleteContacts(progressIndicatorHandler: progressIndicatorHandler)
        let endTime = Date()

        let timeInterval = String(endTime.timeIntervalSince(startTime)).prefix(10)

        DispatchQueue.main.async {
          progressBar.removeFromSuperview()

          let alertTitle = "\(result.description)\n\(timeInterval) (s)"
          let alertController = UIAlertController(title: alertTitle)
          strongSelf.present(alertController, animated: true, completion: nil)
          strongSelf.setUpLabels()
        }
      }
    }
  }

  // MARK: - Popup Helpers

  func showAddPopup(amountEnteredCompletion: @escaping (Int) -> Void) {
    let maxAmount = ContactListParser.shared.inMemoryContacts.count - PersistentDataController.shared.getExportedCount()
    let alertController = UIAlertController(title: "How many contacts to add?", message: "Max = \(maxAmount)", preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "If empty, the max amount will be added"
      textField.keyboardType = .numberPad
    }

    let addAction = UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
      guard let strongSelf = self else {
        return
      }

      let amountToExport: Int = {
        if let desiredAmount = alertController.textFields?[0].text, let desiredAmountInt = Int(desiredAmount) {
          return desiredAmountInt
        }
        else {
          return maxAmount
        }
      }()

      guard amountToExport <= maxAmount else {
        let miniAlertController = UIAlertController(title: "Please enter a number within 0 and \(maxAmount)")
        miniAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        strongSelf.present(miniAlertController, animated: true, completion: nil)
        return
      }

      amountEnteredCompletion(amountToExport)
    })

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    alertController.addAction(addAction)
    alertController.addAction(cancelAction)


    self.present(alertController, animated: true, completion: nil)
  }
}
