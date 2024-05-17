// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateHouseInfoMutation: GraphQLMutation {
  public static let operationName: String = "CreateHouseInfo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateHouseInfo($category: String!, $domestic: Boolean!, $location: String!, $detailedLocation: String!, $coverImageIndex: Int!, $imageUrls: [String]!, $shortDescription: String!, $description: String!, $ownerId: UUID!) { houseInfo: insertIntohousesCollection( objects: [ { owner_id: $ownerId name: $shortDescription category: $category title: $shortDescription content: $description image_urls: $imageUrls cover_image_index: $coverImageIndex domestic: $domestic location: $location detailed_location: $detailedLocation } ] ) { __typename affectedCount } }"#
    ))

  public var category: String
  public var domestic: Bool
  public var location: String
  public var detailedLocation: String
  public var coverImageIndex: Int
  public var imageUrls: [String?]
  public var shortDescription: String
  public var description: String
  public var ownerId: UUID

  public init(
    category: String,
    domestic: Bool,
    location: String,
    detailedLocation: String,
    coverImageIndex: Int,
    imageUrls: [String?],
    shortDescription: String,
    description: String,
    ownerId: UUID
  ) {
    self.category = category
    self.domestic = domestic
    self.location = location
    self.detailedLocation = detailedLocation
    self.coverImageIndex = coverImageIndex
    self.imageUrls = imageUrls
    self.shortDescription = shortDescription
    self.description = description
    self.ownerId = ownerId
  }

  public var __variables: Variables? { [
    "category": category,
    "domestic": domestic,
    "location": location,
    "detailedLocation": detailedLocation,
    "coverImageIndex": coverImageIndex,
    "imageUrls": imageUrls,
    "shortDescription": shortDescription,
    "description": description,
    "ownerId": ownerId
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("insertIntohousesCollection", alias: "houseInfo", HouseInfo?.self, arguments: ["objects": [[
        "owner_id": .variable("ownerId"),
        "name": .variable("shortDescription"),
        "category": .variable("category"),
        "title": .variable("shortDescription"),
        "content": .variable("description"),
        "image_urls": .variable("imageUrls"),
        "cover_image_index": .variable("coverImageIndex"),
        "domestic": .variable("domestic"),
        "location": .variable("location"),
        "detailed_location": .variable("detailedLocation")
      ]]]),
    ] }

    /// Adds one or more `houses` records to the collection
    public var houseInfo: HouseInfo? { __data["houseInfo"] }

    /// HouseInfo
    ///
    /// Parent Type: `HousesInsertResponse`
    public struct HouseInfo: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.HousesInsertResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("affectedCount", Int.self),
      ] }

      /// Count of the records impacted by the mutation
      public var affectedCount: Int { __data["affectedCount"] }
    }
  }
}
