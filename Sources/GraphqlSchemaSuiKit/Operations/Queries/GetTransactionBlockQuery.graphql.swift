// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetTransactionBlockQuery: GraphQLQuery {
  public static let operationName: String = "getTransactionBlock"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getTransactionBlock($digest: String!) { transaction(digest: $digest) { __typename ...TRANSACTION_FIELDS } }"#,
      fragments: [TRANSACTION_FIELDS.self]
    ))

  public var digest: String

  public init(digest: String) {
    self.digest = digest
  }

  @_spi(Unsafe) public var __variables: Variables? { ["digest": digest] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("transaction", Transaction?.self, arguments: ["digest": .variable("digest")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetTransactionBlockQuery.Data.self
    ] }

    /// Fetch a transaction by its digest.
    ///
    /// Returns `null` if the transaction does not exist in the store, either because it never existed or because it was pruned.
    public var transaction: Transaction? { __data["transaction"] }

    /// Transaction
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
        GetTransactionBlockQuery.Data.Transaction.self,
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
