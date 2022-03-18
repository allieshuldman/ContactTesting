//
//  FullTestVC.swift
//  FullTestVC
//
//  Created by Allie Shuldman on 12/8/21.
//

import Foundation
import MessageUI
import UIKit

class FullTestVC: UIViewController {
  let warningLabel = BoldLabel()
  let resultsLabel = UILabel()
  let scrollView = UIScrollView()

  var resultString: String {
    didSet {
      DispatchQueue.main.async {
        self.resultsLabel.text = self.resultString
        self.view.setNeedsLayout()
      }
    }
  }

  var emailString = ""

  let rounds: Int

  init(rounds: Int) {
    self.rounds = rounds
    self.resultString = "Test has begun\n\n"

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
    scrollView.backgroundColor = .white

    resultsLabel.text = resultString
    resultsLabel.numberOfLines = 0

    warningLabel.text = "Do not close app"

    view.addSubview(scrollView)
    scrollView.addSubview(warningLabel)
    scrollView.addSubview(resultsLabel)

    performTest(rounds: rounds)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    scrollView.frame = CGRect(
      x: 0,
      y: 0,
      width: view.frame.width,
      height: tabBarController?.tabBar.frame.minY ?? view.frame.height
    )

    warningLabel.sizeToFit()
    warningLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: UIConstants.topSpacing,
      width: scrollView.frame.width - 2 * UIConstants.leftInset,
      height: warningLabel.frame.height
    )

    resultsLabel.sizeToFit()
    resultsLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: warningLabel.frame.maxY + UIConstants.topSpacing,
      width: scrollView.frame.width - 2 * UIConstants.leftInset,
      height: resultsLabel.frame.height
    )

    scrollView.contentSize = CGSize(width: view.frame.width, height: resultsLabel.frame.maxY - warningLabel.frame.minY)
  }

  func performTest(rounds: Int) {
    DispatchQueue.global(qos: .background).async {
      let contacts = ContactListParser.shared.inMemoryContacts

      for _ in 0..<rounds {
        self.addTest(contacts: contacts)
        self.searchTest(contacts: contacts)
        self.deleteTest(contacts: contacts)
      }

      print(self.emailString)

      guard MFMailComposeViewController.canSendMail() else {
        let alertController = UIAlertController(title: "Make sure you have at least one mail account added to your device")
        self.present(alertController, animated: true, completion: nil)
        return
      }

      DispatchQueue.main.async {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
          $0.withMemoryRebound(to: CChar.self, capacity: 1) {
            ptr in String.init(validatingUTF8: ptr)
          }
        }

        let subject = "Full test \(Date()) \(modelCode ?? "") \(UIDevice.current.systemVersion)"
        composeVC.setSubject(subject)

        composeVC.setMessageBody(self.emailString, isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
      }
    }
  }

  private func addTest(contacts: [Contact]) {
    resultString.append("Adding \(contacts.count) contacts in batches of 100\n")
    let addStart = Date()
//    var addBatchStart = Date()
    var addBatches = 0
    let addResult = ContactStoreManager.shared.addContactsToDevice(contacts, progressIndicatorHandler: { _ in
//      self.resultString.append("Added batch in \(Date().timeIntervalSince(addBatchStart)) s\n")
//      addBatchStart = Date()
      addBatches += 1
    })

    let addEnd = Date().timeIntervalSince(addStart)
    resultString.append("Finished adding contacts in \(addEnd) s, result: \(addResult)\n")
    emailString.append("Average batch save time: \(Double(addEnd)/Double(addBatches)) s \n\n")

  }

  private func searchTest(contacts: [Contact]) {
    for searchField in SearchParameters.SearchField.allCases {
      var randomContacts = Set<Contact>()
      while randomContacts.count < 100 {
        randomContacts.insert(ContactListParser.shared.inMemoryContacts[Int.random(in: 0..<contacts.count)])
      }

      var executionTimes = [Double]()
      resultString.append("Searching for a contact by \(searchField) (100 trials)\n")
      for contact in randomContacts {
        let searchResult = ContactStoreManager.shared.searchForContact(contact, field: searchField)
        switch searchResult {
        case .success(let array, let timeInterval):
          executionTimes.append(timeInterval)
          resultString.append("Success: found \(array.count) contact(s) in \(timeInterval)\n")
        case .failure(let searchError):
          resultString.append("Failure: \(searchError)\n")
        }
      }
      let averageTime = executionTimes.count > 0 ? Double(executionTimes.reduce(0, { $0 + $1 })) / Double(executionTimes.count) : 0
      emailString.append("Ave time for searching by \(searchField): \(averageTime) s\n")
    }

    resultString.append("\n")
    emailString.append("\n")
  }

  private func deleteTest(contacts: [Contact]) {
    resultString.append("Deleting \(contacts.count) contacts in batches of 100\n")
    let deleteStart = Date()
//    var deleteBatchStart = Date()
    var deleteBatches = 0
    let deleteResult = ContactStoreManager.shared.deleteContacts(progressIndicatorHandler: { _ in
//      self.resultString.append("Deleted batch in \(Date().timeIntervalSince(deleteBatchStart)) s\n")
//      deleteBatchStart = Date()
      deleteBatches += 1
    })

    let deleteEnd = Date().timeIntervalSince(deleteStart)
    resultString.append("Finished deleting contacts in \(deleteEnd) s, result: \(deleteResult)\n")
    emailString.append("Average batch delete time: \(Double(deleteEnd)/Double(deleteBatches)) s \n\n")
  }
}

extension FullTestVC: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    dismiss(animated: true, completion: nil)
  }
}
