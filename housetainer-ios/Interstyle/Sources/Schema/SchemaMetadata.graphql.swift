// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == Interstyle.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == Interstyle.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == Interstyle.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == Interstyle.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return Interstyle.Objects.Query
    case "membersConnection": return Interstyle.Objects.MembersConnection
    case "membersEdge": return Interstyle.Objects.MembersEdge
    case "members": return Interstyle.Objects.Members
    case "buddies": return Interstyle.Objects.Buddies
    case "event_bookmarks": return Interstyle.Objects.Event_bookmarks
    case "event_comments": return Interstyle.Objects.Event_comments
    case "events": return Interstyle.Objects.Events
    case "house_comments": return Interstyle.Objects.House_comments
    case "houses": return Interstyle.Objects.Houses
    case "invitations": return Interstyle.Objects.Invitations
    case "notifications": return Interstyle.Objects.Notifications
    case "reports": return Interstyle.Objects.Reports
    case "waitings": return Interstyle.Objects.Waitings
    case "invitationsConnection": return Interstyle.Objects.InvitationsConnection
    case "invitationsEdge": return Interstyle.Objects.InvitationsEdge
    case "housesConnection": return Interstyle.Objects.HousesConnection
    case "housesEdge": return Interstyle.Objects.HousesEdge
    case "PageInfo": return Interstyle.Objects.PageInfo
    case "eventsConnection": return Interstyle.Objects.EventsConnection
    case "eventsEdge": return Interstyle.Objects.EventsEdge
    case "event_bookmarksConnection": return Interstyle.Objects.Event_bookmarksConnection
    case "event_bookmarksEdge": return Interstyle.Objects.Event_bookmarksEdge
    case "Mutation": return Interstyle.Objects.Mutation
    case "event_bookmarksDeleteResponse": return Interstyle.Objects.Event_bookmarksDeleteResponse
    case "event_bookmarksInsertResponse": return Interstyle.Objects.Event_bookmarksInsertResponse
    case "membersUpdateResponse": return Interstyle.Objects.MembersUpdateResponse
    case "invitationsInsertResponse": return Interstyle.Objects.InvitationsInsertResponse
    case "eventsInsertResponse": return Interstyle.Objects.EventsInsertResponse
    case "housesInsertResponse": return Interstyle.Objects.HousesInsertResponse
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
