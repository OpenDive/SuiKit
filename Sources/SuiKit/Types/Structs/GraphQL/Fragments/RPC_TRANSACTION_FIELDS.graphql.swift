// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_TRANSACTION_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_TRANSACTION_FIELDS on TransactionBlock { __typename digest rawTransaction: bcs @include(if: $showInput) rawTransaction: bcs @include(if: $showRawInput) sender { __typename address } signatures effects { __typename bcs @include(if: $showEffects) bcs @include(if: $showObjectChanges) bcs @include(if: $showRawEffects) events @include(if: $showEvents) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_EVENTS_FIELDS } } checkpoint { __typename sequenceNumber } timestamp balanceChanges @include(if: $showBalanceChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename coinType { __typename repr } owner { __typename asObject { __typename address } asAddress { __typename address } } amount } } objectChanges @include(if: $showObjectChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename address inputState { __typename version asMoveObject { __typename contents { __typename type { __typename repr } } } } outputState { __typename asMoveObject { __typename contents { __typename type { __typename repr } } } asMovePackage { __typename modules(first: 10) { __typename nodes { __typename name } } } } } } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("digest", String?.self),
    .field("sender", Sender?.self),
    .field("signatures", [SuiKit.Base64Apollo]?.self),
    .field("effects", Effects?.self),
    .include(if: "showInput" || "showRawInput", .field("bcs", alias: "rawTransaction", SuiKit.Base64Apollo?.self))
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

  /// Sender
  ///
  /// Parent Type: `Address`
  public struct Sender: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Address }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("address", SuiKit.SuiAddressApollo.self)
    ] }

    public var address: SuiKit.SuiAddressApollo { __data["address"] }
  }

  /// Effects
  ///
  /// Parent Type: `TransactionBlockEffects`
  public struct Effects: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlockEffects }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("checkpoint", Checkpoint?.self),
      .field("timestamp", SuiKit.DateTimeApollo?.self),
      .include(if: "showEffects" || "showObjectChanges" || "showRawEffects", .field("bcs", SuiKit.Base64Apollo.self)),
      .include(if: "showEvents", .field("events", Events.self)),
      .include(if: "showBalanceChanges", .field("balanceChanges", BalanceChanges.self)),
      .include(if: "showObjectChanges", .field("objectChanges", ObjectChanges.self))
    ] }

    /// Base64 encoded bcs serialization of the on-chain transaction effects.
    public var bcs: SuiKit.Base64Apollo? { __data["bcs"] }
    /// Events emitted by this transaction block.
    public var events: Events? { __data["events"] }
    /// The checkpoint this transaction was finalized in.
    public var checkpoint: Checkpoint? { __data["checkpoint"] }
    /// Timestamp corresponding to the checkpoint this transaction was finalized in.
    public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }
    /// The effect this transaction had on the balances (sum of coin values per coin type) of
    /// addresses and objects.
    public var balanceChanges: BalanceChanges? { __data["balanceChanges"] }
    /// The effect this transaction had on objects on-chain.
    public var objectChanges: ObjectChanges? { __data["objectChanges"] }

    /// Effects.Events
    ///
    /// Parent Type: `EventConnection`
    public struct Events: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.EventConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self)
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Effects.Events.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self)
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// Effects.Events.Node
      ///
      /// Parent Type: `Event`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Event }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RPC_EVENTS_FIELDS.self)
        ] }

        /// The Move module containing some function that when called by
        /// a programmable transaction block (PTB) emitted this event.
        /// For example, if a PTB invokes A::m1::foo, which internally
        /// calls A::m2::emit_event to emit an event,
        /// the sending module would be A::m1.
        public var sendingModule: SendingModule? { __data["sendingModule"] }
        /// Address of the sender of the event
        public var sender: Sender? { __data["sender"] }
        /// The event's contents as a Move value.
        public var contents: Contents { __data["contents"] }
        /// UTC timestamp in milliseconds since epoch (1/1/1970)
        public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rPC_EVENTS_FIELDS: RPC_EVENTS_FIELDS { _toFragment() }
        }

        public typealias SendingModule = RPC_EVENTS_FIELDS.SendingModule

        public typealias Sender = RPC_EVENTS_FIELDS.Sender

        public typealias Contents = RPC_EVENTS_FIELDS.Contents
      }
    }

    /// Effects.Checkpoint
    ///
    /// Parent Type: `Checkpoint`
    public struct Checkpoint: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Checkpoint }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("sequenceNumber", SuiKit.UInt53Apollo.self)
      ] }

      /// This checkpoint's position in the total order of finalized checkpoints, agreed upon by
      /// consensus.
      public var sequenceNumber: SuiKit.UInt53Apollo { __data["sequenceNumber"] }
    }

    /// Effects.BalanceChanges
    ///
    /// Parent Type: `BalanceChangeConnection`
    public struct BalanceChanges: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.BalanceChangeConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self)
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Effects.BalanceChanges.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self)
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// Effects.BalanceChanges.Node
      ///
      /// Parent Type: `BalanceChange`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.BalanceChange }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("coinType", CoinType?.self),
          .field("owner", Owner?.self),
          .field("amount", SuiKit.BigIntApollo?.self)
        ] }

        /// The inner type of the coin whose balance has changed (e.g. `0x2::sui::SUI`).
        public var coinType: CoinType? { __data["coinType"] }
        /// The address or object whose balance has changed.
        public var owner: Owner? { __data["owner"] }
        /// The signed balance change.
        public var amount: SuiKit.BigIntApollo? { __data["amount"] }

        /// Effects.BalanceChanges.Node.CoinType
        ///
        /// Parent Type: `MoveType`
        public struct CoinType: SuiKit.SelectionSet {
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

        /// Effects.BalanceChanges.Node.Owner
        ///
        /// Parent Type: `Owner`
        public struct Owner: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Owner }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("asObject", AsObject?.self),
            .field("asAddress", AsAddress?.self)
          ] }

          public var asObject: AsObject? { __data["asObject"] }
          public var asAddress: AsAddress? { __data["asAddress"] }

          /// Effects.BalanceChanges.Node.Owner.AsObject
          ///
          /// Parent Type: `Object`
          public struct AsObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("address", SuiKit.SuiAddressApollo.self)
            ] }

            public var address: SuiKit.SuiAddressApollo { __data["address"] }
          }

          /// Effects.BalanceChanges.Node.Owner.AsAddress
          ///
          /// Parent Type: `Address`
          public struct AsAddress: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Address }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("address", SuiKit.SuiAddressApollo.self)
            ] }

            public var address: SuiKit.SuiAddressApollo { __data["address"] }
          }
        }
      }
    }

    /// Effects.ObjectChanges
    ///
    /// Parent Type: `ObjectChangeConnection`
    public struct ObjectChanges: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ObjectChangeConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self)
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Effects.ObjectChanges.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self)
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// Effects.ObjectChanges.Node
      ///
      /// Parent Type: `ObjectChange`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ObjectChange }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("address", SuiKit.SuiAddressApollo.self),
          .field("inputState", InputState?.self),
          .field("outputState", OutputState?.self)
        ] }

        /// The address of the object that has changed.
        public var address: SuiKit.SuiAddressApollo { __data["address"] }
        /// The contents of the object immediately before the transaction.
        public var inputState: InputState? { __data["inputState"] }
        /// The contents of the object immediately after the transaction.
        public var outputState: OutputState? { __data["outputState"] }

        /// Effects.ObjectChanges.Node.InputState
        ///
        /// Parent Type: `Object`
        public struct InputState: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("version", SuiKit.UInt53Apollo.self),
            .field("asMoveObject", AsMoveObject?.self)
          ] }

          public var version: SuiKit.UInt53Apollo { __data["version"] }
          /// Attempts to convert the object into a MoveObject
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

          /// Effects.ObjectChanges.Node.InputState.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("contents", Contents?.self)
            ] }

            /// Displays the contents of the Move object in a JSON string and through GraphQL types. Also
            /// provides the flat representation of the type signature, and the BCS of the corresponding
            /// data.
            public var contents: Contents? { __data["contents"] }

            /// Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet.self)
              ] }

              /// The value's Move type.
              public var type: Type_SelectionSet { __data["type"] }

              /// Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents.Type_SelectionSet
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
        }

        /// Effects.ObjectChanges.Node.OutputState
        ///
        /// Parent Type: `Object`
        public struct OutputState: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("asMoveObject", AsMoveObject?.self),
            .field("asMovePackage", AsMovePackage?.self)
          ] }

          /// Attempts to convert the object into a MoveObject
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
          /// Attempts to convert the object into a MovePackage
          public var asMovePackage: AsMovePackage? { __data["asMovePackage"] }

          /// Effects.ObjectChanges.Node.OutputState.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("contents", Contents?.self)
            ] }

            /// Displays the contents of the Move object in a JSON string and through GraphQL types. Also
            /// provides the flat representation of the type signature, and the BCS of the corresponding
            /// data.
            public var contents: Contents? { __data["contents"] }

            /// Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet.self)
              ] }

              /// The value's Move type.
              public var type: Type_SelectionSet { __data["type"] }

              /// Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents.Type_SelectionSet
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

          /// Effects.ObjectChanges.Node.OutputState.AsMovePackage
          ///
          /// Parent Type: `MovePackage`
          public struct AsMovePackage: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MovePackage }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("modules", Modules?.self, arguments: ["first": 10])
            ] }

            /// Paginate through the MoveModules defined in this package.
            public var modules: Modules? { __data["modules"] }

            /// Effects.ObjectChanges.Node.OutputState.AsMovePackage.Modules
            ///
            /// Parent Type: `MoveModuleConnection`
            public struct Modules: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveModuleConnection }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("nodes", [Node].self)
              ] }

              /// A list of nodes.
              public var nodes: [Node] { __data["nodes"] }

              /// Effects.ObjectChanges.Node.OutputState.AsMovePackage.Modules.Node
              ///
              /// Parent Type: `MoveModule`
              public struct Node: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveModule }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("name", String.self)
                ] }

                /// The module's (unqualified) name.
                public var name: String { __data["name"] }
              }
            }
          }
        }
      }
    }
  }
}
