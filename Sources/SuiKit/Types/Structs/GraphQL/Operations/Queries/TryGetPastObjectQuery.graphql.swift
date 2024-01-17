// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TryGetPastObjectQuery: GraphQLQuery {
  public static let operationName: String = "tryGetPastObject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query tryGetPastObject($id: SuiAddress!, $version: Int, $showBcs: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showContent: Boolean = false, $showDisplay: Boolean = false, $showType: Boolean = false, $showStorageRebate: Boolean = false) { object(address: $id, version: $version) { __typename ...RPC_OBJECT_FIELDS } }"#,
      fragments: [RPC_OBJECT_FIELDS.self]
    ))

  public var id: SuiAddressApollo
  public var version: GraphQLNullable<Int>
  public var showBcs: GraphQLNullable<Bool>
  public var showOwner: GraphQLNullable<Bool>
  public var showPreviousTransaction: GraphQLNullable<Bool>
  public var showContent: GraphQLNullable<Bool>
  public var showDisplay: GraphQLNullable<Bool>
  public var showType: GraphQLNullable<Bool>
  public var showStorageRebate: GraphQLNullable<Bool>

  public init(
    id: SuiAddressApollo,
    version: GraphQLNullable<Int>,
    showBcs: GraphQLNullable<Bool> = false,
    showOwner: GraphQLNullable<Bool> = false,
    showPreviousTransaction: GraphQLNullable<Bool> = false,
    showContent: GraphQLNullable<Bool> = false,
    showDisplay: GraphQLNullable<Bool> = false,
    showType: GraphQLNullable<Bool> = false,
    showStorageRebate: GraphQLNullable<Bool> = false
  ) {
    self.id = id
    self.version = version
    self.showBcs = showBcs
    self.showOwner = showOwner
    self.showPreviousTransaction = showPreviousTransaction
    self.showContent = showContent
    self.showDisplay = showDisplay
    self.showType = showType
    self.showStorageRebate = showStorageRebate
  }

  public var __variables: Variables? { [
    "id": id,
    "version": version,
    "showBcs": showBcs,
    "showOwner": showOwner,
    "showPreviousTransaction": showPreviousTransaction,
    "showContent": showContent,
    "showDisplay": showDisplay,
    "showType": showType,
    "showStorageRebate": showStorageRebate
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("object", Object?.self, arguments: [
        "address": .variable("id"),
        "version": .variable("version")
      ]),
    ] }

    public var object: Object? { __data["object"] }

    /// Object
    ///
    /// Parent Type: `Object`
    public struct Object: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(RPC_OBJECT_FIELDS.self),
      ] }

      /// The address of the object, named as such to avoid conflict with the address type.
      public var objectId: SuiKit.SuiAddressApollo { __data["objectId"] }
      /// The Base64Apollo encoded bcs serialization of the object's content.
      public var bcs: SuiKit.Base64Apollo? { __data["bcs"] }
      public var version: Int { __data["version"] }
      /// Attempts to convert the object into a MoveObject
      public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
      /// The Address or Object that owns this Object.  Immutable and Shared Objects do not have
      /// owners.
      public var owner: RPC_OBJECT_FIELDS.Owner? { __data["owner"] }
      /// The transaction block that created this version of the object.
      public var previousTransactionBlock: RPC_OBJECT_FIELDS.PreviousTransactionBlock? { __data["previousTransactionBlock"] }
      /// The amount of SUI we would rebate if this object gets deleted or mutated.
      /// This number is recalculated based on the present storage gas price.
      public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
      /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
      public var digest: String { __data["digest"] }
      /// The set of named templates defined on-chain for the type of this object,
      /// to be handled off-chain. The server substitutes data from the object
      /// into these templates to generate a display string per template.
      public var display: [RPC_OBJECT_FIELDS.Display]? { __data["display"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_OBJECT_FIELDS: RPC_OBJECT_FIELDS { _toFragment() }
      }

      /// Object.AsMoveObject
      ///
      /// Parent Type: `MoveObject`
      public struct AsMoveObject: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }

        public var ifShowType: IfShowType? { _asInlineFragment() }
        public var ifShowContent: IfShowContent? { _asInlineFragment() }
        public var ifShowBcs: IfShowBcs? { _asInlineFragment() }

        /// Object.AsMoveObject.IfShowType
        ///
        /// Parent Type: `MoveObject`
        public struct IfShowType: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = TryGetPastObjectQuery.Data.Object.AsMoveObject
          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RPC_OBJECT_FIELDS.AsMoveObject.self
          ] }

          /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
          /// provides the flat representation of the type signature, and the bcs of the corresponding
          /// data
          public var contents: Contents? { __data["contents"] }

          /// Object.AsMoveObject.IfShowType.Contents
          ///
          /// Parent Type: `MoveValue`
          public struct Contents: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }

            public var type: Type_SelectionSet { __data["type"] }
            /// Structured contents of a Move value.
            public var data: SuiKit.MoveDataApollo { __data["data"] }
            public var bcs: SuiKit.Base64Apollo { __data["bcs"] }

            /// Object.AsMoveObject.IfShowType.Contents.Type_SelectionSet
            ///
            /// Parent Type: `MoveType`
            public struct Type_SelectionSet: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }

              /// Flat representation of the type signature, as a displayable string.
              public var repr: String { __data["repr"] }
              /// Structured representation of the "shape" of values that match this type.
              public var layout: SuiKit.MoveTypeLayoutApollo { __data["layout"] }
              /// Structured representation of the type signature.
              public var signature: SuiKit.MoveTypeSignatureApollo { __data["signature"] }
            }
          }
        }

        /// Object.AsMoveObject.IfShowContent
        ///
        /// Parent Type: `MoveObject`
        public struct IfShowContent: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = TryGetPastObjectQuery.Data.Object.AsMoveObject
          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RPC_OBJECT_FIELDS.AsMoveObject.self
          ] }

          /// Determines whether a transaction can transfer this object, using the TransferObjects
          /// transaction command or `sui::transfer::public_transfer`, both of which require the object to
          /// have the `key` and `store` abilities.
          public var hasPublicTransfer: Bool { __data["hasPublicTransfer"] }
          /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
          /// provides the flat representation of the type signature, and the bcs of the corresponding
          /// data
          public var contents: Contents? { __data["contents"] }

          /// Object.AsMoveObject.IfShowContent.Contents
          ///
          /// Parent Type: `MoveValue`
          public struct Contents: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }

            public var type: Type_SelectionSet { __data["type"] }
            /// Structured contents of a Move value.
            public var data: SuiKit.MoveDataApollo { __data["data"] }
            public var bcs: SuiKit.Base64Apollo { __data["bcs"] }

            /// Object.AsMoveObject.IfShowContent.Contents.Type_SelectionSet
            ///
            /// Parent Type: `MoveType`
            public struct Type_SelectionSet: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }

              /// Flat representation of the type signature, as a displayable string.
              public var repr: String { __data["repr"] }
              /// Structured representation of the "shape" of values that match this type.
              public var layout: SuiKit.MoveTypeLayoutApollo { __data["layout"] }
              /// Structured representation of the type signature.
              public var signature: SuiKit.MoveTypeSignatureApollo { __data["signature"] }
            }
          }
        }

        /// Object.AsMoveObject.IfShowBcs
        ///
        /// Parent Type: `MoveObject`
        public struct IfShowBcs: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = TryGetPastObjectQuery.Data.Object.AsMoveObject
          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RPC_OBJECT_FIELDS.AsMoveObject.self
          ] }

          /// Determines whether a transaction can transfer this object, using the TransferObjects
          /// transaction command or `sui::transfer::public_transfer`, both of which require the object to
          /// have the `key` and `store` abilities.
          public var hasPublicTransfer: Bool { __data["hasPublicTransfer"] }
          /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
          /// provides the flat representation of the type signature, and the bcs of the corresponding
          /// data
          public var contents: Contents? { __data["contents"] }

          /// Object.AsMoveObject.IfShowBcs.Contents
          ///
          /// Parent Type: `MoveValue`
          public struct Contents: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }

            public var type: Type_SelectionSet { __data["type"] }
            /// Structured contents of a Move value.
            public var data: SuiKit.MoveDataApollo { __data["data"] }
            public var bcs: SuiKit.Base64Apollo { __data["bcs"] }

            /// Object.AsMoveObject.IfShowBcs.Contents.Type_SelectionSet
            ///
            /// Parent Type: `MoveType`
            public struct Type_SelectionSet: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }

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
    }
  }
}
