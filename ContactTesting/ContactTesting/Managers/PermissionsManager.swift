//
//  PermissionsManager.swift
//  ContactTesting
//
//  Created by Allie Shuldman on 3/17/22.
//

import Foundation

class PermissionsManager {
  public static var shared = PermissionsManager()

  private let store = CNContactStore()

  private var authorizationStatus: CNAuthorizationStatus {
    return CNContactStore.authorizationStatus(for: .contacts)
  }

  private var shouldPromptForAccess: Bool {
    switch authorizationStatus {
    case .notDetermined, .restricted, .denied:
      return true
    case .authorized:
      return false
    default:
      return true
    }
  }

  func promptForAccessIfNeeded(completion: @escaping (Bool) -> Void) {
    if shouldPromptForAccess {
      store.requestAccess(for: .contacts, completionHandler: { granted, _ in
        completion(granted)
      })
    }
    else {
      completion(true)
    }
  }
}
