// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetBalanceQuery: GraphQLQuery {
  public static let operationName: String = "getBalance"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getBalance($owner: SuiAddress!, $type: String = "0x2::sui::SUI") { address(address: $owner) { __typename balance(type: $type) { __typename coinType { __typename repr } coinObjectCount totalBalance } } }"#
    ))

  public var owner: SuiAddressApollo
  public var type: GraphQLNullable<String>

  public init(
    owner: SuiAddressApollo,
    type: GraphQLNullable<String> = "0x2::sui::SUI"
  ) {
    self.owner = owner
    self.type = type
  }

  public var __variables: Variables? { [
    "owner": owner,
    "type": type
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self, arguments: ["address": .variable("owner")])
    ] }

    /// Look-up an Account by its SuiAddressApollo.
    public var address: Address? { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Address }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("balance", Balance?.self, arguments: ["type": .variable("type")])
      ] }

      /// Total balance of all coins with marker type owned by this address. If type is not supplied,
      /// it defaults to `0x2::sui::SUI`.
      public var balance: Balance? { __data["balance"] }

      /// Address.Balance
      ///
      /// Parent Type: `Balance`
      public struct Balance: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Balance }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("coinType", CoinType.self),
          .field("coinObjectCount", SuiKit.UInt53Apollo?.self),
          .field("totalBalance", SuiKit.BigIntApollo?.self)
        ] }

        /// Coin type for the balance, such as 0x2::sui::SUI
        public var coinType: CoinType { __data["coinType"] }
        /// How many coins of this type constitute the balance
        public var coinObjectCount: SuiKit.UInt53Apollo? { __data["coinObjectCount"] }
        /// Total balance across all coin objects of the coin type
        public var totalBalance: SuiKit.BigIntApollo? { __data["totalBalance"] }

        /// Address.Balance.CoinType
        ///
        /// Parent Type: `MoveType`
        public struct CoinType: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveType }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("repr", String.self)
          ] }

          /// Flat representation of the type signature, as a displayable string.
          public var repr: String { __data["repr"] }
        }
      }
    }
  }
}
