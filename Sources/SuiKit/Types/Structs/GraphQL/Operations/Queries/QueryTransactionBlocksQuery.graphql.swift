// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class QueryTransactionBlocksQuery: GraphQLQuery {
  public static let operationName: String = "queryTransactionBlocks"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query queryTransactionBlocks($first: Int, $last: Int, $before: String, $after: String, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false, $filter: TransactionBlockFilter) { transactionBlocks( first: $first after: $after last: $last before: $before filter: $filter ) { __typename pageInfo { __typename hasNextPage hasPreviousPage startCursor endCursor } nodes { __typename ...RPC_TRANSACTION_FIELDS } } }"#,
      fragments: [RPC_EVENTS_FIELDS.self, RPC_TRANSACTION_FIELDS.self]
    ))

  public var first: GraphQLNullable<Int>
  public var last: GraphQLNullable<Int>
  public var before: GraphQLNullable<String>
  public var after: GraphQLNullable<String>
  public var showBalanceChanges: GraphQLNullable<Bool>
  public var showEffects: GraphQLNullable<Bool>
  public var showRawEffects: GraphQLNullable<Bool>
  public var showEvents: GraphQLNullable<Bool>
  public var showInput: GraphQLNullable<Bool>
  public var showObjectChanges: GraphQLNullable<Bool>
  public var showRawInput: GraphQLNullable<Bool>
  public var filter: GraphQLNullable<TransactionBlockFilter>

  public init(
    first: GraphQLNullable<Int>,
    last: GraphQLNullable<Int>,
    before: GraphQLNullable<String>,
    after: GraphQLNullable<String>,
    showBalanceChanges: GraphQLNullable<Bool> = false,
    showEffects: GraphQLNullable<Bool> = false,
    showRawEffects: GraphQLNullable<Bool> = false,
    showEvents: GraphQLNullable<Bool> = false,
    showInput: GraphQLNullable<Bool> = false,
    showObjectChanges: GraphQLNullable<Bool> = false,
    showRawInput: GraphQLNullable<Bool> = false,
    filter: GraphQLNullable<TransactionBlockFilter>
  ) {
    self.first = first
    self.last = last
    self.before = before
    self.after = after
    self.showBalanceChanges = showBalanceChanges
    self.showEffects = showEffects
    self.showRawEffects = showRawEffects
    self.showEvents = showEvents
    self.showInput = showInput
    self.showObjectChanges = showObjectChanges
    self.showRawInput = showRawInput
    self.filter = filter
  }

  public var __variables: Variables? { [
    "first": first,
    "last": last,
    "before": before,
    "after": after,
    "showBalanceChanges": showBalanceChanges,
    "showEffects": showEffects,
    "showRawEffects": showRawEffects,
    "showEvents": showEvents,
    "showInput": showInput,
    "showObjectChanges": showObjectChanges,
    "showRawInput": showRawInput,
    "filter": filter
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("transactionBlocks", TransactionBlocks.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after"),
        "last": .variable("last"),
        "before": .variable("before"),
        "filter": .variable("filter")
      ])
    ] }

    /// The transaction blocks that exist in the network.
    ///
    /// `scanLimit` restricts the number of candidate transactions scanned when gathering a page of
    /// results. It is required for queries that apply more than two complex filters (on function,
    /// kind, sender, recipient, input object, changed object, or ids), and can be at most
    /// `serviceConfig.maxScanLimit`.
    ///
    /// When the scan limit is reached the page will be returned even if it has fewer than `first`
    /// results when paginating forward (`last` when paginating backwards). If there are more
    /// transactions to scan, `pageInfo.hasNextPage` (or `pageInfo.hasPreviousPage`) will be set to
    /// `true`, and `PageInfo.endCursor` (or `PageInfo.startCursor`) will be set to the last
    /// transaction that was scanned as opposed to the last (or first) transaction in the page.
    ///
    /// Requesting the next (or previous) page after this cursor will resume the search, scanning
    /// the next `scanLimit` many transactions in the direction of pagination, and so on until all
    /// transactions in the scanning range have been visited.
    ///
    /// By default, the scanning range includes all transactions known to GraphQL, but it can be
    /// restricted by the `after` and `before` cursors, and the `beforeCheckpoint`,
    /// `afterCheckpoint` and `atCheckpoint` filters.
    public var transactionBlocks: TransactionBlocks { __data["transactionBlocks"] }

    /// TransactionBlocks
    ///
    /// Parent Type: `TransactionBlockConnection`
    public struct TransactionBlocks: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlockConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self)
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// TransactionBlocks.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("hasPreviousPage", Bool.self),
          .field("startCursor", String?.self),
          .field("endCursor", String?.self)
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

      /// TransactionBlocks.Node
      ///
      /// Parent Type: `TransactionBlock`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RPC_TRANSACTION_FIELDS.self)
        ] }

        /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
        /// This serves as a unique id for the block on chain.
        public var digest: String? { __data["digest"] }
        /// Serialized form of this transaction's `TransactionData`, BCS serialized and Base64 encoded.
        public var rawTransaction: SuiKit.Base64Apollo? { __data["rawTransaction"] }
        /// The address corresponding to the public key that signed this transaction. System
        /// transactions do not have senders.
        public var sender: Sender? { __data["sender"] }
        /// A list of all signatures, Base64-encoded, from senders, and potentially the gas owner if
        /// this is a sponsored transaction.
        public var signatures: [SuiKit.Base64Apollo]? { __data["signatures"] }
        /// The effects field captures the results to the chain of executing this transaction.
        public var effects: Effects? { __data["effects"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rPC_TRANSACTION_FIELDS: RPC_TRANSACTION_FIELDS { _toFragment() }
        }

        public typealias Sender = RPC_TRANSACTION_FIELDS.Sender

        public typealias Effects = RPC_TRANSACTION_FIELDS.Effects
      }
    }
  }
}
