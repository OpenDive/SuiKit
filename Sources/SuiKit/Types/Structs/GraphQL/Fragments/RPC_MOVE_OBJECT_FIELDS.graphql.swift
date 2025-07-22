// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_MOVE_OBJECT_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_MOVE_OBJECT_FIELDS on MoveObject { __typename objectId: address bcs @include(if: $showBcs) contents @include(if: $showType) { __typename type { __typename repr } } hasPublicTransfer @include(if: $showContent) contents @include(if: $showContent) { __typename data type { __typename repr layout signature } } hasPublicTransfer @include(if: $showBcs) contents @include(if: $showBcs) { __typename bcs type { __typename repr } } owner @include(if: $showOwner) { __typename ...RPC_OBJECT_OWNER_FIELDS } previousTransactionBlock @include(if: $showPreviousTransaction) { __typename digest } storageRebate @include(if: $showStorageRebate) digest version display @include(if: $showDisplay) { __typename key value error } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("address", alias: "objectId", SuiKit.SuiAddressApollo.self),
    .field("digest", String?.self),
    .field("version", SuiKit.UInt53Apollo.self),
    .include(if: "showBcs", .field("bcs", SuiKit.Base64Apollo?.self)),
    .include(if: "showType" || "showContent" || "showBcs", .field("contents", Contents?.self)),
    .include(if: "showContent" || "showBcs", .field("hasPublicTransfer", Bool.self)),
    .include(if: "showOwner", .field("owner", Owner?.self)),
    .include(if: "showPreviousTransaction", .field("previousTransactionBlock", PreviousTransactionBlock?.self)),
    .include(if: "showStorageRebate", .field("storageRebate", SuiKit.BigIntApollo?.self)),
    .include(if: "showDisplay", .field("display", [Display]?.self))
  ] }

  public var objectId: SuiKit.SuiAddressApollo { __data["objectId"] }
  /// The Base64-encoded BCS serialization of the object's content.
  public var bcs: SuiKit.Base64Apollo? { __data["bcs"] }
  /// Displays the contents of the Move object in a JSON string and through GraphQL types. Also
  /// provides the flat representation of the type signature, and the BCS of the corresponding
  /// data.
  public var contents: Contents? { __data["contents"] }
  /// Determines whether a transaction can transfer this object, using the TransferObjects
  /// transaction command or `sui::transfer::public_transfer`, both of which require the object to
  /// have the `key` and `store` abilities.
  public var hasPublicTransfer: Bool? { __data["hasPublicTransfer"] }
  /// The owner type of this object: Immutable, Shared, Parent, Address
  public var owner: Owner? { __data["owner"] }
  /// The transaction block that created this version of the object.
  public var previousTransactionBlock: PreviousTransactionBlock? { __data["previousTransactionBlock"] }
  /// The amount of SUI we would rebate if this object gets deleted or mutated. This number is
  /// recalculated based on the present storage gas price.
  public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
  /// 32-byte hash that identifies the object's contents, encoded as a Base58 string.
  public var digest: String? { __data["digest"] }
  public var version: SuiKit.UInt53Apollo { __data["version"] }
  /// The set of named templates defined on-chain for the type of this object, to be handled
  /// off-chain. The server substitutes data from the object into these templates to generate a
  /// display string per template.
  public var display: [Display]? { __data["display"] }

  /// Contents
  ///
  /// Parent Type: `MoveValue`
  public struct Contents: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .include(if: "showType", .inlineFragment(IfShowType.self)),
      .include(if: "showContent", .inlineFragment(IfShowContent.self)),
      .include(if: "showBcs", .inlineFragment(IfShowBcs.self))
    ] }

    public var ifShowType: IfShowType? { _asInlineFragment() }
    public var ifShowContent: IfShowContent? { _asInlineFragment() }
    public var ifShowBcs: IfShowBcs? { _asInlineFragment() }

    /// Contents.IfShowType
    ///
    /// Parent Type: `MoveValue`
    public struct IfShowType: SuiKit.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Contents
      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("type", Type_SelectionSet.self)
      ] }

      /// The value's Move type.
      public var type: Type_SelectionSet { __data["type"] }

      /// Contents.IfShowType.Type_SelectionSet
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
        /// Structured representation of the "shape" of values that match this type. May return no
        /// layout if the type is invalid.
        public var layout: SuiKit.MoveTypeLayoutApollo? { __data["layout"] }
        /// Structured representation of the type signature.
        public var signature: SuiKit.MoveTypeSignatureApollo { __data["signature"] }
      }
    }

    /// Contents.IfShowContent
    ///
    /// Parent Type: `MoveValue`
    public struct IfShowContent: SuiKit.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Contents
      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("data", AnyHashable.self),
        .field("type", Type_SelectionSet.self)
      ] }

      /// Structured contents of a Move value.
      public var data: AnyHashable { __data["data"] }
      /// The value's Move type.
      public var type: Type_SelectionSet { __data["type"] }

      /// Contents.IfShowContent.Type_SelectionSet
      ///
      /// Parent Type: `MoveType`
      public struct Type_SelectionSet: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveType }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("repr", String.self),
          .field("layout", AnyHashable?.self),
          .field("signature", AnyHashable.self)
        ] }

        /// Flat representation of the type signature, as a displayable string.
        public var repr: String { __data["repr"] }
        /// Structured representation of the "shape" of values that match this type. May return no
        /// layout if the type is invalid.
        public var layout: AnyHashable? { __data["layout"] }
        /// Structured representation of the type signature.
        public var signature: AnyHashable { __data["signature"] }
      }
    }

    /// Contents.IfShowBcs
    ///
    /// Parent Type: `MoveValue`
    public struct IfShowBcs: SuiKit.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Contents
      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("bcs", AnyHashable.self),
        .field("type", Type_SelectionSet.self)
      ] }

      /// The BCS representation of this value, Base64 encoded.
      public var bcs: AnyHashable { __data["bcs"] }
      /// The value's Move type.
      public var type: Type_SelectionSet { __data["type"] }

      /// Contents.IfShowBcs.Type_SelectionSet
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
        /// Structured representation of the "shape" of values that match this type. May return no
        /// layout if the type is invalid.
        public var layout: AnyHashable? { __data["layout"] }
        /// Structured representation of the type signature.
        public var signature: AnyHashable { __data["signature"] }
      }
    }
  }

  /// Owner
  ///
  /// Parent Type: `ObjectOwner`
  public struct Owner: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Unions.ObjectOwner }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(RPC_OBJECT_OWNER_FIELDS.self)
    ] }

    public var asAddressOwner: AsAddressOwner? { _asInlineFragment() }
    public var asParent: AsParent? { _asInlineFragment() }
    public var asShared: AsShared? { _asInlineFragment() }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
    }

    /// Owner.AsAddressOwner
    ///
    /// Parent Type: `AddressOwner`
    public struct AsAddressOwner: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Owner
      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.AddressOwner }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RPC_MOVE_OBJECT_FIELDS.Owner.self,
        RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.self
      ] }

      public var owner: Owner? { __data["owner"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
      }

      public typealias Owner = RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.Owner
    }

    /// Owner.AsParent
    ///
    /// Parent Type: `Parent`
    public struct AsParent: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Owner
      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Parent }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RPC_MOVE_OBJECT_FIELDS.Owner.self,
        RPC_OBJECT_OWNER_FIELDS.AsParent.self
      ] }

      public var parent: Parent? { __data["parent"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
      }

      public typealias Parent = RPC_OBJECT_OWNER_FIELDS.AsParent.Parent
    }

    /// Owner.AsShared
    ///
    /// Parent Type: `Shared`
    public struct AsShared: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Owner
      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Shared }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RPC_MOVE_OBJECT_FIELDS.Owner.self,
        RPC_OBJECT_OWNER_FIELDS.AsShared.self
      ] }

      public var initialSharedVersion: SuiKit.UInt53Apollo { __data["initialSharedVersion"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
      }
    }
  }

  /// PreviousTransactionBlock
  ///
  /// Parent Type: `TransactionBlock`
  public struct PreviousTransactionBlock: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("digest", String?.self)
    ] }

    /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
    /// This serves as a unique id for the block on chain.
    public var digest: String? { __data["digest"] }
  }

  /// Display
  ///
  /// Parent Type: `DisplayEntry`
  public struct Display: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DisplayEntry }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("key", String.self),
      .field("value", String?.self),
      .field("error", String?.self)
    ] }

    /// The identifier for a particular template string of the Display object.
    public var key: String { __data["key"] }
    /// The template string for the key with placeholder values substituted.
    public var value: String? { __data["value"] }
    /// An error string describing why the template could not be rendered.
    public var error: String? { __data["error"] }
  }
}
