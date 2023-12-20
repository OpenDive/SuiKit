// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_OBJECT_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_OBJECT_FIELDS on Object { __typename objectId: location bcs @include(if: $showBcs) version asMoveObject @include(if: $showType) { __typename contents { __typename type { __typename repr } } } asMoveObject @include(if: $showContent) { __typename hasPublicTransfer contents { __typename data type { __typename repr layout signature } } } asMoveObject @include(if: $showBcs) { __typename hasPublicTransfer contents { __typename bcs type { __typename repr } } } owner @include(if: $showOwner) { __typename location asAddress { __typename location } asObject { __typename location } } previousTransactionBlock @include(if: $showPreviousTransaction) { __typename digest } storageRebate @include(if: $showStorageRebate) digest version }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("location", alias: "objectId", SuiKit.SuiAddressApollo.self),
    .field("version", Int.self),
    .field("digest", String.self),
    .include(if: "showBcs", .field("bcs", SuiKit.Base64Apollo?.self)),
    .include(if: "showType" || "showContent" || "showBcs", .field("asMoveObject", AsMoveObject?.self)),
    .include(if: "showOwner", .field("owner", Owner?.self)),
    .include(if: "showPreviousTransaction", .field("previousTransactionBlock", PreviousTransactionBlock?.self)),
    .include(if: "showStorageRebate", .field("storageRebate", SuiKit.BigIntApollo?.self)),
  ] }

  /// The address of the object, named as such to avoid conflict with the address type.
  public var objectId: SuiKit.SuiAddressApollo { __data["objectId"] }
  /// The Base64 encoded bcs serialization of the object's content.
  public var bcs: SuiKit.Base64Apollo? { __data["bcs"] }
  public var version: Int { __data["version"] }
  /// Attempts to convert the object into a MoveObject
  public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
  /// The Address or Object that owns this Object.  Immutable and Shared Objects do not have
  /// owners.
  public var owner: Owner? { __data["owner"] }
  /// The transaction block that created this version of the object.
  public var previousTransactionBlock: PreviousTransactionBlock? { __data["previousTransactionBlock"] }
  /// The amount of SUI we would rebate if this object gets deleted or mutated.
  /// This number is recalculated based on the present storage gas price.
  public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
  /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
  public var digest: String { __data["digest"] }

  /// AsMoveObject
  ///
  /// Parent Type: `MoveObject`
  public struct AsMoveObject: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .include(if: "showType", .inlineFragment(IfShowType.self)),
      .include(if: "showContent", .inlineFragment(IfShowContent.self)),
      .include(if: "showBcs", .inlineFragment(IfShowBcs.self)),
    ] }

    public var ifShowType: IfShowType? { _asInlineFragment() }
    public var ifShowContent: IfShowContent? { _asInlineFragment() }
    public var ifShowBcs: IfShowBcs? { _asInlineFragment() }

    /// AsMoveObject.IfShowType
    ///
    /// Parent Type: `MoveObject`
    public struct IfShowType: SuiKit.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_OBJECT_FIELDS.AsMoveObject
      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("contents", Contents?.self),
      ] }

      /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
      /// provides the flat representation of the type signature, and the bcs of the corresponding
      /// data
      public var contents: Contents? { __data["contents"] }

      /// AsMoveObject.Contents
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
        /// Structured contents of a Move value.
        public var data: SuiKit.MoveDataApollo { __data["data"] }
        public var bcs: SuiKit.Base64Apollo { __data["bcs"] }

        /// AsMoveObject.Contents.Type_SelectionSet
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
          /// Structured representation of the "shape" of values that match this type.
          public var layout: SuiKit.MoveTypeLayoutApollo { __data["layout"] }
          /// Structured representation of the type signature.
          public var signature: SuiKit.MoveTypeSignatureApollo { __data["signature"] }
        }
      }
    }

    /// AsMoveObject.IfShowContent
    ///
    /// Parent Type: `MoveObject`
    public struct IfShowContent: SuiKit.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_OBJECT_FIELDS.AsMoveObject
      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("hasPublicTransfer", Bool?.self),
        .field("contents", Contents?.self),
      ] }

      /// Determines whether a tx can transfer this object
      public var hasPublicTransfer: Bool? { __data["hasPublicTransfer"] }
      /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
      /// provides the flat representation of the type signature, and the bcs of the corresponding
      /// data
      public var contents: Contents? { __data["contents"] }

      /// AsMoveObject.Contents
      ///
      /// Parent Type: `MoveValue`
      public struct Contents: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("data", SuiKit.MoveDataApollo.self),
          .field("type", Type_SelectionSet.self),
        ] }

        /// Structured contents of a Move value.
        public var data: SuiKit.MoveDataApollo { __data["data"] }
        public var type: Type_SelectionSet { __data["type"] }
        public var bcs: SuiKit.Base64Apollo { __data["bcs"] }

        /// AsMoveObject.Contents.Type_SelectionSet
        ///
        /// Parent Type: `MoveType`
        public struct Type_SelectionSet: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("repr", String.self),
            .field("layout", SuiKit.MoveTypeLayoutApollo.self),
            .field("signature", SuiKit.MoveTypeSignatureApollo.self),
          ] }

          /// Flat representation of the type signature, as a displayable string.
          public var repr: String { __data["repr"] }
          /// Structured representation of the "shape" of values that match this type.
          public var layout: SuiKit.MoveTypeLayoutApollo { __data["layout"] }
          /// Structured representation of the type signature.
          public var signature: SuiKit.MoveTypeSignatureApollo { __data["signature"] }
        }
      }
    }

    /// AsMoveObject.IfShowBcs
    ///
    /// Parent Type: `MoveObject`
    public struct IfShowBcs: SuiKit.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RPC_OBJECT_FIELDS.AsMoveObject
      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("hasPublicTransfer", Bool?.self),
        .field("contents", Contents?.self),
      ] }

      /// Determines whether a tx can transfer this object
      public var hasPublicTransfer: Bool? { __data["hasPublicTransfer"] }
      /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
      /// provides the flat representation of the type signature, and the bcs of the corresponding
      /// data
      public var contents: Contents? { __data["contents"] }

      /// AsMoveObject.Contents
      ///
      /// Parent Type: `MoveValue`
      public struct Contents: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("bcs", SuiKit.Base64Apollo.self),
          .field("type", Type_SelectionSet.self),
        ] }

        public var bcs: SuiKit.Base64Apollo { __data["bcs"] }
        public var type: Type_SelectionSet { __data["type"] }
        /// Structured contents of a Move value.
        public var data: SuiKit.MoveDataApollo { __data["data"] }

        /// AsMoveObject.Contents.Type_SelectionSet
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
          /// Structured representation of the "shape" of values that match this type.
          public var layout: SuiKit.MoveTypeLayoutApollo { __data["layout"] }
          /// Structured representation of the type signature.
          public var signature: SuiKit.MoveTypeSignatureApollo { __data["signature"] }
        }
      }
    }
  }

  /// Owner
  ///
  /// Parent Type: `Owner`
  public struct Owner: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Owner }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("location", SuiKit.SuiAddressApollo.self),
      .field("asAddress", AsAddress?.self),
      .field("asObject", AsObject?.self),
    ] }

    public var location: SuiKit.SuiAddressApollo { __data["location"] }
    public var asAddress: AsAddress? { __data["asAddress"] }
    public var asObject: AsObject? { __data["asObject"] }

    /// Owner.AsAddress
    ///
    /// Parent Type: `Address`
    public struct AsAddress: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("location", SuiKit.SuiAddressApollo.self),
      ] }

      public var location: SuiKit.SuiAddressApollo { __data["location"] }
    }

    /// Owner.AsObject
    ///
    /// Parent Type: `Object`
    public struct AsObject: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("location", SuiKit.SuiAddressApollo.self),
      ] }

      /// The address of the object, named as such to avoid conflict with the address type.
      public var location: SuiKit.SuiAddressApollo { __data["location"] }
    }
  }

  /// PreviousTransactionBlock
  ///
  /// Parent Type: `TransactionBlock`
  public struct PreviousTransactionBlock: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("digest", String.self),
    ] }

    /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
    /// This serves as a unique id for the block on chain
    public var digest: String { __data["digest"] }
  }
}
