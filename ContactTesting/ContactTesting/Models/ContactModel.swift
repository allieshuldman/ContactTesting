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

var fakeContact = Contact(firstName: "Allie", lastName: "Shuldman", email: "allieshuldman@fakeemail.com", phoneNumber: 2032032203, id: "17212e3c5436e2c71e5aa0530907e01f5ab064abddf8ace6119c449ba829f8e6516677d13a4380711889cbdb4fb1f00edcf6f5")
