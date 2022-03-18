//
//  ContactParser.swift
//  ContactParser
//
//  Created by Allie Shuldman on 10/5/21.
//

import Foundation
import UIKit

class ContactListParser {
  struct ContactEntry: Decodable {
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: Int
    let id: String

    enum CodingKeys: String, CodingKey {
      case firstName = "First Name"
      case lastName = "Last Name"
      case email = "Email"
      case phoneNumber = "Phone"
      case id = "id"
    }
  }

  let inMemoryContacts: [Contact]

  init() {
    self.inMemoryContacts = Self.getContacts()
  }

  static let shared = ContactListParser()

  private static func getContacts() -> [Contact] {
    guard let path = Bundle.main.path(forResource: "csvjsonid", ofType: "json") else {
      return []
    }

    do {
      let url = URL(fileURLWithPath: path)
      let jsonData = try Data(contentsOf: url)
      let jsonResult = try JSONDecoder().decode([ContactEntry].self, from: jsonData)
      let array = jsonResult.map { Contact($0) }
      return array
    }
    catch {
      return []
    }
  }
}

extension Contact {
  init(_ contactEntry: ContactListParser.ContactEntry) {
    self.firstName = contactEntry.firstName
    self.lastName = contactEntry.lastName
    self.email = contactEntry.email
    self.phoneNumber = contactEntry.phoneNumber
    self.id = contactEntry.id
  }
}
