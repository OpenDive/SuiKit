// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAllBalancesQuery: GraphQLQuery {
  public static let operationName: String = "getAllBalances"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getAllBalances($owner: SuiAddress!, $limit: Int, $cursor: String) { address(address: $owner) { __typename balances(first: $limit, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename coinType { __typename repr } coinObjectCount totalBalance } } } }"#
    ))

  public var owner: SuiAddressApollo
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>

  public init(
    owner: SuiAddressApollo,
    limit: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>
  ) {
    self.owner = owner
    self.limit = limit
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "owner": owner,
    "limit": limit,
    "cursor": cursor
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
        .field("balances", Balances.self, arguments: [
          "first": .variable("limit"),
          "after": .variable("cursor")
        ])
      ] }

      /// The balances of all coin types owned by this address.
      public var balances: Balances { __data["balances"] }

      /// Address.Balances
      ///
      /// Parent Type: `BalanceConnection`
      public struct Balances: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.BalanceConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self)
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.Balances.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self)
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Address.Balances.Node
        ///
        /// Parent Type: `Balance`
        public struct Node: SuiKit.SelectionSet {
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

          /// Address.Balances.Node.CoinType
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
}
