// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MyPageInvitationsQuery: GraphQLQuery {
  public static let operationName: String = "MyPageInvitations"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MyPageInvitations($userId: UUID!) { invitations: invitationsCollection( first: 3 filter: { inviter_id: { eq: $userId } } orderBy: { created_at: DescNullsLast } ) { __typename edges { __typename node { __typename status name: invitee_name } } } }"#
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
      .field("invitationsCollection", alias: "invitations", Invitations?.self, arguments: [
        "first": 3,
        "filter": ["inviter_id": ["eq": .variable("userId")]],
        "orderBy": ["created_at": "DescNullsLast"]
      ]),
    ] }

    /// A pagable collection of type `invitations`
    public var invitations: Invitations? { __data["invitations"] }

    /// Invitations
    ///
    /// Parent Type: `InvitationsConnection`
    public struct Invitations: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.InvitationsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
      ] }

      public var edges: [Edge] { __data["edges"] }

      /// Invitations.Edge
      ///
      /// Parent Type: `InvitationsEdge`
      public struct Edge: Interstyle.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.InvitationsEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node.self),
        ] }

        public var node: Node { __data["node"] }

        /// Invitations.Edge.Node
        ///
        /// Parent Type: `Invitations`
        public struct Node: Interstyle.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Invitations }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("status", String.self),
            .field("invitee_name", alias: "name", String.self),
          ] }

          public var status: String { __data["status"] }
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
