// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct MOVE_OBJECT_FIELDS: GraphqlSchemaSuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MOVE_OBJECT_FIELDS on MoveObject { __typename address digest version contents { __typename bcs type { __typename repr } } owner { __typename ...OBJECT_OWNER_FIELDS } previousTransaction { __typename digest } }"#
  }

  @_spi(Unsafe) public let __data: DataDict
  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveObject }
  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
    .field("digest", String?.self),
    .field("version", GraphqlSchemaSuiKit.UInt53?.self),
    .field("contents", Contents?.self),
    .field("owner", Owner?.self),
    .field("previousTransaction", PreviousTransaction?.self),
  ] }
  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
    MOVE_OBJECT_FIELDS.self
  ] }

  /// The MoveObject's ID.
  public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
  /// 32-byte hash that identifies the object's contents, encoded in Base58.
  public var digest: String? { __data["digest"] }
  /// The version of this object that this content comes from.
  public var version: GraphqlSchemaSuiKit.UInt53? { __data["version"] }
  /// The structured representation of the object's contents.
  public var contents: Contents? { __data["contents"] }
  /// The object's owner kind.
  public var owner: Owner? { __data["owner"] }
  /// The transaction that created this version of the object.
  public var previousTransaction: PreviousTransaction? { __data["previousTransaction"] }

  /// Contents
  ///
  /// Parent Type: `MoveValue`
  public struct Contents: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("bcs", GraphqlSchemaSuiKit.Base64?.self),
      .field("type", Type_SelectionSet?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MOVE_OBJECT_FIELDS.Contents.self
    ] }

    /// The BCS representation of this value, Base64-encoded.
    public var bcs: GraphqlSchemaSuiKit.Base64? { __data["bcs"] }
    /// The value's type.
    public var type: Type_SelectionSet? { __data["type"] }

    /// Contents.Type_SelectionSet
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
        MOVE_OBJECT_FIELDS.Contents.Type_SelectionSet.self
      ] }

      /// Flat representation of the type signature, as a displayable string.
      public var repr: String { __data["repr"] }
    }
  }

  /// Owner
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
      MOVE_OBJECT_FIELDS.Owner.self
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

    /// Owner.AsAddressOwner
    ///
    /// Parent Type: `AddressOwner`
    public struct AsAddressOwner: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MOVE_OBJECT_FIELDS.Owner
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.AddressOwner }
      @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        OBJECT_OWNER_FIELDS.AsAddressOwner.self
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        MOVE_OBJECT_FIELDS.Owner.AsAddressOwner.self,
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

    /// Owner.AsObjectOwner
    ///
    /// Parent Type: `ObjectOwner`
    public struct AsObjectOwner: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MOVE_OBJECT_FIELDS.Owner
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ObjectOwner }
      @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        OBJECT_OWNER_FIELDS.AsObjectOwner.self
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        MOVE_OBJECT_FIELDS.Owner.AsObjectOwner.self,
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

    /// Owner.AsShared
    ///
    /// Parent Type: `Shared`
    public struct AsShared: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MOVE_OBJECT_FIELDS.Owner
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Shared }
      @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        OBJECT_OWNER_FIELDS.AsShared.self
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        MOVE_OBJECT_FIELDS.Owner.AsShared.self,
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

    /// Owner.AsConsensusAddressOwner
    ///
    /// Parent Type: `ConsensusAddressOwner`
    public struct AsConsensusAddressOwner: GraphqlSchemaSuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MOVE_OBJECT_FIELDS.Owner
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ConsensusAddressOwner }
      @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MOVE_OBJECT_FIELDS.Owner.self,
        MOVE_OBJECT_FIELDS.Owner.AsConsensusAddressOwner.self,
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

  /// PreviousTransaction
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
      MOVE_OBJECT_FIELDS.PreviousTransaction.self
    ] }

    /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
    public var digest: String { __data["digest"] }
  }
}
