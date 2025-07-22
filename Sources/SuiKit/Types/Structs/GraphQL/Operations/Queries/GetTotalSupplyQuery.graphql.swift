// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetTotalSupplyQuery: GraphQLQuery {
  public static let operationName: String = "getTotalSupply"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getTotalSupply($coinType: String!) { coinMetadata(coinType: $coinType) { __typename supply decimals } }"#
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
        .field("supply", SuiKit.BigIntApollo?.self),
        .field("decimals", Int?.self)
      ] }

      /// The overall quantity of tokens that will be issued.
      public var supply: SuiKit.BigIntApollo? { __data["supply"] }
      /// The number of decimal places used to represent the token.
      public var decimals: Int? { __data["decimals"] }
    }
  }
}
