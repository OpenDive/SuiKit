// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetTransactionBlockQuery: GraphQLQuery {
  public static let operationName: String = "getTransactionBlock"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getTransactionBlock($digest: String!, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false) { transactionBlock(digest: $digest) { __typename ...RPC_TRANSACTION_FIELDS } }"#,
      fragments: [RPC_TRANSACTION_FIELDS.self]
    ))

  public var digest: String
  public var showBalanceChanges: GraphQLNullable<Bool>
  public var showEffects: GraphQLNullable<Bool>
  public var showInput: GraphQLNullable<Bool>
  public var showObjectChanges: GraphQLNullable<Bool>
  public var showRawInput: GraphQLNullable<Bool>

  public init(
    digest: String,
    showBalanceChanges: GraphQLNullable<Bool> = false,
    showEffects: GraphQLNullable<Bool> = false,
    showInput: GraphQLNullable<Bool> = false,
    showObjectChanges: GraphQLNullable<Bool> = false,
    showRawInput: GraphQLNullable<Bool> = false
  ) {
    self.digest = digest
    self.showBalanceChanges = showBalanceChanges
    self.showEffects = showEffects
    self.showInput = showInput
    self.showObjectChanges = showObjectChanges
    self.showRawInput = showRawInput
  }

  public var __variables: Variables? { [
    "digest": digest,
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
      .field("transactionBlock", TransactionBlock?.self, arguments: ["digest": .variable("digest")]),
    ] }

    public var transactionBlock: TransactionBlock? { __data["transactionBlock"] }

    /// TransactionBlock
    ///
    /// Parent Type: `TransactionBlock`
    public struct TransactionBlock: SuiKit.SelectionSet {
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