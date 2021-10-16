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
      randomContacts = Set((0..<searchParameters.searchAmount).map { _ in RandomContactGenerator.generate() })
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
      searchParametersLabel.text = "Searching for 1 contact that \(searchParameters.searchForExistingContact ? "exists" : "doesn't exist") by \(searchParameters.searchField.rawValue)"
    }
    else {
      searchParametersLabel.text = "Searching for \(searchParameters.searchAmount) contacts that \(searchParameters.searchForExistingContact ? "" : "don't") exist by \(searchParameters.searchField.rawValue)"
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
      y: Constants.topSpacing,
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
        let startTime = Date()
        let result = ContactStoreManager.shared.searchForContact(contact, field: strongSelf.searchParameters.searchField)
        let endTime = Date()

        switch result {
        case .success(let contacts):
          totalContactsFound += contacts.count
          let executionTime = endTime.timeIntervalSince(startTime) * 1000
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
        strongSelf.resultLabel.text = "Total contacts found: \(totalContactsFound)\nNumber of unsuccessful fetches: \(unsuccessfulFetches)\n\nAverage Time (ms): \(String(averageTime).prefix(10))\n\nResults: \n\(executionResults.joined(separator: "\n"))"
        print(averageTime)
        strongSelf.resultLabel.sizeToFit()
        strongSelf.view.setNeedsLayout()
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
