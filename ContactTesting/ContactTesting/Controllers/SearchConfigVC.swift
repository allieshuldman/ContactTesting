//
//  SearchConfigVC.swift
//  SearchConfigVC
//
//  Created by Allie Shuldman on 10/7/21.
//

import UIKit

class SearchConfigVC: UIViewController {
  enum Section: Int, CaseIterable {
    case searchField

    var title: String {
      switch self {
      case .searchField:
        return "SearchField"
      }
    }
  }

  static let cellIdentifier = "SearchConfigCell"
  let maxContacts = ContactStoreManager.shared.getNumberOfTestContactsOnDevice()

  let scrollView = UIScrollView()
  let tableView = UITableView(frame: .zero, style: .insetGrouped)
  let amountLabel = BoldLabel()
  let amountTextField = UITextField(frame: .zero)
  let beginSearchTestButton = BlueButton()
  let buttonBackground = UIView()
  let gradientLayer = CAGradientLayer()

  var selectedCells = [Section: Int]()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    tableView.isScrollEnabled = false
    tableView.allowsMultipleSelection = true
    tableView.delegate = self
    tableView.dataSource = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Search Configuration"

    let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)

    view.backgroundColor = tableView.backgroundColor

    amountLabel.text = "Number of contacts to search for:"

    amountTextField.backgroundColor = .white
    amountTextField.layer.cornerRadius = UIConstants.cornerRadius
    amountTextField.placeholder = " Default: 1, Total contacts: \(maxContacts)"
    amountTextField.keyboardType = .numberPad

    beginSearchTestButton.setTitle("Begin search test", for: .normal)
    beginSearchTestButton.addTarget(self, action: #selector(didTapBeginSearchTest), for: .touchUpInside)

    buttonBackground.backgroundColor = .clear

    tableView.estimatedRowHeight = 44
    tableView.estimatedSectionHeaderHeight = 50

    view.addSubview(scrollView)
    scrollView.addSubview(tableView)
    scrollView.addSubview(amountLabel)
    scrollView.addSubview(amountTextField)
    view.addSubview(buttonBackground)
    view.addSubview(beginSearchTestButton)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    scrollView.frame = CGRect(
      x: 0,
      y: 0,
      width: view.frame.width,
      height: tabBarController?.tabBar.frame.minY ?? view.frame.maxY
    )

    beginSearchTestButton.frame = CGRect(
      x: UIConstants.leftInset,
      y: (tabBarController?.tabBar.frame.minY ?? view.frame.maxY) - UIConstants.buttonHeight - UIConstants.topSpacing,
      width: view.frame.width - 2 * UIConstants.leftInset,
      height: UIConstants.buttonHeight
    )

    buttonBackground.frame = CGRect(
      x: 0,
      y: view.frame.height - beginSearchTestButton.frame.height - 2 * UIConstants.topSpacing,
      width: view.frame.width,
      height: beginSearchTestButton.frame.height + 2 * UIConstants.topSpacing
    )

    gradientLayer.frame = CGRect(x: 0, y: 0, width: buttonBackground.frame.width, height: buttonBackground.frame.height)
    gradientLayer.colors = [UIColor.white.withAlphaComponent(0.0).cgColor, UIColor.white.withAlphaComponent(1.0).cgColor, UIColor.white.withAlphaComponent(1.0).cgColor]
    gradientLayer.locations = [NSNumber(value: 0.0), NSNumber(value: 0.2), NSNumber(value: 0.9)]

    buttonBackground.layer.addSublayer(gradientLayer)

    amountLabel.sizeToFit()
    amountLabel.frame = CGRect(
      x: UIConstants.leftInset,
      y: 10.0,
      width: view.frame.width - 2 * UIConstants.leftInset,
      height: amountLabel.frame.height
    )

    amountTextField.frame = CGRect(
      x: UIConstants.leftInset,
      y: amountLabel.frame.maxY + (UIConstants.topSpacing / 2.0),
      width: view.frame.width - 2 * UIConstants.leftInset,
      height: 50.0
    )

    tableView.frame = CGRect(
      x: 0,
      y: amountTextField.frame.maxY,
      width: scrollView.frame.width,
      height: tableView.contentSize.height
    )

    scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonBackground.frame.height, right: 0)
    scrollView.contentSize = CGSize(width: view.frame.width, height: tableView.frame.maxY)

    for section in 0..<tableView.numberOfSections {
      if tableView.numberOfRows(inSection: section) > 0 {
        tableView.selectRow(at: IndexPath(row: 0, section: section), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        selectedCells[Section(rawValue: section) ?? .searchField] = 0
      }
    }
  }

  @objc func hideKeyboard() {
    view.endEditing(true)
  }

  // MARK: - Section Helpers

  func dataForSection(_ section: Int) -> [String] {
    guard let sectionType = Section(rawValue: section) else {
      return []
    }

    switch sectionType {
    case .searchField:
      return SearchParameters.SearchField.allCases.map { $0.rawValue }
    }
  }

  // MARK: - Button Handlers

  @objc func didTapBeginSearchTest() {
    guard let searchFieldIndex = selectedCells[.searchField], searchFieldIndex < SearchParameters.SearchField.allCases.count else {
      return
    }

    let searchAmount: Int = {
      guard let amountTextFieldText = amountTextField.text, let amountTextFieldInt = Int(amountTextFieldText), amountTextFieldInt < maxContacts else {
        return 1
      }

      return amountTextFieldInt
    }()


    let searchParameters = SearchParameters(
      searchField: SearchParameters.SearchField.allCases[searchFieldIndex],
      searchAmount: searchAmount
    )

    let searchTestVC = SearchTestVC(searchParameters: searchParameters)
    navigationController?.pushViewController(searchTestVC, animated: true)
  }
}

// MARK: - UITableViewDelegate

extension SearchConfigVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section), indexPath.row < dataForSection(indexPath.section).count else {
      return
    }

    if let selectedCellRow = selectedCells[section] {
      tableView.deselectRow(at: IndexPath(row: selectedCellRow, section: indexPath.section), animated: false)
    }

    selectedCells[section] = indexPath.row
  }
}

// MARK: - UITableViewDataSource

extension SearchConfigVC: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return Section.allCases.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataForSection(section).count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
    let data = dataForSection(indexPath.section)

    guard indexPath.row < data.count else {
      return cell
    }

    cell.textLabel?.text = data[indexPath.row]
    cell.textLabel?.numberOfLines = 0

    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Section(rawValue: section)?.title
  }
}
