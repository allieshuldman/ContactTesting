//
//  HistoryVC.swift
//  HistoryVC
//
//  Created by Allie Shuldman on 11/16/21.
//

import UIKit
import Contacts

enum FilterType: String {
  case searchTextFilter
  case eventTypeFilter
}

class HistoryVC: UIViewController {
  let tableView = UITableView()
  let searchController = UISearchController()
  let dropDownView = HistoryVCDropdownTableView()

  var allEvents: [CNChangeHistoryEvent]
  var filters: [FilterType: (CNChangeHistoryEvent) -> Bool] {
    didSet {
      filteredEvents = allEvents
      for (_, eventFilter) in filters {
        filteredEvents = filteredEvents.filter {
          eventFilter($0)
        }
      }
    }
  }

  var filteredEvents: [CNChangeHistoryEvent]

  static let cellIdentifier = "HistoryCell"

  init(historyEvents: [CNChangeHistoryEvent]) {
    self.allEvents = historyEvents
    self.filters = [:]
    self.filteredEvents = allEvents

    super.init(nibName: nil, bundle: nil)

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    tableView.delegate = self
    tableView.dataSource = self



    dropDownView.delegate = self

    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.searchController = searchController
    definesPresentationContext = true

    let tap = UITapGestureRecognizer(target: self, action: #selector(hideDropDown))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = filterBarButtonItem(filled: false)

    dropDownView.view.isHidden = true
    dropDownView.view.layer.cornerRadius = UIConstants.cornerRadius

    view.addSubview(tableView)

    addChild(dropDownView)
    dropDownView.didMove(toParent: self)
    view.addSubview(dropDownView.view)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.frame = view.frame

    let width = view.frame.width / 3.0
    dropDownView.view.frame = CGRect(
      x: view.frame.maxX - 2 - width,
      y: navigationController?.navigationBar.frame.maxY ?? UIConstants.topSpacing,
      width: width,
      height: view.frame.maxY - dropDownView.view.frame.minY
    )
  }

  private func filterBarButtonItem(filled: Bool) -> UIBarButtonItem {
    let imageName = filled ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    let barButtonItem = UIBarButtonItem(image: UIImage(systemName:  imageName), style: .plain, target: self, action: #selector(handleFilterButtonTapped))
    return barButtonItem
  }

  @objc func handleFilterButtonTapped() {
    dropDownView.view.isHidden = !dropDownView.view.isHidden
  }

  @objc func hideDropDown() {
    dropDownView.view.isHidden = true
  }

  func filterBySearchTextFilter(event: CNChangeHistoryEvent) -> Bool {
    guard self.searchController.isActive, let input = searchController.searchBar.text, !input.isEmpty else {
      return true
    }

    let text = input.lowercased()

    switch event {
    case let addContactEvent as CNChangeHistoryAddContactEvent:
      return addContactEvent.contact.fullName.contains(text) ||
      addContactEvent.contact.identifier.contains(text) ||
      (addContactEvent.containerIdentifier?.contains(text) ?? false)

    case let addGroupEvent as CNChangeHistoryAddGroupEvent:
      return addGroupEvent.group.name.contains(text) ||
      addGroupEvent.group.identifier.contains(text) ||
      addGroupEvent.containerIdentifier.contains(text)

    case let addContactToGroupEvent as CNChangeHistoryAddMemberToGroupEvent:
      return addContactToGroupEvent.member.fullName.contains(text) ||
      addContactToGroupEvent.member.identifier.contains(text) ||
      addContactToGroupEvent.group.name.contains(text) ||
      addContactToGroupEvent.group.identifier.contains(text)

    case let addSubgroupEvent as CNChangeHistoryAddSubgroupToGroupEvent:
      return addSubgroupEvent.subgroup.name.contains(text) ||
      addSubgroupEvent.subgroup.identifier.contains(text) ||
      addSubgroupEvent.group.name.contains(text) ||
      addSubgroupEvent.group.identifier.contains(text)

    case let deleteContactEvent as CNChangeHistoryDeleteContactEvent:
      return deleteContactEvent.contactIdentifier.contains(text)

    case let deleteGroupEvent as CNChangeHistoryDeleteGroupEvent:
      return deleteGroupEvent.groupIdentifier.contains(text)

    case is CNChangeHistoryDropEverythingEvent:
      return false

    case let removeContactFromGroupEvent as CNChangeHistoryRemoveMemberFromGroupEvent:
      return removeContactFromGroupEvent.member.fullName.contains(text) ||
      removeContactFromGroupEvent.member.identifier.contains(text) ||
      removeContactFromGroupEvent.group.name.contains(text) ||
      removeContactFromGroupEvent.group.identifier.contains(text)

    case let removeSubgroupEvent as CNChangeHistoryRemoveSubgroupFromGroupEvent:
      return removeSubgroupEvent.subgroup.name.contains(text) ||
      removeSubgroupEvent.subgroup.identifier.contains(text) ||
      removeSubgroupEvent.group.name.contains(text) ||
      removeSubgroupEvent.group.identifier.contains(text)

    case let updateContactEvent as CNChangeHistoryUpdateContactEvent:
      return updateContactEvent.contact.fullName.contains(text) ||
      updateContactEvent.contact.identifier.contains(text)

    case let updateGroupEvent as CNChangeHistoryUpdateGroupEvent:
      return updateGroupEvent.group.name.contains(text) ||
      updateGroupEvent.group.identifier.contains(text)

    default:
      return false
    }
  }
}

// MARK: - UITableViewDelegate

extension HistoryVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard indexPath.row < filteredEvents.count else {
      return
    }

    var elements = [(String, String)]()
    var title: String?

    switch filteredEvents[indexPath.row] {
    case let addContactEvent as CNChangeHistoryAddContactEvent:
      title = addContactEvent.contact.fullName
      elements.append(("Contact Name", "\(addContactEvent.contact.fullName)"))
      elements.append(("Contact ID", addContactEvent.contact.identifier))
      elements.append(("Container ID", String(describing: addContactEvent.containerIdentifier)))

    case let addGroupEvent as CNChangeHistoryAddGroupEvent:
      title = addGroupEvent.group.name
      elements.append(("Group Name", addGroupEvent.group.name))
      elements.append(("Group ID", addGroupEvent.group.identifier))
      elements.append(("Container ID", addGroupEvent.containerIdentifier))

    case let addContactToGroupEvent as CNChangeHistoryAddMemberToGroupEvent:
      title = addContactToGroupEvent.member.fullName
      elements.append(("Contact Name", "\(addContactToGroupEvent.member.fullName)"))
      elements.append(("Contact ID", addContactToGroupEvent.member.identifier))
      elements.append(("Group Name", addContactToGroupEvent.group.name))
      elements.append(("Group ID", addContactToGroupEvent.group.identifier))

    case let addSubgroupEvent as CNChangeHistoryAddSubgroupToGroupEvent:
      title = addSubgroupEvent.subgroup.name
      elements.append(("Subgroup Name", addSubgroupEvent.subgroup.name))
      elements.append(("Subgroup ID", addSubgroupEvent.subgroup.identifier))
      elements.append(("Group Name", addSubgroupEvent.group.name))
      elements.append(("Group ID", addSubgroupEvent.group.identifier))

    case let deleteContactEvent as CNChangeHistoryDeleteContactEvent:
      elements.append(("Contact ID", deleteContactEvent.contactIdentifier))

    case let deleteGroupEvent as CNChangeHistoryDeleteGroupEvent:
      elements.append(("Group ID", deleteGroupEvent.groupIdentifier))

    case is CNChangeHistoryDropEverythingEvent:
      break

    case let removeContactFromGroupEvent as CNChangeHistoryRemoveMemberFromGroupEvent:
      title = removeContactFromGroupEvent.member.fullName
      elements.append(("Contact Name", "\(removeContactFromGroupEvent.member.fullName)"))
      elements.append(("Contact ID", removeContactFromGroupEvent.member.identifier))
      elements.append(("Group Name", removeContactFromGroupEvent.group.name))
      elements.append(("Group ID", removeContactFromGroupEvent.group.identifier))

    case let removeSubgroupEvent as CNChangeHistoryRemoveSubgroupFromGroupEvent:
      title = removeSubgroupEvent.subgroup.name
      elements.append(("Subgroup Name", removeSubgroupEvent.subgroup.name))
      elements.append(("Subgroup ID", removeSubgroupEvent.subgroup.identifier))
      elements.append(("Group Name", removeSubgroupEvent.group.name))
      elements.append(("Group ID", removeSubgroupEvent.group.identifier))

    case let updateContactEvent as CNChangeHistoryUpdateContactEvent:
      title = updateContactEvent.contact.fullName
      elements.append(("Contact Name", "\(updateContactEvent.contact.fullName)"))
      elements.append(("Contact ID", updateContactEvent.contact.identifier))

    case let updateGroupEvent as CNChangeHistoryUpdateGroupEvent:
      title = updateGroupEvent.group.name
      elements.append(("Group Name", updateGroupEvent.group.name))
      elements.append(("Group ID", updateGroupEvent.group.identifier))

    default:
      break
    }

    guard !elements.isEmpty else {
      return
    }

    let actionSheet = UIAlertController(title: "Copy to Clipboard", message: nil, preferredStyle: .actionSheet)
    if let title = title {
      actionSheet.title?.append("\n(\(title))")
    }

    elements.forEach {
      let stringToCopy = $0.1

      let action = UIAlertAction(title: $0.0, style: .default, handler: { _ in
        UIPasteboard.general.string = stringToCopy
      })


      actionSheet.addAction(action)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(cancelAction)

    present(actionSheet, animated: true, completion: nil)
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    dropDownView.view.isHidden = true
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    let width = view.frame.width / 3.0
    dropDownView.view.frame = CGRect(
      x: view.frame.maxX - 2 - width,
      y: navigationController?.navigationBar.frame.maxY ?? UIConstants.topSpacing,
      width: width,
      height: view.frame.maxY - dropDownView.view.frame.minY
    )
  }
}

// MARK: - UITableViewDataSource

extension HistoryVC: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredEvents.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)

    guard indexPath.row < filteredEvents.count else {
      return cell
    }

    let event = filteredEvents[indexPath.row]
    var content = cell.defaultContentConfiguration()

    content.attributedText = createCellTitle(event: event)
    content.textProperties.numberOfLines = 0

    cell.contentConfiguration = content

    return cell
  }

  private func createCellTitle(event: CNChangeHistoryEvent) -> NSAttributedString {
    let title = NSMutableAttributedString()

    switch event {
    case let addContactEvent as CNChangeHistoryAddContactEvent:
      title.append(header("\(CNChangeHistoryAddContactEvent.displayTitle)\n"))
      title.append(body("Name: \(addContactEvent.contact.fullName)\n"))
      title.append(subtext("(\(addContactEvent.contact.identifier))\n"))
      title.append(subtext("Container: \(String(describing: addContactEvent.containerIdentifier))"))

    case let addGroupEvent as CNChangeHistoryAddGroupEvent:
      title.append(header("\(CNChangeHistoryAddGroupEvent.displayTitle)\n"))
      title.append(body("Group: \(addGroupEvent.group.name)\n"))
      title.append(subtext("(\(addGroupEvent.group.identifier))\n"))
      title.append(subtext("Container: \(addGroupEvent.containerIdentifier)"))

    case let addContactToGroupEvent as CNChangeHistoryAddMemberToGroupEvent:
      title.append(header("\(CNChangeHistoryAddMemberToGroupEvent.displayTitle)p\n"))
      title.append(body("Name: \(addContactToGroupEvent.member.fullName)\n"))
      title.append(subtext("(\(addContactToGroupEvent.member.identifier))\n"))
      title.append(subtext("Group: \(addContactToGroupEvent.group.name)\n"))
      title.append(subtext("(\(addContactToGroupEvent.group.identifier))"))

    case let addSubgroupEvent as CNChangeHistoryAddSubgroupToGroupEvent:
      title.append(header("\(CNChangeHistoryAddSubgroupToGroupEvent.displayTitle)\n"))
      title.append(body("Subgroup: \(addSubgroupEvent.subgroup.name)\n"))
      title.append(subtext("(\(addSubgroupEvent.subgroup.identifier))\n"))
      title.append(body("Group: \(addSubgroupEvent.group.name)\n"))
      title.append(subtext("(\(addSubgroupEvent.group.identifier)\n"))

    case let deleteContactEvent as CNChangeHistoryDeleteContactEvent:
      title.append(header("\(CNChangeHistoryDeleteContactEvent.displayTitle)\n"))
      title.append(body("Contact Identifier: \(deleteContactEvent.contactIdentifier)"))

    case let deleteGroupEvent as CNChangeHistoryDeleteGroupEvent:
      title.append(header("\(CNChangeHistoryDeleteGroupEvent.displayTitle)\n"))
      title.append(body("Group Identifier: \(deleteGroupEvent.groupIdentifier)"))

    case is CNChangeHistoryDropEverythingEvent:
      title.append(header(CNChangeHistoryDropEverythingEvent.displayTitle))

    case let removeContactFromGroupEvent as CNChangeHistoryRemoveMemberFromGroupEvent:
      title.append(header("\(CNChangeHistoryRemoveMemberFromGroupEvent.displayTitle)\n"))
      title.append(body("Name: \(removeContactFromGroupEvent.member.fullName)\n"))
      title.append(subtext("(\(removeContactFromGroupEvent.member.identifier))\n"))
      title.append(body("Group: \(removeContactFromGroupEvent.group.name)\n"))
      title.append(subtext("(\(removeContactFromGroupEvent.group.identifier))"))

    case let removeSubgroupEvent as CNChangeHistoryRemoveSubgroupFromGroupEvent:
      title.append(header("\(CNChangeHistoryRemoveSubgroupFromGroupEvent.displayTitle)\n"))
      title.append(body("Subgroup: \(removeSubgroupEvent.subgroup.name))\n"))
      title.append(subtext("(\(removeSubgroupEvent.subgroup.identifier))\n"))
      title.append(body("Group: \(removeSubgroupEvent.group.name)\n"))
      title.append(subtext("(\(removeSubgroupEvent.group.identifier))"))

    case let updateContactEvent as CNChangeHistoryUpdateContactEvent:
      title.append(header("\(CNChangeHistoryUpdateContactEvent.displayTitle)\n"))
      title.append(body("Name: \(updateContactEvent.contact.fullName)\n"))
      title.append(subtext("(\(updateContactEvent.contact.identifier))"))

    case let updateGroupEvent as CNChangeHistoryUpdateGroupEvent:
      title.append(header("\(CNChangeHistoryUpdateGroupEvent.displayTitle)\n"))
      title.append(body("Group: \(updateGroupEvent.group.name)\n"))
      title.append(subtext("(\(updateGroupEvent.group.identifier))"))

    default:
      title.append(header(CNChangeHistoryEvent.displayTitle))
    }

    return title
  }

  private func header(_ string: String) -> NSAttributedString {
    let attributes = [
      NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)
    ]

    return NSAttributedString(string: string, attributes: attributes)
  }

  private func body(_ string: String) -> NSAttributedString {
    let attributes = [
      NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)
    ]

    return NSAttributedString(string: string, attributes: attributes)
  }

  private func subtext(_ string: String) -> NSAttributedString {
    let attributes = [
      NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)
    ]

    return NSAttributedString(string: string, attributes: attributes)
  }
}

// MARK: - UISearchResultsUpdating

extension HistoryVC: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    dropDownView.view.isHidden = true

    guard searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) else {
      filters.removeValue(forKey: .searchTextFilter)
      tableView.reloadData()
      return
    }

    filters[.searchTextFilter] = filterBySearchTextFilter
    tableView.reloadData()
  }
}

// MARK: - HistoryVCDropdownTableViewDelegate

extension HistoryVC: HistoryVCDropdownTableViewDelegate {
  func didSelectEventType(_ eventType: CNChangeHistoryEvent.Type) {
    let eventTypeFilter: (CNChangeHistoryEvent) -> Bool = {
      return type(of: $0) == eventType
    }

    navigationItem.rightBarButtonItem = filterBarButtonItem(filled: true)
    filters[.eventTypeFilter] = eventTypeFilter
    tableView.reloadData()
  }

  func didDeselectEventType() {
    navigationItem.rightBarButtonItem = filterBarButtonItem(filled: false)

    filters.removeValue(forKey: .eventTypeFilter)
    tableView.reloadData()
  }
}
