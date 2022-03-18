//
//  TabBarVC.swift
//  TabBarVC
//
//  Created by Allie Shuldman on 11/21/21.
//

import Foundation
import UIKit

class TabBarVC: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let _ = ContactListParser.shared

    self.view.backgroundColor = .white

    PermissionsManager.shared.promptForAccessIfNeeded() { success in
      guard success else {
        return
      }

      DispatchQueue.main.async {
        let manageContactsVCTabBarItem = UITabBarItem(title: "Manage Contacts", image: UIImage(systemName: "person.crop.circle.badge.plus"), selectedImage: UIImage(systemName: "person.crop.circle.fill.badge.plus"))
        let manageContactsVC = UINavigationController(rootViewController: ManageContactsVC())
        manageContactsVC.tabBarItem = manageContactsVCTabBarItem
        manageContactsVC.navigationBar.backgroundColor = .veryLightGray

        let searchConfigVCTabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass.circle"), selectedImage: UIImage(systemName: "magnifyingglass.circle.fill"))
        let searchConfigVC = UINavigationController(rootViewController: SearchConfigVC())
        searchConfigVC.tabBarItem = searchConfigVCTabBarItem
        searchConfigVC.navigationBar.backgroundColor = .veryLightGray

        let historySelectionVCTabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock.fill"))
        let historySelectionVC = UINavigationController(rootViewController: HistorySelectionVC())
        historySelectionVC.tabBarItem = historySelectionVCTabBarItem
        historySelectionVC.navigationBar.backgroundColor = .veryLightGray

        let fullTestConfigVCTabBarItem = UITabBarItem(title: "Full Test", image: UIImage(systemName: "speedometer"), selectedImage: UIImage(systemName: "speedometer"))
        let fullTestConfigVC = UINavigationController(rootViewController: FullTestConfigVC())
        fullTestConfigVC.tabBarItem = fullTestConfigVCTabBarItem
        fullTestConfigVC.navigationBar.backgroundColor = .veryLightGray

        self.viewControllers = [manageContactsVC, fullTestConfigVC, searchConfigVC, historySelectionVC]
        self.selectedIndex = 0

        self.tabBar.backgroundColor = .veryLightGray
      }
    }
  }
}
