//
//  ContactModel.swift
//  ContactModel
//
//  Created by Allie Shuldman on 10/5/21.
//

struct Contact: Hashable {
  let firstName: String
  let lastName: String
  let email: String
  let phoneNumber: Int
  let id: String

  var url: String {
    return id
  }

  var fullName: String {
    return "\(firstName) \(lastName)"
  }

  public var description: String {
    return "Name: \(firstName) \(lastName)\nEmail: \(email)\nPhone: \(phoneNumber)\nURL: \(url)"
  }
}
