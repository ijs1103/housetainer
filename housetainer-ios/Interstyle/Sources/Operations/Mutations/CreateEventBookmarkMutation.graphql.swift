// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateEventBookmarkMutation: GraphQLMutation {
  public static let operationName: String = "CreateEventBookmark"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateEventBookmark($id: UUID!, $ownerId: UUID!, $createdAt: Datetime!) { insertIntoevent_bookmarksCollection( objects: [{ owner_id: $ownerId, event_id: $id, created_at: $createdAt }] ) { __typename affectedCount } }"#
    ))

  public var id: UUID
  public var ownerId: UUID
  public var createdAt: Datetime

  public init(
    id: UUID,
    ownerId: UUID,
    createdAt: Datetime
  ) {
    self.id = id
    self.ownerId = ownerId
    self.createdAt = createdAt
  }

  public var __variables: Variables? { [
    "id": id,
    "ownerId": ownerId,
    "createdAt": createdAt
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("insertIntoevent_bookmarksCollection", InsertIntoevent_bookmarksCollection?.self, arguments: ["objects": [[
        "owner_id": .variable("ownerId"),
        "event_id": .variable("id"),
        "created_at": .variable("createdAt")
      ]]]),
    ] }

    /// Adds one or more `event_bookmarks` records to the collection
    public var insertIntoevent_bookmarksCollection: InsertIntoevent_bookmarksCollection? { __data["insertIntoevent_bookmarksCollection"] }

    /// InsertIntoevent_bookmarksCollection
    ///
    /// Parent Type: `Event_bookmarksInsertResponse`
    public struct InsertIntoevent_bookmarksCollection: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Event_bookmarksInsertResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("affectedCount", Int.self),
      ] }

      /// Count of the records impacted by the mutation
      public var affectedCount: Int { __data["affectedCount"] }
    }
  }
}
