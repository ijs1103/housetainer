// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateSocialCalendarMutation: GraphQLMutation {
  public static let operationName: String = "CreateSocialCalendar"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateSocialCalendar($title: String!, $scheduleType: String!, $ownerId: UUID!, $date: Datetime, $description: String!, $link: String, $fileName: String!) { socialCalendar: insertIntoeventsCollection( objects: [ { title: $title schedule_type: $scheduleType owner_id: $ownerId date: $date detail: $description related_link: $link display_type: "Y" file_name: $fileName } ] ) { __typename affectedCount } }"#
    ))

  public var title: String
  public var scheduleType: String
  public var ownerId: UUID
  public var date: GraphQLNullable<Datetime>
  public var description: String
  public var link: GraphQLNullable<String>
  public var fileName: String

  public init(
    title: String,
    scheduleType: String,
    ownerId: UUID,
    date: GraphQLNullable<Datetime>,
    description: String,
    link: GraphQLNullable<String>,
    fileName: String
  ) {
    self.title = title
    self.scheduleType = scheduleType
    self.ownerId = ownerId
    self.date = date
    self.description = description
    self.link = link
    self.fileName = fileName
  }

  public var __variables: Variables? { [
    "title": title,
    "scheduleType": scheduleType,
    "ownerId": ownerId,
    "date": date,
    "description": description,
    "link": link,
    "fileName": fileName
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("insertIntoeventsCollection", alias: "socialCalendar", SocialCalendar?.self, arguments: ["objects": [[
        "title": .variable("title"),
        "schedule_type": .variable("scheduleType"),
        "owner_id": .variable("ownerId"),
        "date": .variable("date"),
        "detail": .variable("description"),
        "related_link": .variable("link"),
        "display_type": "Y",
        "file_name": .variable("fileName")
      ]]]),
    ] }

    /// Adds one or more `events` records to the collection
    public var socialCalendar: SocialCalendar? { __data["socialCalendar"] }

    /// SocialCalendar
    ///
    /// Parent Type: `EventsInsertResponse`
    public struct SocialCalendar: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.EventsInsertResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("affectedCount", Int.self),
      ] }

      /// Count of the records impacted by the mutation
      public var affectedCount: Int { __data["affectedCount"] }
    }
  }
}
