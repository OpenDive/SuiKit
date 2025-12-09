// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct TRANSACTION_FIELDS: GraphqlSchemaSuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment TRANSACTION_FIELDS on Transaction { __typename digest transactionBcs signatures { __typename signatureBytes } effects { __typename effectsBcs epoch { __typename epochId } unchangedConsensusObjects { __typename nodes { __typename ... on ConsensusObjectRead { object { __typename asMoveObject { __typename address contents { __typename type { __typename repr } } } } } } } objectChanges { __typename nodes { __typename address inputState { __typename version asMoveObject { __typename address contents { __typename type { __typename repr } } } } outputState { __typename asMoveObject { __typename address contents { __typename type { __typename repr } } } } } } balanceChanges(first: 50) { __typename pageInfo { __typename hasNextPage } nodes { __typename owner { __typename address } coinType { __typename repr } amount } } } }"#
  }

  @_spi(Unsafe) public let __data: DataDict
  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Transaction }
  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("digest", String.self),
    .field("transactionBcs", GraphqlSchemaSuiKit.Base64?.self),
    .field("signatures", [Signature].self),
    .field("effects", Effects?.self),
  ] }
  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

  /// Signature
  ///
  /// Parent Type: `UserSignature`
  public struct Signature: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.UserSignature }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("signatureBytes", GraphqlSchemaSuiKit.Base64?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TRANSACTION_FIELDS.Signature.self
    ] }

    /// The signature bytes, Base64-encoded.
    /// For simple signatures: flag || signature || pubkey
    /// For complex signatures: flag || bcs_serialized_struct
    public var signatureBytes: GraphqlSchemaSuiKit.Base64? { __data["signatureBytes"] }
  }

  /// Effects
  ///
  /// Parent Type: `TransactionEffects`
  public struct Effects: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.TransactionEffects }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("effectsBcs", GraphqlSchemaSuiKit.Base64?.self),
      .field("epoch", Epoch?.self),
      .field("unchangedConsensusObjects", UnchangedConsensusObjects?.self),
      .field("objectChanges", ObjectChanges?.self),
      .field("balanceChanges", BalanceChanges?.self, arguments: ["first": 50]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TRANSACTION_FIELDS.Effects.self
    ] }

    /// The Base64-encoded BCS serialization of these effects, as `TransactionEffects`.
    public var effectsBcs: GraphqlSchemaSuiKit.Base64? { __data["effectsBcs"] }
    /// The epoch this transaction was finalized in.
    public var epoch: Epoch? { __data["epoch"] }
    /// The unchanged consensus-managed objects that were referenced by this transaction.
    public var unchangedConsensusObjects: UnchangedConsensusObjects? { __data["unchangedConsensusObjects"] }
    /// The before and after state of objects that were modified by this transaction.
    public var objectChanges: ObjectChanges? { __data["objectChanges"] }
    /// The effect this transaction had on the balances (sum of coin values per coin type) of addresses and objects.
    public var balanceChanges: BalanceChanges? { __data["balanceChanges"] }

    /// Effects.Epoch
    ///
    /// Parent Type: `Epoch`
    public struct Epoch: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Epoch }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("epochId", GraphqlSchemaSuiKit.UInt53.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TRANSACTION_FIELDS.Effects.Epoch.self
      ] }

      /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
      public var epochId: GraphqlSchemaSuiKit.UInt53 { __data["epochId"] }
    }

    /// Effects.UnchangedConsensusObjects
    ///
    /// Parent Type: `UnchangedConsensusObjectConnection`
    public struct UnchangedConsensusObjects: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.UnchangedConsensusObjectConnection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.self
      ] }

      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Effects.UnchangedConsensusObjects.Node
      ///
      /// Parent Type: `UnchangedConsensusObject`
      public struct Node: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Unions.UnchangedConsensusObject }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsConsensusObjectRead.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node.self
        ] }

        public var asConsensusObjectRead: AsConsensusObjectRead? { _asInlineFragment() }

        /// Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead
        ///
        /// Parent Type: `ConsensusObjectRead`
        public struct AsConsensusObjectRead: GraphqlSchemaSuiKit.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ConsensusObjectRead }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("object", Object?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node.self,
            TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.self
          ] }

          /// The version of the consensus-managed object that was read by this transaction.
          public var object: Object? { __data["object"] }

          /// Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object
          ///
          /// Parent Type: `Object`
          public struct Object: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Object }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("asMoveObject", AsMoveObject?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object.self
            ] }

            /// Attempts to convert the object into a MoveObject.
            public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

            /// Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            public struct AsMoveObject: GraphqlSchemaSuiKit.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveObject }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
                .field("contents", Contents?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object.AsMoveObject.self
              ] }

              /// The MoveObject's ID.
              public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
              /// The structured representation of the object's contents.
              public var contents: Contents? { __data["contents"] }

              /// Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object.AsMoveObject.Contents
              ///
              /// Parent Type: `MoveValue`
              public struct Contents: GraphqlSchemaSuiKit.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("type", Type_SelectionSet?.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object.AsMoveObject.Contents.self
                ] }

                /// The value's type.
                public var type: Type_SelectionSet? { __data["type"] }

                /// Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object.AsMoveObject.Contents.Type_SelectionSet
                ///
                /// Parent Type: `MoveType`
                public struct Type_SelectionSet: GraphqlSchemaSuiKit.SelectionSet {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
                  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("repr", String.self),
                  ] }
                  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    TRANSACTION_FIELDS.Effects.UnchangedConsensusObjects.Node.AsConsensusObjectRead.Object.AsMoveObject.Contents.Type_SelectionSet.self
                  ] }

                  /// Flat representation of the type signature, as a displayable string.
                  public var repr: String { __data["repr"] }
                }
              }
            }
          }
        }
      }
    }

    /// Effects.ObjectChanges
    ///
    /// Parent Type: `ObjectChangeConnection`
    public struct ObjectChanges: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ObjectChangeConnection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TRANSACTION_FIELDS.Effects.ObjectChanges.self
      ] }

      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Effects.ObjectChanges.Node
      ///
      /// Parent Type: `ObjectChange`
      public struct Node: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ObjectChange }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
          .field("inputState", InputState?.self),
          .field("outputState", OutputState?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TRANSACTION_FIELDS.Effects.ObjectChanges.Node.self
        ] }

        /// The address of the object that has changed.
        public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
        /// The contents of the object immediately before the transaction.
        public var inputState: InputState? { __data["inputState"] }
        /// The contents of the object immediately after the transaction.
        public var outputState: OutputState? { __data["outputState"] }

        /// Effects.ObjectChanges.Node.InputState
        ///
        /// Parent Type: `Object`
        public struct InputState: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Object }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("version", GraphqlSchemaSuiKit.UInt53?.self),
            .field("asMoveObject", AsMoveObject?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.self
          ] }

          /// The version of this object that this content comes from.
          public var version: GraphqlSchemaSuiKit.UInt53? { __data["version"] }
          /// Attempts to convert the object into a MoveObject.
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

          /// Effects.ObjectChanges.Node.InputState.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveObject }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
              .field("contents", Contents?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.AsMoveObject.self
            ] }

            /// The MoveObject's ID.
            public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
            /// The structured representation of the object's contents.
            public var contents: Contents? { __data["contents"] }

            /// Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: GraphqlSchemaSuiKit.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents.self
              ] }

              /// The value's type.
              public var type: Type_SelectionSet? { __data["type"] }

              /// Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: GraphqlSchemaSuiKit.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents.Type_SelectionSet.self
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
        public struct OutputState: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Object }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("asMoveObject", AsMoveObject?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.self
          ] }

          /// Attempts to convert the object into a MoveObject.
          public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

          /// Effects.ObjectChanges.Node.OutputState.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveObject }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
              .field("contents", Contents?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMoveObject.self
            ] }

            /// The MoveObject's ID.
            public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
            /// The structured representation of the object's contents.
            public var contents: Contents? { __data["contents"] }

            /// Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: GraphqlSchemaSuiKit.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents.self
              ] }

              /// The value's type.
              public var type: Type_SelectionSet? { __data["type"] }

              /// Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: GraphqlSchemaSuiKit.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents.Type_SelectionSet.self
                ] }

                /// Flat representation of the type signature, as a displayable string.
                public var repr: String { __data["repr"] }
              }
            }
          }
        }
      }
    }

    /// Effects.BalanceChanges
    ///
    /// Parent Type: `BalanceChangeConnection`
    public struct BalanceChanges: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.BalanceChangeConnection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TRANSACTION_FIELDS.Effects.BalanceChanges.self
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Effects.BalanceChanges.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.PageInfo }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TRANSACTION_FIELDS.Effects.BalanceChanges.PageInfo.self
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
      }

      /// Effects.BalanceChanges.Node
      ///
      /// Parent Type: `BalanceChange`
      public struct Node: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.BalanceChange }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("owner", Owner?.self),
          .field("coinType", CoinType?.self),
          .field("amount", GraphqlSchemaSuiKit.BigInt?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TRANSACTION_FIELDS.Effects.BalanceChanges.Node.self
        ] }

        /// The address or object whose balance has changed.
        public var owner: Owner? { __data["owner"] }
        /// The inner type of the coin whose balance has changed (e.g. `0x2::sui::SUI`).
        public var coinType: CoinType? { __data["coinType"] }
        /// The signed balance change.
        public var amount: GraphqlSchemaSuiKit.BigInt? { __data["amount"] }

        /// Effects.BalanceChanges.Node.Owner
        ///
        /// Parent Type: `Address`
        public struct Owner: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Address }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TRANSACTION_FIELDS.Effects.BalanceChanges.Node.Owner.self
          ] }

          /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
          public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
        }

        /// Effects.BalanceChanges.Node.CoinType
        ///
        /// Parent Type: `MoveType`
        public struct CoinType: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("repr", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TRANSACTION_FIELDS.Effects.BalanceChanges.Node.CoinType.self
          ] }

          /// Flat representation of the type signature, as a displayable string.
          public var repr: String { __data["repr"] }
        }
      }
    }
  }
}
