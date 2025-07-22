// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_CREDENTIAL_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_CREDENTIAL_FIELDS on ValidatorCredentials { __typename netAddress networkPubKey p2PAddress primaryAddress workerPubKey workerAddress proofOfPossession protocolPubKey }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ValidatorCredentials }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("netAddress", String?.self),
    .field("networkPubKey", SuiKit.Base64Apollo?.self),
    .field("p2PAddress", String?.self),
    .field("primaryAddress", String?.self),
    .field("workerPubKey", SuiKit.Base64Apollo?.self),
    .field("workerAddress", String?.self),
    .field("proofOfPossession", SuiKit.Base64Apollo?.self),
    .field("protocolPubKey", SuiKit.Base64Apollo?.self)
  ] }

  public var netAddress: String? { __data["netAddress"] }
  public var networkPubKey: SuiKit.Base64Apollo? { __data["networkPubKey"] }
  public var p2PAddress: String? { __data["p2PAddress"] }
  public var primaryAddress: String? { __data["primaryAddress"] }
  public var workerPubKey: SuiKit.Base64Apollo? { __data["workerPubKey"] }
  public var workerAddress: String? { __data["workerAddress"] }
  public var proofOfPossession: SuiKit.Base64Apollo? { __data["proofOfPossession"] }
  public var protocolPubKey: SuiKit.Base64Apollo? { __data["protocolPubKey"] }
}
