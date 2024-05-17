// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteEventBookmarkMutation: GraphQLMutation {
  public static let operationName: String = "DeleteEventBookmark"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteEventBookmark($id: UUID!) { deleteFromevent_bookmarksCollection(filter: { event_id: { eq: $id } }) { __typename affectedCount } }"#
    ))

  public var id: UUID

  public init(id: UUID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("deleteFromevent_bookmarksCollection", DeleteFromevent_bookmarksCollection.self, arguments: ["filter": ["event_id": ["eq": .variable("id")]]]),
    ] }

    /// Deletes zero or more records from the `event_bookmarks` collection
    public var deleteFromevent_bookmarksCollection: DeleteFromevent_bookmarksCollection { __data["deleteFromevent_bookmarksCollection"] }

    /// DeleteFromevent_bookmarksCollection
    ///
    /// Parent Type: `Event_bookmarksDeleteResponse`
    public struct DeleteFromevent_bookmarksCollection: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Event_bookmarksDeleteResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("affectedCount", Int.self),
      ] }

      /// Count of the records impacted by the mutation
      public var affectedCount: Int { __data["affectedCount"] }
    }
  }
}
