// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetCoinsQuery: GraphQLQuery {
  public static let operationName: String = "getCoins"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCoins($owner: SuiAddress!, $first: Int, $cursor: String, $type: String! = "0x2::coin::Coin<0x2::sui::SUI>") { address(address: $owner) { __typename address objects(first: $first, after: $cursor, filter: { type: $type }) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename owner { __typename ...OBJECT_OWNER_FIELDS } contents { __typename bcs json type { __typename repr } } address version digest previousTransaction { __typename digest } } } } }"#,
      fragments: [OBJECT_OWNER_FIELDS.self]
    ))

  public var owner: SuiAddress
  public var first: GraphQLNullable<Int32>
  public var cursor: GraphQLNullable<String>
  public var type: String

  public init(
    owner: SuiAddress,
    first: GraphQLNullable<Int32>,
    cursor: GraphQLNullable<String>,
    type: String = "0x2::coin::Coin<0x2::sui::SUI>"
  ) {
    self.owner = owner
    self.first = first
    self.cursor = cursor
    self.type = type
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "owner": owner,
    "first": first,
    "cursor": cursor,
    "type": type
  ] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address.self, arguments: ["address": .variable("owner")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetCoinsQuery.Data.self
    ] }

    /// Look-up an account by its SuiAddress.
    ///
    /// If `rootVersion` is specified, nested dynamic field accesses will be fetched at or before this version. This can be used to fetch a child or ancestor object bounded by its root object's version, when its immediate parent is wrapped, or a value in a dynamic object field. For any wrapped or child (object-owned) object, its root object can be defined recursively as:
    ///
    /// - The root object of the object it is wrapped in, if it is wrapped.
    /// - The root object of its owner, if it is owned by another object.
    /// - The object itself, if it is not object-owned or wrapped.
    ///
    /// Specifying a `rootVersion` disables nested queries for paginating owned objects or dynamic fields (these queries are only supported at checkpoint boundaries).
    public var address: Address { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Address }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
        .field("objects", Objects?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("cursor"),
          "filter": ["type": .variable("type")]
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetCoinsQuery.Data.Address.self
      ] }

      /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
      public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
      /// Objects owned by this address, optionally filtered by type.
      public var objects: Objects? { __data["objects"] }

      /// Address.Objects
      ///
      /// Parent Type: `MoveObjectConnection`
      public struct Objects: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveObjectConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetCoinsQuery.Data.Address.Objects.self
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.Objects.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.PageInfo }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetCoinsQuery.Data.Address.Objects.PageInfo.self
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Address.Objects.Node
        ///
        /// Parent Type: `MoveObject`
        public struct Node: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveObject }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("owner", Owner?.self),
            .field("contents", Contents?.self),
            .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
            .field("version", GraphqlSchemaSuiKit.UInt53?.self),
            .field("digest", String?.self),
            .field("previousTransaction", PreviousTransaction?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetCoinsQuery.Data.Address.Objects.Node.self
          ] }

          /// The object's owner kind.
          public var owner: Owner? { __data["owner"] }
          /// The structured representation of the object's contents.
          public var contents: Contents? { __data["contents"] }
          /// The MoveObject's ID.
          public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
          /// The version of this object that this content comes from.
          public var version: GraphqlSchemaSuiKit.UInt53? { __data["version"] }
          /// 32-byte hash that identifies the object's contents, encoded in Base58.
          public var digest: String? { __data["digest"] }
          /// The transaction that created this version of the object.
          public var previousTransaction: PreviousTransaction? { __data["previousTransaction"] }

          /// Address.Objects.Node.Owner
          ///
          /// Parent Type: `Owner`
          public struct Owner: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Unions.Owner }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(OBJECT_OWNER_FIELDS.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetCoinsQuery.Data.Address.Objects.Node.Owner.self
            ] }

            public var asAddressOwner: AsAddressOwner? { _asInlineFragment() }
            public var asObjectOwner: AsObjectOwner? { _asInlineFragment() }
            public var asShared: AsShared? { _asInlineFragment() }
            public var asConsensusAddressOwner: AsConsensusAddressOwner? { _asInlineFragment() }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var oBJECT_OWNER_FIELDS: OBJECT_OWNER_FIELDS { _toFragment() }
            }

            /// Address.Objects.Node.Owner.AsAddressOwner
            ///
            /// Parent Type: `AddressOwner`
            public struct AsAddressOwner: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.AddressOwner }
              @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                OBJECT_OWNER_FIELDS.AsAddressOwner.self
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                GetCoinsQuery.Data.Address.Objects.Node.Owner.AsAddressOwner.self,
                OBJECT_OWNER_FIELDS.self,
                OBJECT_OWNER_FIELDS.AsAddressOwner.self
              ] }

              /// The owner's address.
              public var address: Address? { __data["address"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var oBJECT_OWNER_FIELDS: OBJECT_OWNER_FIELDS { _toFragment() }
              }

              public typealias Address = OBJECT_OWNER_FIELDS.AsAddressOwner.Address
            }

            /// Address.Objects.Node.Owner.AsObjectOwner
            ///
            /// Parent Type: `ObjectOwner`
            public struct AsObjectOwner: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ObjectOwner }
              @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                OBJECT_OWNER_FIELDS.AsObjectOwner.self
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                GetCoinsQuery.Data.Address.Objects.Node.Owner.AsObjectOwner.self,
                OBJECT_OWNER_FIELDS.self,
                OBJECT_OWNER_FIELDS.AsObjectOwner.self
              ] }

              /// The owner's address.
              public var address: Address? { __data["address"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var oBJECT_OWNER_FIELDS: OBJECT_OWNER_FIELDS { _toFragment() }
              }

              public typealias Address = OBJECT_OWNER_FIELDS.AsObjectOwner.Address
            }

            /// Address.Objects.Node.Owner.AsShared
            ///
            /// Parent Type: `Shared`
            public struct AsShared: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Shared }
              @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                OBJECT_OWNER_FIELDS.AsShared.self
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                GetCoinsQuery.Data.Address.Objects.Node.Owner.AsShared.self,
                OBJECT_OWNER_FIELDS.self,
                OBJECT_OWNER_FIELDS.AsShared.self
              ] }

              /// The version at which the object became shared.
              public var initialSharedVersion: GraphqlSchemaSuiKit.UInt53? { __data["initialSharedVersion"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var oBJECT_OWNER_FIELDS: OBJECT_OWNER_FIELDS { _toFragment() }
              }
            }

            /// Address.Objects.Node.Owner.AsConsensusAddressOwner
            ///
            /// Parent Type: `ConsensusAddressOwner`
            public struct AsConsensusAddressOwner: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ConsensusAddressOwner }
              @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                GetCoinsQuery.Data.Address.Objects.Node.Owner.AsConsensusAddressOwner.self,
                OBJECT_OWNER_FIELDS.self,
                OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self
              ] }

              /// The version at which the object most recently bcame a consensus object. This serves the same function as `Shared.initialSharedVersion`, except it may change if the object's `owner` type changes.
              public var startVersion: GraphqlSchemaSuiKit.UInt53? { __data["startVersion"] }
              /// The owner's address.
              public var address: Address? { __data["address"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var oBJECT_OWNER_FIELDS: OBJECT_OWNER_FIELDS { _toFragment() }
              }

              public typealias Address = OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.Address
            }
          }

          /// Address.Objects.Node.Contents
          ///
          /// Parent Type: `MoveValue`
          public struct Contents: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("bcs", GraphqlSchemaSuiKit.Base64?.self),
              .field("json", GraphqlSchemaSuiKit.JSON?.self),
              .field("type", Type_SelectionSet?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetCoinsQuery.Data.Address.Objects.Node.Contents.self
            ] }

            /// The BCS representation of this value, Base64-encoded.
            public var bcs: GraphqlSchemaSuiKit.Base64? { __data["bcs"] }
            /// Representation of a Move value in JSON, where:
            ///
            /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
            /// - Bools are represented by JSON boolean literals.
            /// - u8, u16, and u32 are represented as JSON numbers.
            /// - u64, u128, and u256 are represented as JSON strings.
            /// - Balances, Strings, and Urls are represented as JSON strings.
            /// - Vectors of bytes are represented as Base64 blobs, and other vectors are represented by JSON arrays.
            /// - Structs are represented by JSON objects.
            /// - Enums are represented by JSON objects, with a field named `@variant` containing the variant name.
            /// - Empty optional values are represented by `null`.
            public var json: GraphqlSchemaSuiKit.JSON? { __data["json"] }
            /// The value's type.
            public var type: Type_SelectionSet? { __data["type"] }

            /// Address.Objects.Node.Contents.Type_SelectionSet
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
                GetCoinsQuery.Data.Address.Objects.Node.Contents.Type_SelectionSet.self
              ] }

              /// Flat representation of the type signature, as a displayable string.
              public var repr: String { __data["repr"] }
            }
          }

          /// Address.Objects.Node.PreviousTransaction
          ///
          /// Parent Type: `Transaction`
          public struct PreviousTransaction: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Transaction }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("digest", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetCoinsQuery.Data.Address.Objects.Node.PreviousTransaction.self
            ] }

            /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
            public var digest: String { __data["digest"] }
          }
        }
      }
    }
  }
}
