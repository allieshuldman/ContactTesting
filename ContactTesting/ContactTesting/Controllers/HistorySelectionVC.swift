//
//  HistorySelectionVC.swift
//  HistorySelectionVC
//
//  Created by Allie Shuldman on 11/19/21.
//

import Foundation
import UIKit

class HistorySelectionVC: UIViewController {
  enum HistoryType: String, CaseIterable {
    case all = "All History"
    case sinceLastAdd = "Since Last Add"
    case sinceLastDelete = "Since Last Delete"
    case sinceLastAddOrDelete = "Since Last Add or Delete"
    case sinceLastAppOpen = "Since Last App Open"
    case allExcludingTestApp = "All History Excluding Test App"
  }

  let scrollView = UIScrollView()
  var buttons = [BlueButton]()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    title = "History"

    view.addSubview(scrollView)

    HistoryType.allCases.forEach { type in
      let button = BlueButton(frame: .zero)
      button.setTitle(type.rawValue, for: .normal)
      button.addTarget(self, action: #selector(handleButtonTapped(sender:)), for: .touchUpInside)
      buttons.append(button)
      scrollView.addSubview(button)
    }
  }

  @objc private func handleButtonTapped(sender: UIButton) {
    guard let title = sender.titleLabel?.text, let historyType = HistoryType(rawValue: title) else {
      return
    }

    let history: [CNChangeHistoryEvent]? = {
      switch historyType {
      case .all:
        return ContactStoreManager.shared.getAllHistory()

      case .sinceLastAdd:
        guard let token = PersistentDataController.shared.lastAddChangeHistoryToken else {
          return nil
        }
        return ContactStoreManager.shared.getHistory(startingAt: token)

      case .sinceLastDelete:
        guard let token = PersistentDataController.shared.lastDeleteChangeHistoryToken else {
          return nil
        }
        return ContactStoreManager.shared.getHistory(startingAt: token)

      case .sinceLastAddOrDelete:
        guard let token = PersistentDataController.shared.lastStoreInteractionKey else {
          return nil
        }
        return ContactStoreManager.shared.getHistory(startingAt: token)

      case .sinceLastAppOpen:
        guard let token = PersistentDataController.shared.lastAppOpenChangeHistoryKey else {
          return nil
        }
        return ContactStoreManager.shared.getHistory(startingAt: token)

      case .allExcludingTestApp:
        return ContactStoreManager.shared.getAllHistory(excludingAuthors: [ContactConstants.transactionAuthor])
      }
    }()

    let vc: UIViewController = {
      if let history = history, !history.isEmpty {
        return HistoryVC(historyEvents: history)
      }
      else {
        return EmptyHistoryVC()
      }
    }()

    navigationController?.pushViewController(vc, animated: true)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    scrollView.frame = CGRect(
      x: 0,
      y: navigationController?.navigationBar.frame.maxY ?? 0,
      width: view.frame.width,
      height: (tabBarController?.tabBar.frame.minY ?? view.frame.height) - (navigationController?.navigationBar.frame.maxY ?? 0)
    )

    let totalButtonHeight = CGFloat(buttons.count) * (UIConstants.buttonHeight + UIConstants.topSpacing) + UIConstants.topSpacing
    let startingY: CGFloat = max(
      (scrollView.frame.height - totalButtonHeight) / 2.0,
      UIConstants.topSpacing
    )

    for (index, button) in buttons.enumerated() {
      button.frame = CGRect(
        x: UIConstants.leftInset,
        y: startingY + (CGFloat(index) * (UIConstants.topSpacing + UIConstants.buttonHeight)),
        width: scrollView.frame.width - 2 * UIConstants.leftInset,
        height: UIConstants.buttonHeight
      )
    }

    scrollView.contentSize = CGSize(width: view.frame.width, height: (buttons.last?.frame.maxY ?? view.frame.height) + UIConstants.topSpacing)
  }
}
