//
//  SearchTestVC.swift
//  SearchTestVC
//
//  Created by Allie Shuldman on 10/11/21.
//

import UIKit
import Contacts

class SearchTestVC: UIViewController {
  let searchParameters: SearchParameters
  let numberOfContactsOnDevice = ContactStoreManager.shared.getNumberOfTestContactsOnDevice()
  var randomContacts = Set<Contact>()

  let scrollView = UIScrollView()
  let searchParametersLabel = BoldLabel()
  let expectedNumberOfContactsLabel = BoldLabel()
  let actualNumberOfContactsLabel = BoldLabel()
  let resultLabel = UILabel()

  let dispatchQueue = DispatchQueue(label: "SearchQueue")

  init(searchParameters: SearchParameters) {
    self.searchParameters = searchParameters

    if searchParameters.searchForExistingContact {
      while randomContacts.count < searchParameters.searchAmount {
        let upperBound = min(numberOfContactsOnDevice, ContactListParser.shared.inMemoryContacts.count)
        let randomIndex = Int.random(in: 0..<upperBound)
        randomContacts.insert(ContactListParser.shared.inMemoryContacts[randomIndex])
      }
    }
    else {
      randomContacts = []
    }

    super.init(nibName: nil, bundle: Bundle.main)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    if searchParameters.searchAmount == 1 {
      searchParametersLabel.text = "Searching for 1 contact that \(searchParameters.searchForExistingContact ? "does" : "doesn't") exist in the \(searchParameters.searchLocation.rawValue) by \(searchParameters.searchField.rawValue)"
    }
    else {
      searchParametersLabel.text = "Searching for \(searchParameters.searchAmount) contacts that \(searchParameters.searchForExistingContact ? "do" : "don't") exist in the \(searchParameters.searchLocation.rawValue) by \(searchParameters.searchField.rawValue)"
    }

    searchParametersLabel.numberOfLines = 0
    searchParametersLabel.lineBreakMode = .byWordWrapping
    searchParametersLabel.textColor = UIColor(red: 0.0, green: 0.32, blue: 0.44, alpha: 1.0)

    expectedNumberOfContactsLabel.text = "Expected number of test contacts on device: \(PersistentDataController.shared.getExportedCount())"
    expectedNumberOfContactsLabel.numberOfLines = 0
    expectedNumberOfContactsLabel.lineBreakMode = .byWordWrapping

    actualNumberOfContactsLabel.text = "Number of contacts found in group: \(numberOfContactsOnDevice)"
    actualNumberOfContactsLabel.numberOfLines = 0
    actualNumberOfContactsLabel.lineBreakMode = .byWordWrapping

    resultLabel.numberOfLines = 0
    resultLabel.lineBreakMode = .byWordWrapping

    view.addSubview(scrollView)
    scrollView.addSubview(searchParametersLabel)
    scrollView.addSubview(expectedNumberOfContactsLabel)
    scrollView.addSubview(actualNumberOfContactsLabel)
    scrollView.addSubview(resultLabel)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    search()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    scrollView.frame = view.frame

    searchParametersLabel.frame = CGRect(
      x: Constants.leftInset,
      y: 0,
      width: scrollView.frame.width - 2 * Constants.leftInset,
      height: searchParametersLabel.frame.height
    )
    searchParametersLabel.sizeToFit()

    expectedNumberOfContactsLabel.frame = CGRect(
      x: Constants.leftInset,
      y: searchParametersLabel.frame.maxY + Constants.topSpacing,
      width: searchParametersLabel.frame.width,
      height: searchParametersLabel.frame.height
    )
    expectedNumberOfContactsLabel.sizeToFit()

    actualNumberOfContactsLabel.frame = CGRect(
      x: Constants.leftInset,
      y: expectedNumberOfContactsLabel.frame.maxY + Constants.topSpacing,
      width: actualNumberOfContactsLabel.frame.width,
      height: actualNumberOfContactsLabel.frame.height
    )
    actualNumberOfContactsLabel.sizeToFit()

    resultLabel.frame = CGRect(
      x: Constants.leftInset,
      y: actualNumberOfContactsLabel.frame.maxY + Constants.topSpacing,
      width: scrollView.frame.width - 2 * Constants.leftInset,
      height: resultLabel.frame.height
    )

    scrollView.contentSize = CGSize(width: view.frame.width, height: resultLabel.frame.maxY - searchParametersLabel.frame.minY)
  }

  func search() {
    var executionTimes = [Double]()
    dispatchQueue.async { [self] in
      for contact in randomContacts {
        let startTime = Date()
        let _ = ContactStoreManager.shared.searchForContact(contact, location: searchParameters.searchLocation, field: searchParameters.searchField)
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        executionTimes.append(executionTime)
      }

      DispatchQueue.main.async {
        let averageTime = Double(executionTimes.reduce(0, { $0 + $1 })) / Double(executionTimes.count)
        let timeStrings = executionTimes.map { String($0).prefix(10) }
        resultLabel.text = "Average Time: \(String(averageTime).prefix(10))\n\nTimes (s): \n\(timeStrings.joined(separator: "\n"))"
        resultLabel.sizeToFit()
        view.setNeedsLayout()
      }
    }
  }
}

// MARK: - CNContact

extension CNContact {
  var displayDescription: String {
    return "Given Name: \(givenName), Family Name: \(familyName), identifier: \(identifier), phone numbers: \(String(describing: phoneNumbers.first?.value.stringValue)), email addresses \(String(describing: emailAddresses.first?.value)), url: \(String(describing: urlAddresses.first?.value))"
  }
}
