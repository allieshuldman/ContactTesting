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
    case hiddenPredicate(SearchFieldHiddenPredicate)

    static var allCases: [SearchParameters.SearchField] {
      var indexed = SearchFieldIndexed.allCases.map { SearchField.indexed($0) }
      let nonIndexed = SearchFieldNonIndexed.allCases.map { SearchField.nonIndexed($0) }
      let hiddenPredicate = SearchFieldHiddenPredicate.allCases.map { SearchField.hiddenPredicate($0) }
      indexed.append(contentsOf: nonIndexed)
      indexed.append(contentsOf: hiddenPredicate)
      return indexed
    }

    var rawValue: String {
      switch self {
      case .indexed(let indexedParam):
        return "\(indexedParam.rawValue) (indexed)"
      case .nonIndexed(let nonIndexedParam):
        return "\(nonIndexedParam.rawValue) (not indexed)"
      case .hiddenPredicate(let hiddenParam):
        return "\(hiddenParam.rawValue) (hidden predicate)"
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

  enum SearchFieldHiddenPredicate: String, CaseIterable {
    case url = "URL"
  }

  let searchField: SearchField
  let searchAmount: Int
}
