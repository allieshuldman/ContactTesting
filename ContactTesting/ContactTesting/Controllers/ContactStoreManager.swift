//
//  ContactExportManager.swift
//  ContactExportManager
//
//  Created by Allie Shuldman on 10/5/21.
//

import Foundation
import Contacts

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

  func addContactsToDevice(_ contacts: [Contact]) -> AddResult {
    guard let group = getTestGroup(createIfDoesntExist: true) else {
      return .couldNotCreateGroup
    }

    let saveRequest = CNSaveRequest()
    var idMap = [String: String]()

    contacts.forEach {
      let cnContact = CNMutableContact($0)
      idMap[$0.id] = cnContact.identifier
      saveRequest.add(cnContact, toContainerWithIdentifier: nil)
      saveRequest.addMember(cnContact, to: group)
    }

    PersistentDataController.shared.addIds(contactIdToDeviceIdMap: idMap)

    do {
      try store.execute(saveRequest)
      PersistentDataController.shared.updateExportedCount(contacts.count)
      PersistentDataController.shared.storeTestGroupId(group.identifier)
      return .success
    }
    catch {
      return .couldNotAddContacts
    }
  }

  func deleteContacts() -> DeleteResult {
    guard let group = getTestGroup(createIfDoesntExist: false), let mutableGroup = group.mutableCopy() as? CNMutableGroup else {
      return .groupDoesntExist
    }

    let predicate = CNContact.predicateForContactsInGroup(withIdentifier: mutableGroup.identifier)
    let deleteContactsRequest = CNSaveRequest()

    do {
      let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: [])

      for cnContact in contacts {
        if let mutableContact = cnContact.mutableCopy() as? CNMutableContact {
          deleteContactsRequest.delete(mutableContact)
        }
      }
    }
    catch {
      return .couldNotFetchContacts
    }

    do {
      try store.execute(deleteContactsRequest)
      PersistentDataController.shared.clearData()
    }
    catch {
      return .couldNotDeleteContacts
    }

    let deleteGroupRequest = CNSaveRequest()
    deleteGroupRequest.delete(mutableGroup)

    do {
      try store.execute(deleteGroupRequest)
    }
    catch {
      return .couldNotDeleteGroup
    }

    return .success
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
        PersistentDataController.shared.updateExportedCount(contacts.count)
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

  func searchForContact(_ contact: Contact, location: SearchParameters.SearchLocation, field: SearchParameters.SearchField) -> [CNContact] {
    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactUrlAddressesKey] as [CNKeyDescriptor]

    let groupPredicate: NSPredicate? = {
      switch location {
      case .testGroup:
        guard let groupId = getTestGroupId() else {
          return nil
        }

        return CNContact.predicateForContactsInGroup(withIdentifier: groupId)
      case .wholeContainer:
        return nil
      }
    }()

    let fieldPredicate: NSPredicate? = {
      switch field {
      case .indexed(let indexedField):
        switch indexedField {
        case .identifier:
          if let identifier = PersistentDataController.shared.getDeviceId(contactId: contact.id) {
            return CNContact.predicateForContacts(withIdentifiers: [identifier])
          }
          return nil
        case .name:
          return CNContact.predicateForContacts(matchingName: contact.fullName)
        case .phoneNumber:
          return CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: String(contact.phoneNumber)))
        case .emailAddress:
          return CNContact.predicateForContacts(matchingEmailAddress: contact.email)
        }
      case .nonIndexed:
        return nil
      }
    }()

    let predicates = [groupPredicate, fieldPredicate].compactMap { $0 }

    switch field {
    case .indexed:
      return searchOnIndexedField(keys: keysToFetch, predicates: predicates)
    case .nonIndexed(let nonIndexedParam):
      return searchOnNonIdexedField(contact: contact, keys: keysToFetch, predicates: predicates, field: nonIndexedParam)
    }
  }

  private func searchOnIndexedField(keys: [CNKeyDescriptor], predicates: [NSPredicate]) -> [CNContact] {
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

    do {
      let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
      return contacts
    }
    catch {
      return []
    }
  }

  private func searchOnNonIdexedField(contact: Contact, keys: [CNKeyDescriptor], predicates: [NSPredicate], field: SearchParameters.SearchFieldNonIndexed) -> [CNContact] {
    let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    fetchRequest.predicate = predicate

    var fetchedContacts = [CNContact]()
    do {
      try store.enumerateContacts(with: fetchRequest) { enumeratedContact, stop in
        switch field {
        case .url:
          let containsUrl = enumeratedContact.urlAddresses.contains {
            $0.label == "Test" && $0.value as String == contact.url
          }

          if containsUrl {
            fetchedContacts.append(enumeratedContact)
          }
        }
      }

      return fetchedContacts
    }
    catch {
      return []
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
