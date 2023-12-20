// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MultiGetTransactionBlocksQuery: GraphQLQuery {
  public static let operationName: String = "multiGetTransactionBlocks"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query multiGetTransactionBlocks($digests: [String!]!, $limit: Int, $cursor: String, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false) { transactionBlockConnection( first: $limit after: $cursor filter: { transactionIds: $digests } ) { __typename pageInfo { __typename hasNextPage hasPreviousPage startCursor endCursor } nodes { __typename ...RPC_TRANSACTION_FIELDS } } }"#,
      fragments: [RPC_TRANSACTION_FIELDS.self]
    ))

  public var digests: [String]
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>
  public var showBalanceChanges: GraphQLNullable<Bool>
  public var showEffects: GraphQLNullable<Bool>
  public var showInput: GraphQLNullable<Bool>
  public var showObjectChanges: GraphQLNullable<Bool>
  public var showRawInput: GraphQLNullable<Bool>

  public init(
    digests: [String],
    limit: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>,
    showBalanceChanges: GraphQLNullable<Bool> = false,
    showEffects: GraphQLNullable<Bool> = false,
    showInput: GraphQLNullable<Bool> = false,
    showObjectChanges: GraphQLNullable<Bool> = false,
    showRawInput: GraphQLNullable<Bool> = false
  ) {
    self.digests = digests
    self.limit = limit
    self.cursor = cursor
    self.showBalanceChanges = showBalanceChanges
    self.showEffects = showEffects
    self.showInput = showInput
    self.showObjectChanges = showObjectChanges
    self.showRawInput = showRawInput
  }

  public var __variables: Variables? { [
    "digests": digests,
    "limit": limit,
    "cursor": cursor,
    "showBalanceChanges": showBalanceChanges,
    "showEffects": showEffects,
    "showInput": showInput,
    "showObjectChanges": showObjectChanges,
    "showRawInput": showRawInput
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("transactionBlockConnection", TransactionBlockConnection?.self, arguments: [
        "first": .variable("limit"),
        "after": .variable("cursor"),
        "filter": ["transactionIds": .variable("digests")]
      ]),
    ] }

    public var transactionBlockConnection: TransactionBlockConnection? { __data["transactionBlockConnection"] }

    /// TransactionBlockConnection
    ///
    /// Parent Type: `TransactionBlockConnection`
    public struct TransactionBlockConnection: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlockConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self),
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// TransactionBlockConnection.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("hasPreviousPage", Bool.self),
          .field("startCursor", String?.self),
          .field("endCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool { __data["hasPreviousPage"] }
        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? { __data["startCursor"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// TransactionBlockConnection.Node
      ///
      /// Parent Type: `TransactionBlock`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RPC_TRANSACTION_FIELDS.self),
        ] }

        /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
        /// This serves as a unique id for the block on chain
        public var digest: String { __data["digest"] }
        /// The transaction block data in BCS format.
        /// This includes data on the sender, inputs, sponsor, gas inputs, individual transactions, and user signatures.
        public var rawTransaction: SuiKit.Base64Apollo? { __data["rawTransaction"] }
        /// The address of the user sending this transaction block
        public var sender: RPC_TRANSACTION_FIELDS.Sender? { __data["sender"] }
        /// A list of signatures of all signers, senders, and potentially the gas owner if this is a sponsored transaction.
        public var signatures: [RPC_TRANSACTION_FIELDS.Signature?]? { __data["signatures"] }
        /// The effects field captures the results to the chain of executing this transaction
        public var effects: RPC_TRANSACTION_FIELDS.Effects? { __data["effects"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rPC_TRANSACTION_FIELDS: RPC_TRANSACTION_FIELDS { _toFragment() }
        }
      }
    }
  }
}
