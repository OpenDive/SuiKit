// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct ExecuteTransactionMutation: GraphQLMutation {
  public static let operationName: String = "executeTransaction"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation executeTransaction($transactionDataBcs: Base64!, $signatures: [Base64!]!) { executeTransaction( transactionDataBcs: $transactionDataBcs signatures: $signatures ) { __typename errors effects { __typename transaction { __typename ...TRANSACTION_FIELDS } } } }"#,
      fragments: [TRANSACTION_FIELDS.self]
    ))

  public var transactionDataBcs: Base64
  public var signatures: [Base64]

  public init(
    transactionDataBcs: Base64,
    signatures: [Base64]
  ) {
    self.transactionDataBcs = transactionDataBcs
    self.signatures = signatures
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "transactionDataBcs": transactionDataBcs,
    "signatures": signatures
  ] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("executeTransaction", ExecuteTransaction.self, arguments: [
        "transactionDataBcs": .variable("transactionDataBcs"),
        "signatures": .variable("signatures")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ExecuteTransactionMutation.Data.self
    ] }

    /// Execute a transaction, committing its effects on chain.
    ///
    /// - `transactionDataBcs` contains the BCS-encoded transaction data (Base64-encoded).
    /// - `signatures` are a list of `flag || signature || pubkey` bytes, Base64-encoded.
    ///
    /// Waits until the transaction has reached finality on chain to return its transaction digest, or returns the error that prevented finality if that was not possible. A transaction is final when its effects are guaranteed on chain (it cannot be revoked).
    ///
    /// There may be a delay between transaction finality and when GraphQL requests (including the request that issued the transaction) reflect its effects. As a result, queries that depend on indexing the state of the chain (e.g. contents of output objects, address-level balance information at the time of the transaction), must wait for indexing to catch up by polling for the transaction digest using `Query.transaction`.
    public var executeTransaction: ExecuteTransaction { __data["executeTransaction"] }

    /// ExecuteTransaction
    ///
    /// Parent Type: `ExecutionResult`
    public struct ExecuteTransaction: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ExecutionResult }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("errors", [String]?.self),
        .field("effects", Effects?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ExecuteTransactionMutation.Data.ExecuteTransaction.self
      ] }

      /// Errors that occurred during execution (e.g., network errors, validation failures).
      /// These are distinct from execution failures within the transaction itself.
      public var errors: [String]? { __data["errors"] }
      /// The effects of the transaction execution, if successful.
      public var effects: Effects? { __data["effects"] }

      /// ExecuteTransaction.Effects
      ///
      /// Parent Type: `TransactionEffects`
      public struct Effects: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.TransactionEffects }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("transaction", Transaction?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ExecuteTransactionMutation.Data.ExecuteTransaction.Effects.self
        ] }

        /// The transaction that ran to produce these effects.
        public var transaction: Transaction? { __data["transaction"] }

        /// ExecuteTransaction.Effects.Transaction
        ///
        /// Parent Type: `Transaction`
        public struct Transaction: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Transaction }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(TRANSACTION_FIELDS.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ExecuteTransactionMutation.Data.ExecuteTransaction.Effects.Transaction.self,
            TRANSACTION_FIELDS.self
          ] }

          /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
          public var digest: String { __data["digest"] }
          /// The Base64-encoded BCS serialization of this transaction, as a `TransactionData`.
          public var transactionBcs: GraphqlSchemaSuiKit.Base64? { __data["transactionBcs"] }
          /// User signatures for this transaction.
          public var signatures: [Signature] { __data["signatures"] }
          /// The results to the chain of executing this transaction.
          public var effects: Effects? { __data["effects"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var tRANSACTION_FIELDS: TRANSACTION_FIELDS { _toFragment() }
          }

          public typealias Signature = TRANSACTION_FIELDS.Signature

          public typealias Effects = TRANSACTION_FIELDS.Effects
        }
      }
    }
  }
}
