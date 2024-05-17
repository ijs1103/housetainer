// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MyPageBookmarkedEventsQuery: GraphQLQuery {
  public static let operationName: String = "MyPageBookmarkedEvents"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MyPageBookmarkedEvents($ownerId: UUID!, $perPage: Int!, $cursor: Cursor) { events: event_bookmarksCollection( first: $perPage after: $cursor filter: { owner_id: { eq: $ownerId } } orderBy: { created_at: DescNullsLast } ) { __typename edges { __typename node { __typename event: events { __typename id imageName: image_urls title scheduleType: schedule_type date members { __typename id username memberType: member_type } } } } pageInfo { __typename hasNextPage cursor: endCursor } } }"#
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
      .field("event_bookmarksCollection", alias: "events", Events?.self, arguments: [
        "first": .variable("perPage"),
        "after": .variable("cursor"),
        "filter": ["owner_id": ["eq": .variable("ownerId")]],
        "orderBy": ["created_at": "DescNullsLast"]
      ]),
    ] }

    /// A pagable collection of type `event_bookmarks`
    public var events: Events? { __data["events"] }

    /// Events
    ///
    /// Parent Type: `Event_bookmarksConnection`
    public struct Events: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Event_bookmarksConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var edges: [Edge] { __data["edges"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// Events.Edge
      ///
      /// Parent Type: `Event_bookmarksEdge`
      public struct Edge: Interstyle.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Event_bookmarksEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node.self),
        ] }

        public var node: Node { __data["node"] }

        /// Events.Edge.Node
        ///
        /// Parent Type: `Event_bookmarks`
        public struct Node: Interstyle.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Event_bookmarks }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("events", alias: "event", Event.self),
          ] }

          public var event: Event { __data["event"] }

          /// Events.Edge.Node.Event
          ///
          /// Parent Type: `Events`
          public struct Event: Interstyle.SelectionSet {
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

            /// Events.Edge.Node.Event.Members
            ///
            /// Parent Type: `Members`
            public struct Members: Interstyle.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Members }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", Interstyle.UUID.self),
                .field("username", String.self),
                .field("member_type", alias: "memberType", String?.self),
              ] }

              public var id: Interstyle.UUID { __data["id"] }
              public var username: String { __data["username"] }
              public var memberType: String? { __data["memberType"] }
            }
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
