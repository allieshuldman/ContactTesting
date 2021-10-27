//
//  ContactExportManager.swift
//  ContactExportManager
//
//  Created by Allie Shuldman on 10/5/21.
//

import Contacts
import Foundation

class ContactStoreManager {
  // MARK: - Result Types

  enum AddResult {
    case success
    case couldNotCreateGroup
    case couldNotAddContacts
    case failure(String)

    var description: String {
      switch self {
      case .success:
        return "Successfully added contacts"
      case .couldNotCreateGroup:
        return "Failed to create group"
      case .couldNotAddContacts:
        return "Failed to add contacts"
      case .failure(let error):
        return "Generic failure: \(error)"
      }
    }
  }

  enum DeleteResult {
    case success
    case groupDoesntExist
    case couldNotFetchContacts
    case couldNotDeleteGroup
    case couldNotDeleteContacts
    case failure(String)

    var description: String {
      switch self {
      case .success:
        return "Successfully deleted group"
      case .groupDoesntExist:
        return "Group already deleted"
      case .failure(let error):
        return "Failed to delete group \(error)"
      case .couldNotFetchContacts:
        return "Could not fetch contacts"
      case .couldNotDeleteGroup:
        return "Could not delete group"
      case .couldNotDeleteContacts:
        return "Could not delete contacts"
      }
    }
  }

  enum SearchResult {
    case success([CNContact], TimeInterval)
    case failure(SearchError)

    enum SearchError {
      case noIdentifier
      case enumerationError
      case fetchError

      var description: String {
        switch self {
        case .noIdentifier:
          return "Could not find identifier for contact"
        case .enumerationError:
          return "Could not enumerate contacts"
        case .fetchError:
          return "Could not fetch contacts"
        }
      }
    }
  }

  // MARK: - Contact Store Helpers

