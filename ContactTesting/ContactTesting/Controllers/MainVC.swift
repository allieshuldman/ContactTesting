//
//  ViewController.swift
//  ContactTesting
//
//  Created by Allie Shuldman on 10/4/21.
//

import UIKit

class MainVC: UIViewController {
  let numberOfContactsInMemoryLabel = BoldLabel()
  let numberOfContactsInContainerLabel = BoldLabel()
  let numberOfContactsOnDeviceLabel = BoldLabel()

  let addContactsToDeviceButton = GrayButton()
  let deleteContactsFromDeviceButton = GrayButton()

  let beginSearchTestButton = BlueButton()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    ContactStoreManager.shared.promptForAccessIfNeeded { accessGranted in
      if accessGranted {
        DispatchQueue.main.async {
          self.setUpView()
        }
      }
      else {
        DispatchQueue.main.async {
          let alertController = self.createSimpleAlertController(title: "Please grant contact access in device settings")
          self.present(alertController, animated: true, completion: nil)
        }
      }
    }
  }

  func setUpView() {
    setUpLabels()

    addContactsToDeviceButton.setTitle("Add contacts to device", for: .normal)
    addContactsToDeviceButton.addTarget(self, action: #selector(didTapAddContactsToDevice), for: .touchUpInside)

    deleteContactsFromDeviceButton.setTitle("Delete contacts from device", for: .normal)
    deleteContactsFromDeviceButton.addTarget(self, action: #selector(didTapDeleteContacts), for: .touchUpInside)

    beginSearchTestButton.setTitle("Configure search test", for: .normal)
    beginSearchTestButton.addTarget(self, action: #selector(didTapBeginSearchTestButton), for: .touchUpInside)

    view.addSubview(numberOfContactsInMemoryLabel)
    view.addSubview(numberOfContactsInContainerLabel)
    view.addSubview(numberOfContactsOnDeviceLabel)
    view.addSubview(addContactsToDeviceButton)
    view.addSubview(deleteContactsFromDeviceButton)
    view.addSubview(beginSearchTestButton)
  }

  func setUpLabels() {
    numberOfContactsInMemoryLabel.text = "Number of contacts in memory: \(ContactListParser.shared.inMemoryContacts.count)"
    numberOfContactsInContainerLabel.text = "Number of contacts in container: \(ContactStoreManager.shared.getNumberOfTestContactsOnDevice())"
    numberOfContactsOnDeviceLabel.text = "Number of contacts on device: \(ContactStoreManager.shared.getNumberOfContactsOnDevice())"
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    numberOfContactsInMemoryLabel.sizeToFit()
    numberOfContactsInMemoryLabel.frame =  CGRect(
     x: Constants.leftInset,
     y: Constants.topSpacing,
     width: view.frame.width - 2 * Constants.leftInset,
     height: numberOfContactsInMemoryLabel.frame.height
    )

    numberOfContactsInContainerLabel.sizeToFit()
    numberOfContactsInContainerLabel.frame =  CGRect(
     x: Constants.leftInset,
     y: numberOfContactsInMemoryLabel.frame.maxY + Constants.topSpacing,
     width: view.frame.width - 2 * Constants.leftInset,
     height: numberOfContactsInContainerLabel.frame.height
    )

    numberOfContactsOnDeviceLabel.sizeToFit()
    numberOfContactsOnDeviceLabel.frame =  CGRect(
     x: Constants.leftInset,
     y: numberOfContactsInContainerLabel.frame.maxY + Constants.topSpacing,
     width: view.frame.width - 2 * Constants.leftInset,
     height: numberOfContactsOnDeviceLabel.frame.height
    )

    addContactsToDeviceButton.frame = CGRect(
      x: Constants.leftInset,
      y: numberOfContactsOnDeviceLabel.frame.maxY + Constants.topSpacing,
      width: view.frame.width - 2 * Constants.leftInset,
      height: Constants.buttonHeight
    )

    deleteContactsFromDeviceButton.frame = CGRect(
      x: Constants.leftInset,
      y: addContactsToDeviceButton.frame.maxY + Constants.topSpacing,
      width: view.frame.width - 2 * Constants.leftInset,
      height: Constants.buttonHeight
    )

    let testButtonY = deleteContactsFromDeviceButton.frame.maxY > view.frame.maxY - Constants.buttonHeight - Constants.topSpacing ? view.frame.maxY - Constants.buttonHeight : view.frame.maxY - Constants.buttonHeight - Constants.topSpacing

    beginSearchTestButton.frame = CGRect(
      x: Constants.leftInset,
      y: testButtonY,
      width: view.frame.width - 2 * Constants.leftInset,
      height: Constants.buttonHeight
    )
  }

  func generateNewTextForLabel(label: UILabel?, n: Int) {
    if let labelText = label?.text, let indexOfColon = labelText.firstIndex(of: ":") {
      label?.text = labelText[labelText.startIndex..<indexOfColon] + " \(n)"
    }
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

      let spinner = Spinner(style: .large)
      strongSelf.view.addSubview(spinner)

      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor).isActive = true
      spinner.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor).isActive = true
      spinner.heightAnchor.constraint(equalToConstant: 100).isActive = true
      spinner.widthAnchor.constraint(equalToConstant: 100).isActive = true

      spinner.startAnimating()

      let queue = DispatchQueue(label: "AddContactsDispatchQueue")
      queue.async {

        let startTime = Date()
        let result = ContactStoreManager.shared.addContactsToDevice(contactsSlice)
        let endTime = Date()

        let timeInterval = String(endTime.timeIntervalSince(startTime)).prefix(10)

        DispatchQueue.main.async {
          let alertTitle = "\(result.description)\n\(timeInterval) (s)"
          let alertController = strongSelf.createSimpleAlertController(title: alertTitle)
          strongSelf.present(alertController, animated: true, completion: nil)

          strongSelf.setUpLabels()
          spinner.stopAnimating()
          spinner.removeFromSuperview()
        }
      }

    }
  }

  @objc func didTapDeleteContacts() {
    let spinner = Spinner(style: .large)
    self.view.addSubview(spinner)

    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    spinner.heightAnchor.constraint(equalToConstant: 100).isActive = true
    spinner.widthAnchor.constraint(equalToConstant: 100).isActive = true

    spinner.startAnimating()

    let dispatchQueue = DispatchQueue(label: "DeleteContactsDispatchQueue")
    dispatchQueue.async { [weak self] in
      guard let strongSelf = self else {
        return
      }

      let startTime = Date()
      let result = ContactStoreManager.shared.deleteContacts()
      let endTime = Date()

      let timeInterval = String(endTime.timeIntervalSince(startTime)).prefix(10)

      DispatchQueue.main.async {
        spinner.stopAnimating()
        spinner.removeFromSuperview()

        let alertTitle = "\(result.description)\n\(timeInterval) (s)"
        let alertController = strongSelf.createSimpleAlertController(title: alertTitle)
        strongSelf.present(alertController, animated: true, completion: nil)
        strongSelf.setUpLabels()
      }
    }
  }

  @objc func didTapBeginSearchTestButton() {
    if ContactStoreManager.shared.getNumberOfTestContactsOnDevice() == 0 {
      let alert = createSimpleAlertController(title: "Add contacts to device before proceeding")
      present(alert, animated: true, completion: nil)
    }
    else {
      let searchConfigVC = SearchConfigVC()
      navigationController?.pushViewController(searchConfigVC, animated: true)
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
        let miniAlertController = strongSelf.createSimpleAlertController(title: "Please enter a number within 0 and \(maxAmount)")
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

  func createSimpleAlertController(title: String) -> UIAlertController {
    let controller = UIAlertController(title: title, message: "", preferredStyle: .alert)
    controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    return controller
  }
}
