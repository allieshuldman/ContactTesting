//
//  CNContact+FullName.swift
//  CNContact+FullName
//
//  Created by Allie Shuldman on 11/16/21.
//

extension CNContact {
  var fullName: String {
    return givenName + " " + familyName
  }
}
