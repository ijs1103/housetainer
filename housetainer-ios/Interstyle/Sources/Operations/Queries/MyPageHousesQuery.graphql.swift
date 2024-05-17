// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MyPageHousesQuery: GraphQLQuery {
  public static let operationName: String = "MyPageHouses"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MyPageHouses($ownerId: UUID!, $perPage: Int!, $cursor: Cursor) { houses: housesCollection( first: $perPage after: $cursor filter: { owner_id: { eq: $ownerId } } orderBy: { created_at: DescNullsLast } ) { __typename edges { __typename node { __typename id imageUrls: image_urls title } } pageInfo { __typename hasNextPage cursor: endCursor } } }"#
    ))

  public var ownerId: UUID
  public var perPage: Int
  public var cursor: GraphQLNullable<Cursor>

  public init(
    ownerId: UUID,
    perPage: Int,
    cursor: GraphQLNullable<Cursor>
  ) {
    self.ownerId = ownerId
    self.perPage = perPage
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "ownerId": ownerId,
    "perPage": perPage,
    "cursor": cursor
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("housesCollection", alias: "houses", Houses?.self, arguments: [
        "first": .variable("perPage"),
        "after": .variable("cursor"),
        "filter": ["owner_id": ["eq": .variable("ownerId")]],
        "orderBy": ["created_at": "DescNullsLast"]
      ]),
    ] }

    /// A pagable collection of type `houses`
    public var houses: Houses? { __data["houses"] }

    /// Houses
    ///
    /// Parent Type: `HousesConnection`
    public struct Houses: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.HousesConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var edges: [Edge] { __data["edges"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// Houses.Edge
      ///
      /// Parent Type: `HousesEdge`
      public struct Edge: Interstyle.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.HousesEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node.self),
        ] }

        public var node: Node { __data["node"] }

        /// Houses.Edge.Node
        ///
        /// Parent Type: `Houses`
        public struct Node: Interstyle.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Houses }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", Interstyle.UUID.self),
            .field("image_urls", alias: "imageUrls", [String?].self),
            .field("title", String.self),
          ] }

          public var id: Interstyle.UUID { __data["id"] }
          public var imageUrls: [String?] { __data["imageUrls"] }
          public var title: String { __data["title"] }
        }
      }

      /// Houses.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: Interstyle.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", alias: "cursor", String?.self),
        ] }

        public var hasNextPage: Bool { __data["hasNextPage"] }
        public var cursor: String? { __data["cursor"] }
      }
    }
  }
}
