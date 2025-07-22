// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ExecuteTransactionBlockMutation: GraphQLMutation {
  public static let operationName: String = "executeTransactionBlock"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation executeTransactionBlock($txBytes: String!, $signatures: [String!]!, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false) { executeTransactionBlock(txBytes: $txBytes, signatures: $signatures) { __typename errors effects { __typename transactionBlock { __typename ...RPC_TRANSACTION_FIELDS } } } }"#,
      fragments: [RPC_EVENTS_FIELDS.self, RPC_TRANSACTION_FIELDS.self]
    ))

  public var txBytes: String
  public var signatures: [String]
  public var showBalanceChanges: GraphQLNullable<Bool>
  public var showEffects: GraphQLNullable<Bool>
  public var showRawEffects: GraphQLNullable<Bool>
  public var showEvents: GraphQLNullable<Bool>
  public var showInput: GraphQLNullable<Bool>
  public var showObjectChanges: GraphQLNullable<Bool>
  public var showRawInput: GraphQLNullable<Bool>

  public init(
    txBytes: String,
    signatures: [String],
    showBalanceChanges: GraphQLNullable<Bool> = false,
    showEffects: GraphQLNullable<Bool> = false,
    showRawEffects: GraphQLNullable<Bool> = false,
    showEvents: GraphQLNullable<Bool> = false,
    showInput: GraphQLNullable<Bool> = false,
    showObjectChanges: GraphQLNullable<Bool> = false,
    showRawInput: GraphQLNullable<Bool> = false
  ) {
    self.txBytes = txBytes
    self.signatures = signatures
    self.showBalanceChanges = showBalanceChanges
    self.showEffects = showEffects
    self.showRawEffects = showRawEffects
    self.showEvents = showEvents
    self.showInput = showInput
    self.showObjectChanges = showObjectChanges
    self.showRawInput = showRawInput
  }

  public var __variables: Variables? { [
    "txBytes": txBytes,
    "signatures": signatures,
    "showBalanceChanges": showBalanceChanges,
    "showEffects": showEffects,
    "showRawEffects": showRawEffects,
    "showEvents": showEvents,
    "showInput": showInput,
    "showObjectChanges": showObjectChanges,
    "showRawInput": showRawInput
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("executeTransactionBlock", ExecuteTransactionBlock.self, arguments: [
        "txBytes": .variable("txBytes"),
        "signatures": .variable("signatures")
      ])
    ] }

    /// Execute a transaction, committing its effects on chain.
    ///
    /// - `txBytes` is a `TransactionData` struct that has been BCS-encoded and then Base64-encoded.
    /// - `signatures` are a list of `flag || signature || pubkey` bytes, Base64-encoded.
    ///
    /// Waits until the transaction has reached finality on chain to return its transaction digest,
    /// or returns the error that prevented finality if that was not possible. A transaction is
    /// final when its effects are guaranteed on chain (it cannot be revoked).
    ///
    /// There may be a delay between transaction finality and when GraphQL requests (including the
    /// request that issued the transaction) reflect its effects. As a result, queries that depend
    /// on indexing the state of the chain (e.g. contents of output objects, address-level balance
    /// information at the time of the transaction), must wait for indexing to catch up by polling
    /// for the transaction digest using `Query.transactionBlock`.
    public var executeTransactionBlock: ExecuteTransactionBlock { __data["executeTransactionBlock"] }

    /// ExecuteTransactionBlock
    ///
    /// Parent Type: `ExecutionResult`
    public struct ExecuteTransactionBlock: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ExecutionResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("errors", [String]?.self),
        .field("effects", Effects.self)
      ] }

      /// The errors field captures any errors that occurred during execution
      public var errors: [String]? { __data["errors"] }
      /// The effects of the executed transaction. Since the transaction was just executed
      /// and not indexed yet, fields including `balance_changes`, `timestamp` and `checkpoint`
      /// are not available.
      public var effects: Effects { __data["effects"] }

      /// ExecuteTransactionBlock.Effects
      ///
      /// Parent Type: `TransactionBlockEffects`
      public struct Effects: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlockEffects }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("transactionBlock", TransactionBlock?.self)
        ] }

        /// The transaction that ran to produce these effects.
        public var transactionBlock: TransactionBlock? { __data["transactionBlock"] }

        /// ExecuteTransactionBlock.Effects.TransactionBlock
        ///
        /// Parent Type: `TransactionBlock`
        public struct TransactionBlock: SuiKit.SelectionSet {
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
}
