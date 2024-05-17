// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ExistUserNicknameQuery: GraphQLQuery {
  public static let operationName: String = "ExistUserNickname"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ExistUserNickname($username: String!) { userProfile: membersCollection( first: 1 filter: { username: { eq: $username } } ) { __typename edges { __typename node { __typename id } } } }"#
    ))

  public var username: String

  public init(username: String) {
    self.username = username
  }

  public var __variables: Variables? { ["username": username] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("membersCollection", alias: "userProfile", UserProfile?.self, arguments: [
        "first": 1,
        "filter": ["username": ["eq": .variable("username")]]
      ]),
    ] }

    /// A pagable collection of type `members`
    public var userProfile: UserProfile? { __data["userProfile"] }

    /// UserProfile
    ///
    /// Parent Type: `MembersConnection`
    public struct UserProfile: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.MembersConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
      ] }

      public var edges: [Edge] { __data["edges"] }

      /// UserProfile.Edge
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

        /// UserProfile.Edge.Node
        ///
        /// Parent Type: `Members`
        public struct Node: Interstyle.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Members }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", Interstyle.UUID.self),
          ] }

          public var id: Interstyle.UUID { __data["id"] }
        }
      }
    }
  }
}
