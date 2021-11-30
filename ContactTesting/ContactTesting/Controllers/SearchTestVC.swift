//
//  SearchTestVC.swift
//  SearchTestVC
//
//  Created by Allie Shuldman on 10/11/21.
//

import Contacts
import MessageUI
import UIKit

class SearchTestVC: UIViewController {
  let searchParameters: SearchParameters
  let numberOfContactsOnDevice = ContactStoreManager.shared.getNumberOfTestContactsOnDevice()
  var randomContacts = Set<Contact>()

  let scrollView = UIScrollView()
  let searchParametersLabel = BoldLabel()
  let expectedNumberOfContactsLabel = BoldLabel()
  let actualNumberOfContactsLabel = BoldLabel()
  let resultLabel = UILabel()
  let sendResultsButton = BlueButton()

  let dispatchQueue = DispatchQueue(label: "SearchQueue")

  init(searchParameters: SearchParameters) {
    self.searchParameters = searchParameters

    while randomContacts.count < searchParameters.searchAmount {
      let upperBound = min(numberOfContactsOnDevice, ContactListParser.shared.inMemoryContacts.count)
      let randomIndex = Int.random(in: 0..<upperBound)
      randomContacts.insert(ContactListParser.shared.inMemoryContacts[randomIndex])
    }

    super.init(nibName: nil, bundle: Bundle.main)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    searchParametersLabel.text = "Searching for \(searchParameters.searchAmount) contact(s) by \(searchParameters.searchField.rawValue)"

    searchParametersLabel.numberOfLines = 0
    searchParametersLabel.lineBreakMode = .byWordWrapping
    searchParametersLabel.textColor = UIColor(red: 0.0, green: 0.32, blue: 0.44, alpha: 1.0)

    expectedNumberOfContactsLabel.text = "Expected number of test contacts on device: \(PersistentDataController.shared.getExportedCount())"
    expectedNumberOfContactsLabel.numberOfLines = 0
    expectedNumberOfContactsLabel.lineBreakMode = .byWordWrapping

    actualNumberOfContactsLabel.text = "Number of contacts found in group: \(numberOfContactsOnDevice)"
    actualNumberOfContactsLabel.numberOfLines = 0
    actualNumberOfContactsLabel.lineBreakMode = .byWordWrapping

    sendResultsButton.setTitle("Send results via email", for: .normal)
    sendResultsButton.addTarget(self, action: #selector(didTapSendResultsButton), for: .touchUpInside)

    resultLabel.numberOfLines = 0
    resultLabel.lineBreakMode = .byWordWrapping

    view.addSubview(scrollView)
    scrollView.addSubview(searchParametersLabel)
    scrollView.addSubview(expectedNumberOfContactsLabel)
    scrollView.addSubview(actualNumberOfContactsLabel)
    scrollView.addSubview(sendResultsButton)
    scrollView.addSubview(resultLabel)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    search()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    scrollView.frame = CGRect(
      x: 0,
      y: 0,
      width: view.frame.width,
      height: tabBarController?.tabBar.frame.minY ?? view.frame.height
    )

    searchParametersLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: UIConstants.topSpacing,
      width: scrollView.frame.width - 2 * UIConstants.leftInset,
      height: searchParametersLabel.frame.height
    )
    searchParametersLabel.sizeToFit()

    expectedNumberOfContactsLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: searchParametersLabel.frame.maxY + UIConstants.topSpacing,
      width: searchParametersLabel.frame.width,
      height: searchParametersLabel.frame.height
    )
    expectedNumberOfContactsLabel.sizeToFit()

    actualNumberOfContactsLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: expectedNumberOfContactsLabel.frame.maxY + UIConstants.topSpacing,
      width: actualNumberOfContactsLabel.frame.width,
      height: actualNumberOfContactsLabel.frame.height
    )
    actualNumberOfContactsLabel.sizeToFit()

    sendResultsButton.frame = CGRect(
      x: UIConstants.leftInset,
      y: actualNumberOfContactsLabel.frame.maxY + UIConstants.topSpacing,
      width: view.frame.width - 2 * UIConstants.leftInset,
      height: UIConstants.buttonHeight
    )

    resultLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: sendResultsButton.frame.maxY + UIConstants.topSpacing,
      width: scrollView.frame.width - 2 * UIConstants.leftInset,
      height: resultLabel.frame.height
    )

    scrollView.contentSize = CGSize(width: view.frame.width, height: resultLabel.frame.maxY)
  }

  func search() {
    // Add spinner
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

    var totalContactsFound = 0
    var unsuccessfulFetches = 0

    var executionTimes = [Double]()
    var executionResults = [String]()

    // Perform searches
    dispatchQueue.async { [weak self] in
      guard let strongSelf = self else {
        return
      }

      for contact in strongSelf.randomContacts {
        let result = ContactStoreManager.shared.searchForContact(contact, field: strongSelf.searchParameters.searchField)

        switch result {
        case .success(let contacts, let searchTime):
          totalContactsFound += contacts.count
          let executionTime = searchTime * 1000
          executionTimes.append(executionTime)
          executionResults.append(String(executionTime))
        case .failure(let error):
          unsuccessfulFetches += 1
          executionResults.append(error.description)
        }
      }

      // Display results
      DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else {
          return
        }

        spinner.stopAnimating()
        spinner.removeFromSuperview()
        let averageTime = executionTimes.count > 0 ? Double(executionTimes.reduce(0, { $0 + $1 })) / Double(executionTimes.count) : 0
        strongSelf.resultLabel.text = "Total contacts found: \(totalContactsFound)\nNumber of failed fetches: \(unsuccessfulFetches)\n\nAverage Time (ms): \(String(averageTime).prefix(10))\n\nResults: \n\(executionResults.joined(separator: "\n"))"
        strongSelf.resultLabel.sizeToFit()
        strongSelf.view.setNeedsLayout()
      }
    }
  }

  @objc func didTapSendResultsButton() {
    guard MFMailComposeViewController.canSendMail() else {
      let alertController = UIAlertController(title: "Make sure you have at least one mail account added to your device")
      present(alertController, animated: true, completion: nil)
      return
    }

    let composeVC = MFMailComposeViewController()
    composeVC.mailComposeDelegate = self
    composeVC.setSubject(searchParametersLabel.text ?? "")
    composeVC.setMessageBody(resultLabel.text ?? "", isHTML: false)
    self.present(composeVC, animated: true, completion: nil)
  }
}

// MARK: - MFMailComposeViewControllerDelegate

extension SearchTestVC: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - CNContact

extension CNContact {
  var displayDescription: String {
    return "Given Name: \(givenName), Family Name: \(familyName), identifier: \(identifier), phone numbers: \(String(describing: phoneNumbers.first?.value.stringValue)), email addresses \(String(describing: emailAddresses.first?.value)), url: \(String(describing: urlAddresses.first?.value))"
  }
}
