// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DevInspectTransactionBlockQuery: GraphQLQuery {
  public static let operationName: String = "devInspectTransactionBlock"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query devInspectTransactionBlock($txBytes: String!, $txMeta: TransactionMetadata!, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false) { dryRunTransactionBlock(txBytes: $txBytes, txMeta: $txMeta) { __typename error results { __typename mutatedReferences { __typename input { __typename ... on Input { inputIndex: ix } ... on Result { cmd resultIndex: ix } } type { __typename repr } bcs } returnValues { __typename type { __typename repr } bcs } } transaction { __typename ...RPC_TRANSACTION_FIELDS } } }"#,
      fragments: [RPC_EVENTS_FIELDS.self, RPC_TRANSACTION_FIELDS.self]
    ))

  public var txBytes: String
  public var txMeta: TransactionMetadata
  public var showBalanceChanges: GraphQLNullable<Bool>
  public var showEffects: GraphQLNullable<Bool>
  public var showRawEffects: GraphQLNullable<Bool>
  public var showEvents: GraphQLNullable<Bool>
  public var showInput: GraphQLNullable<Bool>
  public var showObjectChanges: GraphQLNullable<Bool>
  public var showRawInput: GraphQLNullable<Bool>

  public init(
    txBytes: String,
    txMeta: TransactionMetadata,
    showBalanceChanges: GraphQLNullable<Bool> = false,
    showEffects: GraphQLNullable<Bool> = false,
    showRawEffects: GraphQLNullable<Bool> = false,
    showEvents: GraphQLNullable<Bool> = false,
    showInput: GraphQLNullable<Bool> = false,
    showObjectChanges: GraphQLNullable<Bool> = false,
    showRawInput: GraphQLNullable<Bool> = false
  ) {
    self.txBytes = txBytes
    self.txMeta = txMeta
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
    "txMeta": txMeta,
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

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("dryRunTransactionBlock", DryRunTransactionBlock.self, arguments: [
        "txBytes": .variable("txBytes"),
        "txMeta": .variable("txMeta")
      ])
    ] }

    /// Simulate running a transaction to inspect its effects without
    /// committing to them on-chain.
    ///
    /// `txBytes` either a `TransactionData` struct or a `TransactionKind`
    /// struct, BCS-encoded and then Base64-encoded.  The expected
    /// type is controlled by the presence or absence of `txMeta`: If
    /// present, `txBytes` is assumed to be a `TransactionKind`, if
    /// absent, then `TransactionData`.
    ///
    /// `txMeta` the data that is missing from a `TransactionKind` to make
    /// a `TransactionData` (sender address and gas information).  All
    /// its fields are nullable.
    ///
    /// `skipChecks` optional flag to disable the usual verification
    /// checks that prevent access to objects that are owned by
    /// addresses other than the sender, and calling non-public,
    /// non-entry functions, and some other checks.  Defaults to false.
    public var dryRunTransactionBlock: DryRunTransactionBlock { __data["dryRunTransactionBlock"] }

    /// DryRunTransactionBlock
    ///
    /// Parent Type: `DryRunResult`
    public struct DryRunTransactionBlock: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DryRunResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("error", String?.self),
        .field("results", [Result]?.self),
        .field("transaction", Transaction?.self)
      ] }

      /// The error that occurred during dry run execution, if any.
      public var error: String? { __data["error"] }
      /// The intermediate results for each command of the dry run execution, including
      /// contents of mutated references and return values.
      public var results: [Result]? { __data["results"] }
      /// The transaction block representing the dry run execution.
      public var transaction: Transaction? { __data["transaction"] }

      /// DryRunTransactionBlock.Result
      ///
      /// Parent Type: `DryRunEffect`
      public struct Result: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DryRunEffect }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("mutatedReferences", [MutatedReference]?.self),
          .field("returnValues", [ReturnValue]?.self)
        ] }

        /// Changes made to arguments that were mutably borrowed by each command in this transaction.
        public var mutatedReferences: [MutatedReference]? { __data["mutatedReferences"] }
        /// Return results of each command in this transaction.
        public var returnValues: [ReturnValue]? { __data["returnValues"] }

        /// DryRunTransactionBlock.Result.MutatedReference
        ///
        /// Parent Type: `DryRunMutation`
        public struct MutatedReference: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DryRunMutation }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("input", Input.self),
            .field("type", Type_SelectionSet.self),
            .field("bcs", SuiKit.Base64Apollo.self)
          ] }

          public var input: Input { __data["input"] }
          public var type: Type_SelectionSet { __data["type"] }
          public var bcs: SuiKit.Base64Apollo { __data["bcs"] }

          /// DryRunTransactionBlock.Result.MutatedReference.Input
          ///
          /// Parent Type: `TransactionArgument`
          public struct Input: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Unions.TransactionArgument }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .inlineFragment(AsInput.self),
              .inlineFragment(AsResult.self)
            ] }

            public var asInput: AsInput? { _asInlineFragment() }
            public var asResult: AsResult? { _asInlineFragment() }

            /// DryRunTransactionBlock.Result.MutatedReference.Input.AsInput
            ///
            /// Parent Type: `Input`
            public struct AsInput: SuiKit.InlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = DevInspectTransactionBlockQuery.Data.DryRunTransactionBlock.Result.MutatedReference.Input
              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Input }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("ix", alias: "inputIndex", Int.self)
              ] }

              /// Index of the programmable transaction block input (0-indexed).
              public var inputIndex: Int { __data["inputIndex"] }
            }

            /// DryRunTransactionBlock.Result.MutatedReference.Input.AsResult
            ///
            /// Parent Type: `Result`
            public struct AsResult: SuiKit.InlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = DevInspectTransactionBlockQuery.Data.DryRunTransactionBlock.Result.MutatedReference.Input
              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Result }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("cmd", Int.self),
                .field("ix", alias: "resultIndex", Int?.self)
              ] }

              /// The index of the previous command (0-indexed) that returned this result.
              public var cmd: Int { __data["cmd"] }
              /// If the previous command returns multiple values, this is the index of the individual result
              /// among the multiple results from that command (also 0-indexed).
              public var resultIndex: Int? { __data["resultIndex"] }
            }
          }

          /// DryRunTransactionBlock.Result.MutatedReference.Type_SelectionSet
          ///
          /// Parent Type: `MoveType`
          public struct Type_SelectionSet: SuiKit.SelectionSet {
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

        /// DryRunTransactionBlock.Result.ReturnValue
        ///
        /// Parent Type: `DryRunReturn`
        public struct ReturnValue: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DryRunReturn }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("type", Type_SelectionSet.self),
            .field("bcs", SuiKit.Base64Apollo.self)
          ] }

          public var type: Type_SelectionSet { __data["type"] }
          public var bcs: SuiKit.Base64Apollo { __data["bcs"] }

          /// DryRunTransactionBlock.Result.ReturnValue.Type_SelectionSet
          ///
          /// Parent Type: `MoveType`
          public struct Type_SelectionSet: SuiKit.SelectionSet {
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

      /// DryRunTransactionBlock.Transaction
      ///
      /// Parent Type: `TransactionBlock`
      public struct Transaction: SuiKit.SelectionSet {
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
