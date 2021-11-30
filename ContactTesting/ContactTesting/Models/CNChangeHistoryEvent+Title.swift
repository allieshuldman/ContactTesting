//
//  CNChangeHistoryEvent+Title.swift
//  CNChangeHistoryEvent+Title
//
//  Created by Allie Shuldman on 11/16/21.
//

extension CNChangeHistoryEvent {
  class var displayTitle: String {
    switch self {
    case is CNChangeHistoryAddContactEvent.Type:
      return "Add Contact"

    case is CNChangeHistoryAddGroupEvent.Type:
      return "Add Group"

    case is CNChangeHistoryAddMemberToGroupEvent.Type:
      return "Add Contact to Group"

    case is CNChangeHistoryAddSubgroupToGroupEvent.Type:
      return "Add Subgroup to Group"

    case is CNChangeHistoryDeleteContactEvent.Type:
      return "Delete Contact"

    case is CNChangeHistoryDeleteGroupEvent.Type:
      return "Delete Group"

    case is CNChangeHistoryDropEverythingEvent.Type:
      return "Drop Everything"

    case is CNChangeHistoryRemoveMemberFromGroupEvent.Type:
      return "Remove Contact from Group"

    case is CNChangeHistoryRemoveSubgroupFromGroupEvent.Type:
      return "Remove Subgroup from Group"

    case is CNChangeHistoryUpdateContactEvent.Type:
      return "Update Contact"

    case is CNChangeHistoryUpdateGroupEvent.Type:
      return "Update Group"

    default:
      return "Unknown Event"
    }
  }
}
