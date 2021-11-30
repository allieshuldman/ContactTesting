//
//  SideBarVC.swift
//  SideBarVC
//
//  Created by Allie Shuldman on 11/19/21.
//

import Foundation

class SideBarVC: UIViewController {
  enum Action: String, CaseIterable {
    case addContacts = "Add Contacts"
    case deleteContacts = "Delete Contacts"
    case viewHistory = "View History"
  }

  static let cellIdentifier = "SideBarVCCell"
  let actions: [Action] = Action.allCases
}

extension SideBarVC: UITableViewDelegate {

}

extension SideBarVC: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return actions.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)

    guard indexPath.row < actions.count else {
      return cell
    }

    var config = cell.defaultContentConfiguration()
    config.text = actions[indexPath.row].rawValue

    cell.contentConfiguration = config

    return cell
  }
}
