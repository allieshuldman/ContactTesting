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
    static let groupId = "groupId"
    static let exportCountKey = "exportCountKey"
    static let contactIdMapKey = "contactIdMapKey"
  }

  let store = UserDefaults.standard

  // MARK: - Clear Data

  func clearData() {
    resetGroupId()
    resetExportedCount()
    resetIdMap()
  }

  // MARK: - Group Id

  func getTestGroupId() -> String? {
    return store.value(forKey: Key.groupId) as? String
  }

  func storeTestGroupId(_ id: String) {
    store.set(id, forKey: Key.groupId)
  }

  func resetGroupId() {
    store.removeObject(forKey: Key.groupId)
  }

  // MARK: - Export Count

  func getExportedCount() -> Int {
    return store.value(forKey: Key.exportCountKey) as? Int ?? 0
  }

  func updateExportedCount(_ count: Int) {
    store.set(getExportedCount() + count, forKey: Key.exportCountKey)
  }

  func resetExportedCount() {
    store.removeObject(forKey: Key.exportCountKey)
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

  func resetIdMap() {
    store.removeObject(forKey: Key.contactIdMapKey)
  }
}
