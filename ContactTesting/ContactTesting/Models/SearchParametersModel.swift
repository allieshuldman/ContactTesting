//
//  SearchParametersModel.swift
//  SearchParametersModel
//
//  Created by Allie Shuldman on 10/7/21.
//

import Foundation

public struct SearchParameters {
  enum SearchField: CaseIterable {
    case indexed(SearchFieldIndexed)
    case nonIndexed(SearchFieldNonIndexed)

    static var allCases: [SearchParameters.SearchField] {
      var indexed = SearchFieldIndexed.allCases.map { SearchField.indexed($0) }
      let nonIndexed = SearchFieldNonIndexed.allCases.map { SearchField.nonIndexed($0) }
      indexed.append(contentsOf: nonIndexed)
      return indexed
    }

    var rawValue: String {
      switch self {
      case .indexed(let indexedParam):
        return "\(indexedParam.rawValue) (indexed)"
      case .nonIndexed(let nonIndexedParam):
        return "\(nonIndexedParam.rawValue) (not indexed)"
      }
    }
  }

  enum SearchFieldIndexed: String, CaseIterable {
    case identifier = "Identifier"
    case name = "Name"
    case phoneNumber = "Phone Number"
    case emailAddress = "Email Address"
  }

  enum SearchFieldNonIndexed: String, CaseIterable {
    case url = "URL"
  }

  let searchForExistingContact: Bool
  let searchField: SearchField
  let searchAmount: Int
}
