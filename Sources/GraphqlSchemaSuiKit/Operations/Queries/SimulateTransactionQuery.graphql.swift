// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct SimulateTransactionQuery: GraphQLQuery {
  public static let operationName: String = "simulateTransaction"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query simulateTransaction($transaction: JSON!) { simulateTransaction(transaction: $transaction) { __typename error effects { __typename transaction { __typename ...TRANSACTION_FIELDS } } } }"#,
      fragments: [TRANSACTION_FIELDS.self]
    ))

  public var transaction: JSON

  public init(transaction: JSON) {
    self.transaction = transaction
  }

  @_spi(Unsafe) public var __variables: Variables? { ["transaction": transaction] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("simulateTransaction", SimulateTransaction.self, arguments: ["transaction": .variable("transaction")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      SimulateTransactionQuery.Data.self
    ] }

    /// Simulate a transaction to preview its effects without executing it on chain.
    ///
    /// Accepts a JSON transaction matching the [Sui gRPC API schema](https://docs.sui.io/references/fullnode-protocol#sui-rpc-v2-Transaction).
    /// The JSON format allows for partial transaction specification where certain fields can be automatically resolved by the server.
    ///
    /// Alternatively, for already serialized transactions, you can pass BCS-encoded data:
    /// `{"bcs": {"value": "<base64>"}}`
    ///
    /// Unlike `executeTransaction`, this does not require signatures since the transaction is not committed to the blockchain. This allows for previewing transaction effects, estimating gas costs, and testing transaction logic without spending gas or requiring valid signatures.
    public var simulateTransaction: SimulateTransaction { __data["simulateTransaction"] }

    /// SimulateTransaction
    ///
    /// Parent Type: `SimulationResult`
    public struct SimulateTransaction: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.SimulationResult }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("error", String?.self),
        .field("effects", Effects?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SimulateTransactionQuery.Data.SimulateTransaction.self
      ] }

      /// Error message if the simulation failed.
      ///
      /// `None` if the simulation was successful.
      public var error: String? { __data["error"] }
      /// The predicted effects of the transaction if it were executed.
      ///
      /// `None` if the simulation failed due to an error.
      public var effects: Effects? { __data["effects"] }

      /// SimulateTransaction.Effects
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
          SimulateTransactionQuery.Data.SimulateTransaction.Effects.self
        ] }

        /// The transaction that ran to produce these effects.
        public var transaction: Transaction? { __data["transaction"] }

        /// SimulateTransaction.Effects.Transaction
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
            SimulateTransactionQuery.Data.SimulateTransaction.Effects.Transaction.self,
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
