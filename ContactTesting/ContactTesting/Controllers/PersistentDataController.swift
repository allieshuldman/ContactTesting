//
//  PersistentDataController.swift
//  PersistentDataController
//
//  Created by Allie Shuldman on 10/12/21.
//

import Foundation

class PersistentDataController {
  static let shared = PersistentDataController()

  enum Key {
    static let exportCountKey = "exportCountKey"
    static let contactIdMapKey = "contactIdMapKey"
  }

  let store = UserDefaults.standard

  // MARK: - Export Count

  func getExportedCount() -> Int {
    return store.value(forKey: Key.exportCountKey) as? Int ?? 0
  }

  func updateExportedCount(_ count: Int) {
    store.set(getExportedCount() + count, forKey: Key.exportCountKey)
  }

  func resetExportedCount() {
    store.set(0, forKey: Key.exportCountKey)
  }

  // MARK: - ContactId/DeviceId map

  func addIds(contactIdToDeviceIdMap: [String: String]) {
    var dict = store.value(forKey: Key.contactIdMapKey) as? [String: String] ?? [:]
    for (contactId, deviceId) in contactIdToDeviceIdMap {
      dict[contactId] = deviceId
    }
    store.set(dict, forKey: Key.contactIdMapKey)
  }

  func getDeviceId(contactId: String) -> String? {
    guard let dict = store.value(forKey: Key.contactIdMapKey) as? [String: String] else {
      return nil
    }

    return dict[contactId]
  }

  func removeIds() {
    store.set([:], forKey: Key.contactIdMapKey)
  }
}
