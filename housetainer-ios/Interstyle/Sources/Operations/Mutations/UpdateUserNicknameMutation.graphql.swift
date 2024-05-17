// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateUserNicknameMutation: GraphQLMutation {
  public static let operationName: String = "UpdateUserNickname"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateUserNickname($id: UUID!, $username: String!) { userProfile: updatemembersCollection( filter: { id: { eq: $id } } set: { username: $username } ) { __typename affectedCount } }"#
    ))

  public var id: UUID
  public var username: String

  public init(
    id: UUID,
    username: String
  ) {
    self.id = id
    self.username = username
  }

  public var __variables: Variables? { [
    "id": id,
    "username": username
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updatemembersCollection", alias: "userProfile", UserProfile.self, arguments: [
        "filter": ["id": ["eq": .variable("id")]],
        "set": ["username": .variable("username")]
      ]),
    ] }

    /// Updates zero or more records in the `members` collection
    public var userProfile: UserProfile { __data["userProfile"] }

    /// UserProfile
    ///
    /// Parent Type: `MembersUpdateResponse`
    public struct UserProfile: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.MembersUpdateResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("affectedCount", Int.self),
      ] }

      /// Count of the records impacted by the mutation
      public var affectedCount: Int { __data["affectedCount"] }
    }
  }
}
