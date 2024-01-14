// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class QueryTransactionBlocksQuery: GraphQLQuery {
  public static let operationName: String = "queryTransactionBlocks"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query queryTransactionBlocks($first: Int, $last: Int, $before: String, $after: String, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showEvents: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false, $filter: TransactionBlockFilter) { transactionBlockConnection( first: $first after: $after last: $last before: $before filter: $filter ) { __typename pageInfo { __typename hasNextPage hasPreviousPage startCursor endCursor } nodes { __typename ...RPC_TRANSACTION_FIELDS } } }"#,
      fragments: [RPC_EVENTS_FIELDS.self, RPC_TRANSACTION_FIELDS.self]
    ))

  public var first: GraphQLNullable<Int>
  public var last: GraphQLNullable<Int>
  public var before: GraphQLNullable<String>
  public var after: GraphQLNullable<String>
  public var showBalanceChanges: GraphQLNullable<Bool>
  public var showEffects: GraphQLNullable<Bool>
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
    "showEvents": showEvents,
    "showInput": showInput,
    "showObjectChanges": showObjectChanges,
    "showRawInput": showRawInput,
    "filter": filter
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("transactionBlockConnection", TransactionBlockConnection?.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after"),
        "last": .variable("last"),
        "before": .variable("before"),
        "filter": .variable("filter")
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
        /// This serves as a unique id for the block on chain.
        public var digest: String { __data["digest"] }
        /// Serialized form of this transaction's `SenderSignedData`, BCS serialized and Base64Apollo encoded.
        public var rawTransaction: SuiKit.Base64Apollo? { __data["rawTransaction"] }
        /// The address corresponding to the public key that signed this transaction. System
        /// transactions do not have senders.
        public var sender: RPC_TRANSACTION_FIELDS.Sender? { __data["sender"] }
        /// A list of all signatures, Base64Apollo-encoded, from senders, and potentially the gas owner if
        /// this is a sponsored transaction.
        public var signatures: [SuiKit.Base64Apollo]? { __data["signatures"] }
        /// Events emitted by this transaction block.
        public var events: RPC_TRANSACTION_FIELDS.Events? { __data["events"] }
        /// The effects field captures the results to the chain of executing this transaction.
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
