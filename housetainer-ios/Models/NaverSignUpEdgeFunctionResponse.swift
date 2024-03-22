//
//  NaverSignUpEdgeFunctionResponse.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/23/24.
//

import Foundation

struct NaverSignUpEdgeFunctionResponse: Codable {
    let data: DataType
    let error: JSONNull?
}

struct DataType: Codable {
    let user: UserType
    let session: SessionType
}

struct SessionType: Codable {
    let accessToken, tokenType: String
    let expiresIn, expiresAt: Int
    let refreshToken: String
    let user: UserType

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
        case refreshToken = "refresh_token"
        case user
    }
}

struct UserType: Codable {
    let id, aud, role, email: String
    let emailConfirmedAt, phone, confirmedAt, lastSignInAt: String
    let appMetadata: AppMetadata
    let userMetadata: UserMetadata
    let identities: [Identity]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, aud, role, email
        case emailConfirmedAt = "email_confirmed_at"
        case phone
        case confirmedAt = "confirmed_at"
        case lastSignInAt = "last_sign_in_at"
        case appMetadata = "app_metadata"
        case userMetadata = "user_metadata"
        case identities
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AppMetadata: Codable {
    let provider: String
    let providers: [String]
}

struct Identity: Codable {
    let identityID, id, userID: String
    let identityData: IdentityData
    let provider, lastSignInAt, createdAt, updatedAt: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case identityID = "identity_id"
        case id
        case userID = "user_id"
        case identityData = "identity_data"
        case provider
        case lastSignInAt = "last_sign_in_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case email
    }
}

struct IdentityData: Codable {
    let email: String
    let emailVerified, phoneVerified: Bool
    let sub: String

    enum CodingKeys: String, CodingKey {
        case email
        case emailVerified = "email_verified"
        case phoneVerified = "phone_verified"
        case sub
    }
}

struct UserMetadata: Codable {
}

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