  static let shared = ContactStoreManager()
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
      ContactStoreManager.shared.store.requestAccess(for: .contacts, completionHandler: {granted, _ in
        completion(granted)
      })
    }
    else {
      completion(true)
    }
  }

  private func getTestGroupId() -> String? {
    if let storedValue = PersistentDataController.shared.getTestGroupId() {
      return storedValue
    }

    return getTestGroup(createIfDoesntExist: false)?.identifier
  }

  private func getTestGroup(createIfDoesntExist: Bool) -> CNGroup? {
    let groupName = "Contact-Testing"
    do {
      let groups = try store.groups(matching: nil)
      if let testGroup = groups.first(where: { $0.name == groupName }) {
        return testGroup
      }
      else if createIfDoesntExist{
        do {
          let newGroup = CNMutableGroup()
          newGroup.name = groupName

          let saveRequest = CNSaveRequest()
          saveRequest.add(newGroup, toContainerWithIdentifier: nil)

          try store.execute(saveRequest)

          return newGroup
        }
        catch {
          print("Error saving new group \(error.localizedDescription)")
        }
      }
    }
    catch {
      print("Error looking for group \(error.localizedDescription)")
    }

    return nil
  }

  // MARK: - Adding/Deleting from device

  func addContactsToDevice(_ contacts: [Contact], progressIndicatorHandler: ((Float) -> Void)?) -> AddResult {
    guard let group = getTestGroup(createIfDoesntExist: true) else {
      return .couldNotCreateGroup
    }

    var contactsAdded = 0

    for contactBatch in createBatches(allContacts: contacts, batchSize: PersistentDataController.shared.batchSize) {
      let saveRequest = CNSaveRequest()
      var idMap = [String: String]()

      contactBatch.forEach {
        let cnContact = CNMutableContact($0)
        idMap[$0.id] = cnContact.identifier
        saveRequest.add(cnContact, toContainerWithIdentifier: nil)
        saveRequest.addMember(cnContact, to: group)
      }

      PersistentDataController.shared.addIds(contactIdToDeviceIdMap: idMap)

      do {
        try store.execute(saveRequest)
        PersistentDataController.shared.storeTestGroupId(group.identifier)
        PersistentDataController.shared.incrementExportedCount(by: contactBatch.count)

        contactsAdded += contactBatch.count
        progressIndicatorHandler?(Float(contactsAdded) / Float(contacts.count))
      }
      catch {
        return .couldNotAddContacts
      }
    }

    return .success
  }

  func deleteContacts(progressIndicatorHandler: ((Float) -> Void)?) -> DeleteResult {
    guard let group = getTestGroup(createIfDoesntExist: false), let mutableGroup = group.mutableCopy() as? CNMutableGroup else {
      return .groupDoesntExist
    }

    let predicate = CNContact.predicateForContactsInGroup(withIdentifier: mutableGroup.identifier)

    var contacts: [CNContact]

    do {
      contacts = try store.unifiedContacts(matching: predicate, keysToFetch: [])
    }
    catch {
      return .couldNotFetchContacts
    }

    var contactsDeleted = 0

    for contactBatch in createBatches(allContacts: contacts, batchSize: PersistentDataController.shared.batchSize) {
      let deleteContactsRequest = CNSaveRequest()
      for cnContact in contactBatch {
        if let mutableContact = cnContact.mutableCopy() as? CNMutableContact {
          deleteContactsRequest.delete(mutableContact)
        }
      }
      do {
        try store.execute(deleteContactsRequest)
        contactsDeleted += contactBatch.count
        progressIndicatorHandler?(Float(contactsDeleted) / Float(contacts.count))
      }
      catch {
        return .couldNotDeleteContacts
      }
    }

    let deleteGroupRequest = CNSaveRequest()
    deleteGroupRequest.delete(mutableGroup)

    do {
      try store.execute(deleteGroupRequest)
    }
    catch {
      return .couldNotDeleteGroup
    }

    PersistentDataController.shared.clearData()
    return .success
  }

  func deleteAllContacts(progressIndicatorHandler: ((Float) -> Void)?) -> DeleteResult {
    var contacts = [CNContact]()

    do {
      let containers = try store.containers(matching: nil)
      for container in containers {
        let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
        contacts += try store.unifiedContacts(matching: fetchPredicate, keysToFetch: [])
      }
    }
    catch {
      return .couldNotFetchContacts
    }

    var contactsDeleted = 0

    for contactBatch in createBatches(allContacts: contacts, batchSize: PersistentDataController.shared.batchSize) {
      let deleteContactsRequest = CNSaveRequest()
      for cnContact in contactBatch {
        if let mutableContact = cnContact.mutableCopy() as? CNMutableContact {
          deleteContactsRequest.delete(mutableContact)
        }
      }
      do {
        try store.execute(deleteContactsRequest)
        contactsDeleted += contactBatch.count
        progressIndicatorHandler?(Float(contactsDeleted) / Float(contacts.count))
      }
      catch {
        return .couldNotDeleteContacts
      }
    }

    if let group = getTestGroup(createIfDoesntExist: false), let mutableGroup = group.mutableCopy() as? CNMutableGroup {
      let deleteGroupRequest = CNSaveRequest()
      deleteGroupRequest.delete(mutableGroup)

      do {
        try store.execute(deleteGroupRequest)
      }
      catch {
        return .couldNotDeleteGroup
      }
    }

    PersistentDataController.shared.clearData()
    return .success
  }

  func createBatches<T>(allContacts: [T], batchSize: Int) -> [[T]] {
    var batches = [[T]]()
    let numberOfBatches = Int((Double(allContacts.count) / Double(batchSize)).rounded(.up))

    for batchIndex in 0..<numberOfBatches {
      let startIndex = batchSize * batchIndex
      let endIndex = min(allContacts.count, startIndex + batchSize)
      batches.append(Array(allContacts[startIndex..<endIndex]))
    }

    return batches
  }

  // MARK: - Fetching from device

  func getNumberOfTestContactsOnDevice() -> Int {
    guard let group = getTestGroup(createIfDoesntExist: false) else {
      return 0
    }

    let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)

    do {
      let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: [])

      // In case the app was deleted but the contacts were not
      if contacts.count != PersistentDataController.shared.getExportedCount() {
        PersistentDataController.shared.setExportCount(contacts.count)
      }

      return contacts.count
    }
    catch {
      return 0
    }
  }

  func getNumberOfContactsOnDevice() -> Int {
    do {
      let containers = try store.containers(matching: nil)
      var totalContacts = 0
      for container in containers {
        let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
        let contactsInContainer = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: [])
        totalContacts += contactsInContainer.count
      }
      return totalContacts
    }
    catch {
      return 0
    }
  }

  // MARK: - Search

  func searchForContact(_ contact: Contact, field: SearchParameters.SearchField) -> SearchResult {
    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactUrlAddressesKey] as [CNKeyDescriptor]

    switch field {
    case .indexed(let indexedField):
      var predicate: NSPredicate

      switch indexedField {
      case .identifier:
        if let identifier = PersistentDataController.shared.getDeviceId(contactId: contact.id) {
          predicate = CNContact.predicateForContacts(withIdentifiers: [identifier])
        }
        else {
          return .failure(.noIdentifier)
        }
      case .name:
        predicate = CNContact.predicateForContacts(matchingName: contact.fullName)
      case .phoneNumber:
        predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: String(contact.phoneNumber)))
      case .emailAddress:
        predicate = CNContact.predicateForContacts(matchingEmailAddress: contact.email)
      }

      return search(using: predicate, keys: keysToFetch)

    case .nonIndexed(let nonIndexedField):
      return enumerationSearch(contact: contact, keys: keysToFetch, field: nonIndexedField)

    case .hiddenPredicate(let hidden):
      switch hidden {
      case .url:
        return search(using: CNContact.predicateForContacts(matchingURL: contact.url), keys: keysToFetch)
      }
    }
  }

  private func search(using predicate: NSPredicate, keys: [CNKeyDescriptor]) -> SearchResult {
    do {
      let startTime = Date()
      let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
      let endTime = Date()
      let searchTime = endTime.timeIntervalSince(startTime)
      return .success(contacts, searchTime)
    }
    catch {
      return .failure(.fetchError)
    }
  }

  private func enumerationSearch(contact: Contact, keys: [CNKeyDescriptor], field: SearchParameters.SearchFieldNonIndexed) -> SearchResult {
    let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
    var fetchedContacts = [CNContact]()
    do {
      let startTime = Date()
      try store.enumerateContacts(with: fetchRequest) { enumeratedContact, stop in
        switch field {
        case .url:
          let containsUrl = enumeratedContact.urlAddresses.contains {
            $0.label == "Test" && $0.value as String == contact.url
          }

          if containsUrl {
            fetchedContacts.append(enumeratedContact)
            stop.pointee = true
          }
        }
      }
      let endTime = Date()
      let searchTime = endTime.timeIntervalSince(startTime)

      return .success(fetchedContacts, searchTime)
    }
    catch {
      return .failure(.enumerationError)
    }
  }
}

// MARK: - CNMutableContact

extension CNMutableContact {
  convenience init(_ contact: Contact) {
    self.init()

    givenName = contact.firstName
    familyName = contact.lastName
    emailAddresses = [CNLabeledValue(label: "work", value: NSString(string: contact.email))]
    phoneNumbers = [CNLabeledValue(label: "home", value: CNPhoneNumber(stringValue: String(contact.phoneNumber)))]
    urlAddresses = [CNLabeledValue(label: "Test", value: NSString(string: contact.id))]
  }
}
