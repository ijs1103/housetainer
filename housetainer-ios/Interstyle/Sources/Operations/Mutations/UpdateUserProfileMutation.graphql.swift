// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateUserProfileMutation: GraphQLMutation {
  public static let operationName: String = "UpdateUserProfile"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateUserProfile($id: UUID!, $profileUrl: String, $gender: String, $birthday: Date) { userProfile: updatemembersCollection( filter: { id: { eq: $id } } set: { profile_photo: $profileUrl, gender: $gender, birthday: $birthday } ) { __typename affectedCount } }"#
    ))

  public var id: UUID
  public var profileUrl: GraphQLNullable<String>
  public var gender: GraphQLNullable<String>
  public var birthday: GraphQLNullable<Date>

  public init(
    id: UUID,
    profileUrl: GraphQLNullable<String>,
    gender: GraphQLNullable<String>,
    birthday: GraphQLNullable<Date>
  ) {
    self.id = id
    self.profileUrl = profileUrl
    self.gender = gender
    self.birthday = birthday
  }

  public var __variables: Variables? { [
    "id": id,
    "profileUrl": profileUrl,
    "gender": gender,
    "birthday": birthday
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updatemembersCollection", alias: "userProfile", UserProfile.self, arguments: [
        "filter": ["id": ["eq": .variable("id")]],
        "set": [
          "profile_photo": .variable("profileUrl"),
          "gender": .variable("gender"),
          "birthday": .variable("birthday")
        ]
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
