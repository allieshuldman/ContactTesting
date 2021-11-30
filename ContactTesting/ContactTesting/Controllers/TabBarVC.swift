//
//  TabBarVC.swift
//  TabBarVC
//
//  Created by Allie Shuldman on 11/21/21.
//

import Foundation
import UIKit

class TabBarVC: UITabBarController {
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    edgesForExtendedLayout = []

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

    viewControllers = [manageContactsVC, searchConfigVC, historySelectionVC]
    selectedIndex = 0

    tabBar.backgroundColor = .veryLightGray
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
