// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class InviteUserMutation: GraphQLMutation {
  public static let operationName: String = "InviteUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation InviteUser($ownerId: UUID!, $name: String!, $email: String!, $code: String!, $createdAt: Datetime!) { inviteUser: insertIntoinvitationsCollection( objects: [ { created_at: $createdAt code: $code inviter_id: $ownerId invitee_name: $name invitee_email: $email status: "S" } ] ) { __typename affectedCount } }"#
    ))

  public var ownerId: UUID
  public var name: String
  public var email: String
  public var code: String
  public var createdAt: Datetime

  public init(
    ownerId: UUID,
    name: String,
    email: String,
    code: String,
    createdAt: Datetime
  ) {
    self.ownerId = ownerId
    self.name = name
    self.email = email
    self.code = code
    self.createdAt = createdAt
  }

  public var __variables: Variables? { [
    "ownerId": ownerId,
    "name": name,
    "email": email,
    "code": code,
    "createdAt": createdAt
  ] }

  public struct Data: Interstyle.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("insertIntoinvitationsCollection", alias: "inviteUser", InviteUser?.self, arguments: ["objects": [[
        "created_at": .variable("createdAt"),
        "code": .variable("code"),
        "inviter_id": .variable("ownerId"),
        "invitee_name": .variable("name"),
        "invitee_email": .variable("email"),
        "status": "S"
      ]]]),
    ] }

    /// Adds one or more `invitations` records to the collection
    public var inviteUser: InviteUser? { __data["inviteUser"] }

    /// InviteUser
    ///
    /// Parent Type: `InvitationsInsertResponse`
    public struct InviteUser: Interstyle.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { Interstyle.Objects.InvitationsInsertResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("affectedCount", Int.self),
      ] }

      /// Count of the records impacted by the mutation
      public var affectedCount: Int { __data["affectedCount"] }
    }
  }
}
