//
//  RandomContactGenerator.swift
//  RandomContactGenerator
//
//  Created by Allie Shuldman on 10/15/21.
//

import Foundation

struct RandomContactGenerator {
  static func generate() -> Contact {
    let firstName = Self.randomStringGenerator(length: 7)
    let lastName = Self.randomStringGenerator(length: 10)

    return Contact(
      firstName: firstName,
      lastName: lastName,
      email: "\(firstName).\(lastName)@fakeemail.com",
      phoneNumber: Int.random(in: 1001001000...9999999999),
      id: Self.randomStringGenerator(length: 51)
    )
  }

  private static let letters = "abcdefghijklmnopqrstuvwxyz"
  private static func randomStringGenerator(length: Int) -> String {
    return String((0..<length).compactMap{ _ in Self.letters.randomElement() })
  }
}
