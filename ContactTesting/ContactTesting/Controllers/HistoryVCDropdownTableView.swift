//
//  HistoryVCDropdownTableView.swift
//  HistoryVCDropdownTableView
//
//  Created by Allie Shuldman on 11/16/21.
//

import UIKit
import Contacts

protocol HistoryVCDropdownTableViewDelegate: AnyObject {
  func didSelectEventType(_ eventType: CNChangeHistoryEvent.Type)
  func didDeselectEventType()
}

class HistoryVCDropdownTableView: UIViewController {
  static let cellIdentifier = "HistoryVCDropdownTableViewCell"
  let tableView = UITableView()

  weak var delegate: HistoryVCDropdownTableViewDelegate?

  var eventTypes: [CNChangeHistoryEvent.Type] = [
    CNChangeHistoryAddContactEvent.self,
    CNChangeHistoryAddMemberToGroupEvent.self,
    CNChangeHistoryAddGroupEvent.self,
    CNChangeHistoryAddSubgroupToGroupEvent.self,
    CNChangeHistoryDeleteContactEvent.self,
    CNChangeHistoryDeleteGroupEvent.self,
    CNChangeHistoryDropEverythingEvent.self,
    CNChangeHistoryRemoveMemberFromGroupEvent.self,
    CNChangeHistoryRemoveSubgroupFromGroupEvent.self,
    CNChangeHistoryUpdateContactEvent.self,
    CNChangeHistoryUpdateGroupEvent.self,
  ]

  init() {
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = .clear

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.contentInset = .zero
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.layer.cornerRadius = UIConstants.cornerRadius

    tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = .clear
    tableView.layer.cornerRadius = UIConstants.cornerRadius

    view.addSubview(tableView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.frame = view.bounds
  }
}

extension HistoryVCDropdownTableView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if tableView.indexPathForSelectedRow == indexPath {
      delegate?.didDeselectEventType()
      tableView.deselectRow(at: indexPath, animated: true)
      return nil
    }

    return indexPath
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row < eventTypes.count else {
      return
    }

    delegate?.didSelectEventType(eventTypes[indexPath.row])
  }
}

extension HistoryVCDropdownTableView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return eventTypes.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)

    guard indexPath.row < eventTypes.count else {
      return cell
    }

    var config = cell.defaultContentConfiguration()
    config.text = eventTypes[indexPath.row].displayTitle
    config.textProperties.font = .preferredFont(forTextStyle: .caption1)
    cell.contentConfiguration = config

    cell.backgroundColor = .lightGray
    cell.selectedBackgroundView?.backgroundColor = .lightBlue

    if indexPath.row == 0 {
      cell.layer.cornerRadius = UIConstants.cornerRadius
      cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    else if indexPath.row == eventTypes.count - 1 {
      cell.separatorInset.left = UIScreen.main.bounds.width
      cell.layer.cornerRadius = UIConstants.cornerRadius
      cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    return cell
  }
}
