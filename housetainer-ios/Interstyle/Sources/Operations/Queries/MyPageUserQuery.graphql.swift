// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MyPageUserQuery: GraphQLQuery {
  public static let operationName: String = "MyPageUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MyPageUser($userId: UUID!) { user: membersCollection(first: 1, filter: { id: { eq: $userId } }) { __typename edges { __typename node { __typename id memberType: member_type nickname profileUrl: profile_photo } } } }"#
    ))

  public var userId: UUID

  public init(userId: UUID) {
    self.userId = userId
  }

  public var __variables: Variables? { ["userId": userId] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("membersCollection", alias: "user", User?.self, arguments: [
        "first": 1,
        "filter": ["id": ["eq": .variable("userId")]]
      ]),
    ] }

    /// A pagable collection of type `members`
    public var user: User? { __data["user"] }

    /// User
    ///
    /// Parent Type: `MembersConnection`
    public struct User: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.MembersConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
      ] }

      public var edges: [Edge] { __data["edges"] }

      /// User.Edge
      ///
      /// Parent Type: `MembersEdge`
      public struct Edge: Interstyle.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.MembersEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node.self),
        ] }

        public var node: Node { __data["node"] }

        /// User.Edge.Node
        ///
        /// Parent Type: `Members`
        public struct Node: Interstyle.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Members }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", Interstyle.UUID.self),
            .field("member_type", alias: "memberType", String?.self),
            .field("nickname", String.self),
            .field("profile_photo", alias: "profileUrl", String?.self),
          ] }

          public var id: Interstyle.UUID { __data["id"] }
          public var memberType: String? { __data["memberType"] }
          public var nickname: String { __data["nickname"] }
          public var profileUrl: String? { __data["profileUrl"] }
        }
      }
    }
  }
}
