// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetAllBalancesQuery: GraphQLQuery {
  public static let operationName: String = "getAllBalances"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getAllBalances($owner: SuiAddress!, $limit: Int, $cursor: String) { address(address: $owner) { __typename balances(first: $limit, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename coinType { __typename repr } totalBalance } } } }"#
    ))

  public var owner: SuiAddress
  public var limit: GraphQLNullable<Int32>
  public var cursor: GraphQLNullable<String>

  public init(
    owner: SuiAddress,
    limit: GraphQLNullable<Int32>,
    cursor: GraphQLNullable<String>
  ) {
    self.owner = owner
    self.limit = limit
    self.cursor = cursor
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "owner": owner,
    "limit": limit,
    "cursor": cursor
  ] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address.self, arguments: ["address": .variable("owner")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetAllBalancesQuery.Data.self
    ] }

    /// Look-up an account by its SuiAddress.
    ///
    /// If `rootVersion` is specified, nested dynamic field accesses will be fetched at or before this version. This can be used to fetch a child or ancestor object bounded by its root object's version, when its immediate parent is wrapped, or a value in a dynamic object field. For any wrapped or child (object-owned) object, its root object can be defined recursively as:
    ///
    /// - The root object of the object it is wrapped in, if it is wrapped.
    /// - The root object of its owner, if it is owned by another object.
    /// - The object itself, if it is not object-owned or wrapped.
    ///
    /// Specifying a `rootVersion` disables nested queries for paginating owned objects or dynamic fields (these queries are only supported at checkpoint boundaries).
    public var address: Address { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Address }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("balances", Balances?.self, arguments: [
          "first": .variable("limit"),
          "after": .variable("cursor")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetAllBalancesQuery.Data.Address.self
      ] }

      /// Total balance across coins owned by this address, grouped by coin type.
      public var balances: Balances? { __data["balances"] }

      /// Address.Balances
      ///
      /// Parent Type: `BalanceConnection`
      public struct Balances: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.BalanceConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetAllBalancesQuery.Data.Address.Balances.self
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.Balances.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.PageInfo }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetAllBalancesQuery.Data.Address.Balances.PageInfo.self
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Address.Balances.Node
        ///
        /// Parent Type: `Balance`
        public struct Node: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Balance }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("coinType", CoinType?.self),
            .field("totalBalance", GraphqlSchemaSuiKit.BigInt?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetAllBalancesQuery.Data.Address.Balances.Node.self
          ] }

          /// Coin type for the balance, such as `0x2::sui::SUI`.
          public var coinType: CoinType? { __data["coinType"] }
          /// The total balance across all coin objects of this coin type.
          public var totalBalance: GraphqlSchemaSuiKit.BigInt? { __data["totalBalance"] }

          /// Address.Balances.Node.CoinType
          ///
          /// Parent Type: `MoveType`
          public struct CoinType: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("repr", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetAllBalancesQuery.Data.Address.Balances.Node.CoinType.self
            ] }

            /// Flat representation of the type signature, as a displayable string.
            public var repr: String { __data["repr"] }
          }
        }
      }
    }
  }
}
