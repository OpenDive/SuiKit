// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCoinMetadataQuery: GraphQLQuery {
  public static let operationName: String = "getCoinMetadata"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCoinMetadata($coinType: String!) { coinMetadata(coinType: $coinType) { __typename decimals name symbol description iconUrl address } }"#
    ))

  public var coinType: String

  public init(coinType: String) {
    self.coinType = coinType
  }

  public var __variables: Variables? { ["coinType": coinType] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("coinMetadata", CoinMetadata?.self, arguments: ["coinType": .variable("coinType")])
    ] }

    /// The coin metadata associated with the given coin type. Note that if the latest version of
    /// the coin's metadata is wrapped or deleted, it will not be found.
    public var coinMetadata: CoinMetadata? { __data["coinMetadata"] }

    /// CoinMetadata
    ///
    /// Parent Type: `CoinMetadata`
    public struct CoinMetadata: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.CoinMetadata }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("decimals", Int?.self),
        .field("name", String?.self),
        .field("symbol", String?.self),
        .field("description", String?.self),
        .field("iconUrl", String?.self),
        .field("address", SuiKit.SuiAddressApollo.self)
      ] }

      /// The number of decimal places used to represent the token.
      public var decimals: Int? { __data["decimals"] }
      /// Full, official name of the token.
      public var name: String? { __data["name"] }
      /// The token's identifying abbreviation.
      public var symbol: String? { __data["symbol"] }
      /// Optional description of the token, provided by the creator of the token.
      public var description: String? { __data["description"] }
      public var iconUrl: String? { __data["iconUrl"] }
      public var address: SuiKit.SuiAddressApollo { __data["address"] }
    }
  }
}
