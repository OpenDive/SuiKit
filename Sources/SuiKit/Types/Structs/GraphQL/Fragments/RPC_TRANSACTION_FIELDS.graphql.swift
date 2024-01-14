// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_TRANSACTION_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_TRANSACTION_FIELDS on TransactionBlock { __typename digest rawTransaction: bcs @include(if: $showInput) rawTransaction: bcs @include(if: $showRawInput) sender { __typename address } signatures events(first: 50) @include(if: $showEvents) { __typename nodes { __typename ...RPC_EVENTS_FIELDS } } effects { __typename checkpoint { __typename sequenceNumber } timestamp balanceChanges @include(if: $showBalanceChanges) { __typename coinType { __typename repr } owner { __typename asAddress { __typename address } asObject { __typename address } } amount } dependencies @include(if: $showEffects) { __typename digest } status @include(if: $showEffects) gasEffects @include(if: $showEffects) { __typename gasObject { __typename owner { __typename asAddress { __typename address } asObject { __typename address } } digest version address } gasSummary { __typename storageCost storageRebate nonRefundableStorageFee computationCost } } executedEpoch: epoch @include(if: $showEffects) { __typename epochId } objectChanges @include(if: $showEffects) { __typename idCreated idDeleted inputState { __typename version digest address } outputState { __typename version digest address owner { __typename asAddress { __typename address } asObject { __typename address } } } } objectChanges @include(if: $showObjectChanges) { __typename idCreated idDeleted inputState { __typename version digest address asMoveObject { __typename contents { __typename type { __typename repr } } } owner { __typename asAddress { __typename address } asObject { __typename address } } } outputState { __typename version digest address asMoveObject { __typename contents { __typename type { __typename repr } } } owner { __typename asAddress { __typename address } asObject { __typename address } } } } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("digest", String.self),
    .field("sender", Sender?.self),
    .field("signatures", [SuiKit.Base64Apollo]?.self),
    .field("effects", Effects?.self),
    .include(if: "showInput" || "showRawInput", .field("bcs", alias: "rawTransaction", SuiKit.Base64Apollo?.self)),
    .include(if: "showEvents", .field("events", Events.self, arguments: ["first": 50])),
  ] }

  /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
  /// This serves as a unique id for the block on chain.
  public var digest: String { __data["digest"] }
  /// Serialized form of this transaction's `SenderSignedData`, BCS serialized and Base64Apollo encoded.
  public var rawTransaction: SuiKit.Base64Apollo? { __data["rawTransaction"] }
  /// The address corresponding to the public key that signed this transaction. System
  /// transactions do not have senders.
  public var sender: Sender? { __data["sender"] }
  /// A list of all signatures, Base64Apollo-encoded, from senders, and potentially the gas owner if
  /// this is a sponsored transaction.
  public var signatures: [SuiKit.Base64Apollo]? { __data["signatures"] }
  /// Events emitted by this transaction block.
  public var events: Events? { __data["events"] }
  /// The effects field captures the results to the chain of executing this transaction.
  public var effects: Effects? { __data["effects"] }

  /// Sender
  ///
  /// Parent Type: `Address`
  public struct Sender: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("address", SuiKit.SuiAddressApollo.self),
    ] }

    public var address: SuiKit.SuiAddressApollo { __data["address"] }
  }

  /// Events
  ///
  /// Parent Type: `EventConnection`
  public struct Events: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.EventConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("nodes", [Node].self),
    ] }

    /// A list of nodes.
    public var nodes: [Node] { __data["nodes"] }

    /// Events.Node
    ///
    /// Parent Type: `Event`
    public struct Node: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Event }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(RPC_EVENTS_FIELDS.self),
      ] }

      /// The Move module containing some function that when called by
      /// a programmable transaction block (PTB) emitted this event.
      /// For example, if a PTB invokes A::m1::foo, which internally
      /// calls A::m2::emit_event to emit an event,
      /// the sending module would be A::m1.
      public var sendingModule: RPC_EVENTS_FIELDS.SendingModule? { __data["sendingModule"] }
      /// Addresses of the senders of the event
      public var senders: [RPC_EVENTS_FIELDS.Sender]? { __data["senders"] }
      public var type: RPC_EVENTS_FIELDS.Type_SelectionSet { __data["type"] }
      /// Representation of a Move value in JSONApollo, where:
      ///
      /// - Addresses, IDs, and UIDs are represented in canonical form, as JSONApollo strings.
      /// - Bools are represented by JSONApollo boolean literals.
      /// - u8, u16, and u32 are represented as JSONApollo numbers.
      /// - u64, u128, and u256 are represented as JSONApollo strings.
      /// - Vectors are represented by JSONApollo arrays.
      /// - Structs are represented by JSONApollo objects.
      /// - Empty optional values are represented by `null`.
      ///
      /// This form is offered as a less verbose convenience in cases where the layout of the type is
      /// known by the client.
      public var JSONApollo: SuiKit.JSONApollo { __data["JSONApollo"] }
      public var bcs: SuiKit.Base64Apollo { __data["bcs"] }
      /// UTC timestamp in milliseconds since epoch (1/1/1970)
      public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_EVENTS_FIELDS: RPC_EVENTS_FIELDS { _toFragment() }
      }
    }
  }

  /// Effects
  ///
  /// Parent Type: `TransactionBlockEffects`
  public struct Effects: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlockEffects }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("checkpoint", Checkpoint?.self),
      .field("timestamp", SuiKit.DateTimeApollo?.self),
      .include(if: "showBalanceChanges", .field("balanceChanges", [BalanceChange]?.self)),
      .include(if: "showEffects", [
        .field("dependencies", [Dependency]?.self),
        .field("status", GraphQLEnum<SuiKit.ExecutionStatusApollo>?.self),
        .field("gasEffects", GasEffects?.self),
        .field("epoch", alias: "executedEpoch", ExecutedEpoch?.self),
      ]),
      .include(if: "showEffects" || "showObjectChanges", .field("objectChanges", [ObjectChange]?.self)),
    ] }

    /// The checkpoint this transaction was finalized in.
    public var checkpoint: Checkpoint? { __data["checkpoint"] }
    /// Timestamp corresponding to the checkpoint this transaction was finalized in.
    public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }
    /// The effect this transaction had on the balances (sum of coin values per coin type) of
    /// addresses and objects.
    public var balanceChanges: [BalanceChange]? { __data["balanceChanges"] }
    /// Transactions whose outputs this transaction depends upon.
    public var dependencies: [Dependency]? { __data["dependencies"] }
    /// Whether the transaction executed successfully or not.
    public var status: GraphQLEnum<SuiKit.ExecutionStatusApollo>? { __data["status"] }
    /// Effects to the gas object.
    public var gasEffects: GasEffects? { __data["gasEffects"] }
    /// The epoch this transaction was finalized in.
    public var executedEpoch: ExecutedEpoch? { __data["executedEpoch"] }
    /// The effect this transaction had on objects on-chain.
    public var objectChanges: [ObjectChange]? { __data["objectChanges"] }

    /// Effects.Checkpoint
    ///
    /// Parent Type: `Checkpoint`
    public struct Checkpoint: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Checkpoint }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("sequenceNumber", Int.self),
      ] }

      /// This checkpoint's position in the total order of finalized checkpoints, agreed upon by
      /// consensus.
      public var sequenceNumber: Int { __data["sequenceNumber"] }
    }

    /// Effects.BalanceChange
    ///
    /// Parent Type: `BalanceChange`
    public struct BalanceChange: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.BalanceChange }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("coinType", CoinType?.self),
        .field("owner", Owner?.self),
        .field("amount", SuiKit.BigIntApollo?.self),
      ] }

      /// The inner type of the coin whose balance has changed (e.g. `0x2::sui::SUI`).
      public var coinType: CoinType? { __data["coinType"] }
      /// The address or object whose balance has changed.
      public var owner: Owner? { __data["owner"] }
      /// The signed balance change.
      public var amount: SuiKit.BigIntApollo? { __data["amount"] }

      /// Effects.BalanceChange.CoinType
      ///
      /// Parent Type: `MoveType`
      public struct CoinType: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("repr", String.self),
        ] }

        /// Flat representation of the type signature, as a displayable string.
        public var repr: String { __data["repr"] }
      }

      /// Effects.BalanceChange.Owner
      ///
      /// Parent Type: `Owner`
      public struct Owner: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Owner }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("asAddress", AsAddress?.self),
          .field("asObject", AsObject?.self),
        ] }

        public var asAddress: AsAddress? { __data["asAddress"] }
        public var asObject: AsObject? { __data["asObject"] }

        /// Effects.BalanceChange.Owner.AsAddress
        ///
        /// Parent Type: `Address`
        public struct AsAddress: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("address", SuiKit.SuiAddressApollo.self),
          ] }

          public var address: SuiKit.SuiAddressApollo { __data["address"] }
        }

        /// Effects.BalanceChange.Owner.AsObject
        ///
        /// Parent Type: `Object`
        public struct AsObject: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("address", SuiKit.SuiAddressApollo.self),
          ] }

          /// The address of the object, named as such to avoid conflict with the address type.
          public var address: SuiKit.SuiAddressApollo { __data["address"] }
        }
      }
    }

    /// Effects.Dependency
    ///
    /// Parent Type: `TransactionBlock`
    public struct Dependency: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("digest", String.self),
      ] }

      /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
      /// This serves as a unique id for the block on chain.
      public var digest: String { __data["digest"] }
    }

    /// Effects.GasEffects
    ///
    /// Parent Type: `GasEffects`
    public struct GasEffects: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.GasEffects }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("gasObject", GasObject?.self),
        .field("gasSummary", GasSummary?.self),
      ] }

      public var gasObject: GasObject? { __data["gasObject"] }
      public var gasSummary: GasSummary? { __data["gasSummary"] }

      /// Effects.GasEffects.GasObject
      ///
      /// Parent Type: `Object`
      public struct GasObject: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("owner", Owner?.self),
          .field("digest", String.self),
          .field("version", Int.self),
          .field("address", SuiKit.SuiAddressApollo.self),
        ] }

        /// The Address or Object that owns this Object.  Immutable and Shared Objects do not have
        /// owners.
        public var owner: Owner? { __data["owner"] }
        /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
        public var digest: String { __data["digest"] }
        public var version: Int { __data["version"] }
        /// The address of the object, named as such to avoid conflict with the address type.
        public var address: SuiKit.SuiAddressApollo { __data["address"] }

        /// Effects.GasEffects.GasObject.Owner
        ///
        /// Parent Type: `Owner`
        public struct Owner: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Owner }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("asAddress", AsAddress?.self),
            .field("asObject", AsObject?.self),
          ] }

          public var asAddress: AsAddress? { __data["asAddress"] }
          public var asObject: AsObject? { __data["asObject"] }

          /// Effects.GasEffects.GasObject.Owner.AsAddress
          ///
          /// Parent Type: `Address`
          public struct AsAddress: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("address", SuiKit.SuiAddressApollo.self),
            ] }

            public var address: SuiKit.SuiAddressApollo { __data["address"] }
          }

          /// Effects.GasEffects.GasObject.Owner.AsObject
          ///
          /// Parent Type: `Object`
          public struct AsObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("address", SuiKit.SuiAddressApollo.self),
            ] }

            /// The address of the object, named as such to avoid conflict with the address type.
            public var address: SuiKit.SuiAddressApollo { __data["address"] }
          }
        }
      }

      /// Effects.GasEffects.GasSummary
      ///
      /// Parent Type: `GasCostSummary`
      public struct GasSummary: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.GasCostSummary }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("storageCost", SuiKit.BigIntApollo?.self),
          .field("storageRebate", SuiKit.BigIntApollo?.self),
          .field("nonRefundableStorageFee", SuiKit.BigIntApollo?.self),
          .field("computationCost", SuiKit.BigIntApollo?.self),
        ] }

        /// Gas paid for the data stored on-chain by this transaction (in MIST).
        public var storageCost: SuiKit.BigIntApollo? { __data["storageCost"] }
        /// Part of storage cost that can be reclaimed by cleaning up data created by this transaction
        /// (when objects are deleted or an object is modified, which is treated as a deletion followed
        /// by a creation) (in MIST).
        public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
        /// Part of storage cost that is not reclaimed when data created by this transaction is cleaned
        /// up (in MIST).
        public var nonRefundableStorageFee: SuiKit.BigIntApollo? { __data["nonRefundableStorageFee"] }
        /// Gas paid for executing this transaction (in MIST).
        public var computationCost: SuiKit.BigIntApollo? { __data["computationCost"] }
      }
    }

    /// Effects.ExecutedEpoch
    ///
    /// Parent Type: `Epoch`
    public struct ExecutedEpoch: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Epoch }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("epochId", Int.self),
      ] }

      /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change
      public var epochId: Int { __data["epochId"] }
    }

    /// Effects.ObjectChange
    ///
    /// Parent Type: `ObjectChange`
    public struct ObjectChange: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ObjectChange }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .include(if: "showEffects", .inlineFragment(IfShowEffects.self)),
        .include(if: "showObjectChanges", .inlineFragment(IfShowObjectChanges.self)),
      ] }

      public var ifShowEffects: IfShowEffects? { _asInlineFragment() }
      public var ifShowObjectChanges: IfShowObjectChanges? { _asInlineFragment() }

      /// Effects.ObjectChange.IfShowEffects
      ///
      /// Parent Type: `ObjectChange`
      public struct IfShowEffects: SuiKit.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = RPC_TRANSACTION_FIELDS.Effects.ObjectChange
        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ObjectChange }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("idCreated", Bool?.self),
          .field("idDeleted", Bool?.self),
          .field("inputState", InputState?.self),
          .field("outputState", OutputState?.self),
        ] }

        /// Whether the ID was created in this transaction.
        public var idCreated: Bool? { __data["idCreated"] }
        /// Whether the ID was deleted in this transaction.
        public var idDeleted: Bool? { __data["idDeleted"] }
        /// The contents of the object immediately before the transaction.
        public var inputState: InputState? { __data["inputState"] }
        /// The contents of the object immediately after the transaction.
        public var outputState: OutputState? { __data["outputState"] }

        /// Effects.ObjectChange.InputState
        ///
        /// Parent Type: `Object`
        public struct InputState: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("version", Int.self),
            .field("digest", String.self),
            .field("address", SuiKit.SuiAddressApollo.self),
          ] }

          public var version: Int { __data["version"] }
          /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
          public var digest: String { __data["digest"] }
          /// The address of the object, named as such to avoid conflict with the address type.
          public var address: SuiKit.SuiAddressApollo { __data["address"] }
          /// Attempts to convert the object into a MoveObject
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
          /// The Address or Object that owns this Object.  Immutable and Shared Objects do not have
          /// owners.
          public var owner: Owner? { __data["owner"] }
        }
          
          /// Effects.ObjectChange.OutputState.Owner
          ///
          /// Parent Type: `Owner`
          public struct Owner: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Owner }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asAddress", AsAddress?.self),
              .field("asObject", AsObject?.self),
            ] }

            public var asAddress: AsAddress? { __data["asAddress"] }
            public var asObject: AsObject? { __data["asObject"] }

            /// Effects.ObjectChange.OutputState.Owner.AsAddress
            ///
            /// Parent Type: `Address`
            public struct AsAddress: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }

            /// Effects.ObjectChange.OutputState.Owner.AsObject
            ///
            /// Parent Type: `Object`
            public struct AsObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }
          }
          
          /// Effects.ObjectChange.InputState.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("contents", Contents?.self),
            ] }

            /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }

            /// Effects.ObjectChange.InputState.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet.self),
              ] }

              public var type: Type_SelectionSet { __data["type"] }

              /// Effects.ObjectChange.InputState.AsMoveObject.Contents.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self),
                ] }

                /// Flat representation of the type signature, as a displayable string.
                public var repr: String { __data["repr"] }
              }
            }
          }

        /// Effects.ObjectChange.OutputState
        ///
        /// Parent Type: `Object`
        public struct OutputState: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("version", Int.self),
            .field("digest", String.self),
            .field("address", SuiKit.SuiAddressApollo.self),
            .field("owner", Owner?.self),
          ] }

          public var version: Int { __data["version"] }
          /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
          public var digest: String { __data["digest"] }
          /// The address of the object, named as such to avoid conflict with the address type.
          public var address: SuiKit.SuiAddressApollo { __data["address"] }
          /// The Address or Object that owns this Object.  Immutable and Shared Objects do not have
          /// owners.
          public var owner: Owner? { __data["owner"] }
          /// Attempts to convert the object into a MoveObject
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
            
            /// Effects.ObjectChange.InputState.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            public struct AsMoveObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("contents", Contents?.self),
              ] }

              /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
              /// provides the flat representation of the type signature, and the bcs of the corresponding
              /// data
              public var contents: Contents? { __data["contents"] }

              /// Effects.ObjectChange.InputState.AsMoveObject.Contents
              ///
              /// Parent Type: `MoveValue`
              public struct Contents: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("type", Type_SelectionSet.self),
                ] }

                public var type: Type_SelectionSet { __data["type"] }

                /// Effects.ObjectChange.InputState.AsMoveObject.Contents.Type_SelectionSet
                ///
                /// Parent Type: `MoveType`
                public struct Type_SelectionSet: SuiKit.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                  public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("repr", String.self),
                  ] }

                  /// Flat representation of the type signature, as a displayable string.
                  public var repr: String { __data["repr"] }
                }
              }
            }

          /// Effects.ObjectChange.OutputState.Owner
          ///
          /// Parent Type: `Owner`
          public struct Owner: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Owner }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asAddress", AsAddress?.self),
              .field("asObject", AsObject?.self),
            ] }

            public var asAddress: AsAddress? { __data["asAddress"] }
            public var asObject: AsObject? { __data["asObject"] }

            /// Effects.ObjectChange.OutputState.Owner.AsAddress
            ///
            /// Parent Type: `Address`
            public struct AsAddress: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }

            /// Effects.ObjectChange.OutputState.Owner.AsObject
            ///
            /// Parent Type: `Object`
            public struct AsObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }
          }
        }
      }

      /// Effects.ObjectChange.IfShowObjectChanges
      ///
      /// Parent Type: `ObjectChange`
      public struct IfShowObjectChanges: SuiKit.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = RPC_TRANSACTION_FIELDS.Effects.ObjectChange
        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ObjectChange }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("idCreated", Bool?.self),
          .field("idDeleted", Bool?.self),
          .field("inputState", InputState?.self),
          .field("outputState", OutputState?.self),
        ] }

        /// Whether the ID was created in this transaction.
        public var idCreated: Bool? { __data["idCreated"] }
        /// Whether the ID was deleted in this transaction.
        public var idDeleted: Bool? { __data["idDeleted"] }
        /// The contents of the object immediately before the transaction.
        public var inputState: InputState? { __data["inputState"] }
        /// The contents of the object immediately after the transaction.
        public var outputState: OutputState? { __data["outputState"] }

        /// Effects.ObjectChange.InputState
        ///
        /// Parent Type: `Object`
        public struct InputState: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("version", Int.self),
            .field("digest", String.self),
            .field("address", SuiKit.SuiAddressApollo.self),
            .field("asMoveObject", AsMoveObject?.self),
            .field("owner", Owner?.self),
          ] }

          public var version: Int { __data["version"] }
          /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
          public var digest: String { __data["digest"] }
          /// The address of the object, named as such to avoid conflict with the address type.
          public var address: SuiKit.SuiAddressApollo { __data["address"] }
          /// Attempts to convert the object into a MoveObject
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
          /// The Address or Object that owns this Object.  Immutable and Shared Objects do not have
          /// owners.
          public var owner: Owner? { __data["owner"] }

          /// Effects.ObjectChange.InputState.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("contents", Contents?.self),
            ] }

            /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }

            /// Effects.ObjectChange.InputState.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet.self),
              ] }

              public var type: Type_SelectionSet { __data["type"] }

              /// Effects.ObjectChange.InputState.AsMoveObject.Contents.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self),
                ] }

                /// Flat representation of the type signature, as a displayable string.
                public var repr: String { __data["repr"] }
              }
            }
          }

          /// Effects.ObjectChange.InputState.Owner
          ///
          /// Parent Type: `Owner`
          public struct Owner: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Owner }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asAddress", AsAddress?.self),
              .field("asObject", AsObject?.self),
            ] }

            public var asAddress: AsAddress? { __data["asAddress"] }
            public var asObject: AsObject? { __data["asObject"] }

            /// Effects.ObjectChange.InputState.Owner.AsAddress
            ///
            /// Parent Type: `Address`
            public struct AsAddress: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }

            /// Effects.ObjectChange.InputState.Owner.AsObject
            ///
            /// Parent Type: `Object`
            public struct AsObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }
          }
        }

        /// Effects.ObjectChange.OutputState
        ///
        /// Parent Type: `Object`
        public struct OutputState: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("version", Int.self),
            .field("digest", String.self),
            .field("address", SuiKit.SuiAddressApollo.self),
            .field("asMoveObject", AsMoveObject?.self),
            .field("owner", Owner?.self),
          ] }

          public var version: Int { __data["version"] }
          /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
          public var digest: String { __data["digest"] }
          /// The address of the object, named as such to avoid conflict with the address type.
          public var address: SuiKit.SuiAddressApollo { __data["address"] }
          /// Attempts to convert the object into a MoveObject
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
          /// The Address or Object that owns this Object.  Immutable and Shared Objects do not have
          /// owners.
          public var owner: Owner? { __data["owner"] }

          /// Effects.ObjectChange.OutputState.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("contents", Contents?.self),
            ] }

            /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }

            /// Effects.ObjectChange.OutputState.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet.self),
              ] }

              public var type: Type_SelectionSet { __data["type"] }

              /// Effects.ObjectChange.OutputState.AsMoveObject.Contents.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self),
                ] }

                /// Flat representation of the type signature, as a displayable string.
                public var repr: String { __data["repr"] }
              }
            }
          }

          /// Effects.ObjectChange.OutputState.Owner
          ///
          /// Parent Type: `Owner`
          public struct Owner: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Owner }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asAddress", AsAddress?.self),
              .field("asObject", AsObject?.self),
            ] }

            public var asAddress: AsAddress? { __data["asAddress"] }
            public var asObject: AsObject? { __data["asObject"] }

            /// Effects.ObjectChange.OutputState.Owner.AsAddress
            ///
            /// Parent Type: `Address`
            public struct AsAddress: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }

            /// Effects.ObjectChange.OutputState.Owner.AsObject
            ///
            /// Parent Type: `Object`
            public struct AsObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", SuiKit.SuiAddressApollo.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var address: SuiKit.SuiAddressApollo { __data["address"] }
            }
          }
        }
      }
    }
  }
}
