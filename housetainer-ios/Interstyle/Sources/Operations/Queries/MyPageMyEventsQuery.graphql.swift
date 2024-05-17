// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MyPageMyEventsQuery: GraphQLQuery {
  public static let operationName: String = "MyPageMyEvents"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MyPageMyEvents($ownerId: UUID!, $current: Datetime!, $perPage: Int!, $cursor: Cursor) { events: eventsCollection( first: $perPage after: $cursor filter: { owner_id: { eq: $ownerId }, date: { gte: $current } } orderBy: { date: AscNullsLast } ) { __typename edges { __typename node { __typename id imageName: image_urls title scheduleType: schedule_type date members { __typename id nickname memberType: member_type } } } pageInfo { __typename hasNextPage cursor: endCursor } } }"#
    ))

  public var ownerId: UUID
  public var current: Datetime
  public var perPage: Int
  public var cursor: GraphQLNullable<Cursor>

  public init(
    ownerId: UUID,
    current: Datetime,
    perPage: Int,
    cursor: GraphQLNullable<Cursor>
  ) {
    self.ownerId = ownerId
    self.current = current
    self.perPage = perPage
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "ownerId": ownerId,
    "current": current,
    "perPage": perPage,
    "cursor": cursor
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("eventsCollection", alias: "events", Events?.self, arguments: [
        "first": .variable("perPage"),
        "after": .variable("cursor"),
        "filter": [
          "owner_id": ["eq": .variable("ownerId")],
          "date": ["gte": .variable("current")]
        ],
        "orderBy": ["date": "AscNullsLast"]
      ]),
    ] }

    /// A pagable collection of type `events`
    public var events: Events? { __data["events"] }

    /// Events
    ///
    /// Parent Type: `EventsConnection`
    public struct Events: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.EventsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var edges: [Edge] { __data["edges"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// Events.Edge
      ///
      /// Parent Type: `EventsEdge`
      public struct Edge: Interstyle.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.EventsEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node.self),
        ] }

        public var node: Node { __data["node"] }

        /// Events.Edge.Node
        ///
        /// Parent Type: `Events`
        public struct Node: Interstyle.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Events }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", Interstyle.UUID.self),
            .field("image_urls", alias: "imageName", [String].self),
            .field("title", String.self),
            .field("schedule_type", alias: "scheduleType", String.self),
            .field("date", Interstyle.Datetime.self),
            .field("members", Members.self),
          ] }

          public var id: Interstyle.UUID { __data["id"] }
          public var imageName: [String] { __data["imageName"] }
          public var title: String { __data["title"] }
          public var scheduleType: String { __data["scheduleType"] }
          public var date: Interstyle.Datetime { __data["date"] }
          public var members: Members { __data["members"] }

          /// Events.Edge.Node.Members
          ///
          /// Parent Type: `Members`
          public struct Members: Interstyle.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Members }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", Interstyle.UUID.self),
              .field("nickname", String.self),
              .field("member_type", alias: "memberType", String?.self),
            ] }

            public var id: Interstyle.UUID { __data["id"] }
            public var nickname: String { __data["nickname"] }
            public var memberType: String? { __data["memberType"] }
          }
        }
      }

      /// Events.PageInfo
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
