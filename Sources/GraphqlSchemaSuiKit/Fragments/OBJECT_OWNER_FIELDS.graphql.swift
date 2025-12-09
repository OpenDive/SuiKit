// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct OBJECT_OWNER_FIELDS: GraphqlSchemaSuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment OBJECT_OWNER_FIELDS on Owner { __typename ... on AddressOwner { address { __typename address } } ... on ObjectOwner { address { __typename address } } ... on Shared { initialSharedVersion } ... on ConsensusAddressOwner { startVersion address { __typename address } } }"#
  }

  @_spi(Unsafe) public let __data: DataDict
  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Unions.Owner }
  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .inlineFragment(AsAddressOwner.self),
    .inlineFragment(AsObjectOwner.self),
    .inlineFragment(AsShared.self),
    .inlineFragment(AsConsensusAddressOwner.self),
  ] }
  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
    OBJECT_OWNER_FIELDS.self
  ] }

  public var asAddressOwner: AsAddressOwner? { _asInlineFragment() }
  public var asObjectOwner: AsObjectOwner? { _asInlineFragment() }
  public var asShared: AsShared? { _asInlineFragment() }
  public var asConsensusAddressOwner: AsConsensusAddressOwner? { _asInlineFragment() }

  /// AsAddressOwner
  ///
  /// Parent Type: `AddressOwner`
  public struct AsAddressOwner: GraphqlSchemaSuiKit.InlineFragment {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = OBJECT_OWNER_FIELDS
    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.AddressOwner }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      OBJECT_OWNER_FIELDS.self,
      OBJECT_OWNER_FIELDS.AsAddressOwner.self
    ] }

    /// The owner's address.
    public var address: Address? { __data["address"] }

    /// AsAddressOwner.Address
    ///
    /// Parent Type: `Address`
    public struct Address: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Address }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        OBJECT_OWNER_FIELDS.AsAddressOwner.Address.self
      ] }

      /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
      public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
    }
  }

  /// AsObjectOwner
  ///
  /// Parent Type: `ObjectOwner`
  public struct AsObjectOwner: GraphqlSchemaSuiKit.InlineFragment {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = OBJECT_OWNER_FIELDS
    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ObjectOwner }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      OBJECT_OWNER_FIELDS.self,
      OBJECT_OWNER_FIELDS.AsObjectOwner.self
    ] }

    /// The owner's address.
    public var address: Address? { __data["address"] }

    /// AsObjectOwner.Address
    ///
    /// Parent Type: `Address`
    public struct Address: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Address }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        OBJECT_OWNER_FIELDS.AsObjectOwner.Address.self
      ] }

      /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
      public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
    }
  }

  /// AsShared
  ///
  /// Parent Type: `Shared`
  public struct AsShared: GraphqlSchemaSuiKit.InlineFragment {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = OBJECT_OWNER_FIELDS
    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Shared }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("initialSharedVersion", GraphqlSchemaSuiKit.UInt53?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      OBJECT_OWNER_FIELDS.self,
      OBJECT_OWNER_FIELDS.AsShared.self
    ] }

    /// The version at which the object became shared.
    public var initialSharedVersion: GraphqlSchemaSuiKit.UInt53? { __data["initialSharedVersion"] }
  }

  /// AsConsensusAddressOwner
  ///
  /// Parent Type: `ConsensusAddressOwner`
  public struct AsConsensusAddressOwner: GraphqlSchemaSuiKit.InlineFragment {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = OBJECT_OWNER_FIELDS
    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ConsensusAddressOwner }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("startVersion", GraphqlSchemaSuiKit.UInt53?.self),
      .field("address", Address?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      OBJECT_OWNER_FIELDS.self,
      OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self
    ] }

    /// The version at which the object most recently bcame a consensus object. This serves the same function as `Shared.initialSharedVersion`, except it may change if the object's `owner` type changes.
    public var startVersion: GraphqlSchemaSuiKit.UInt53? { __data["startVersion"] }
    /// The owner's address.
    public var address: Address? { __data["address"] }

    /// AsConsensusAddressOwner.Address
    ///
    /// Parent Type: `Address`
    public struct Address: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Address }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("address", GraphqlSchemaSuiKit.SuiAddress.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.Address.self
      ] }

      /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
      public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
    }
  }
}
