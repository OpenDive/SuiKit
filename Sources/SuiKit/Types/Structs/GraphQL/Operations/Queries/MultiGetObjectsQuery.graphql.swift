// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MultiGetObjectsQuery: GraphQLQuery {
  public static let operationName: String = "multiGetObjects"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query multiGetObjects($ids: [SuiAddress!]!, $limit: Int, $cursor: String, $showBcs: Boolean = false, $showContent: Boolean = false, $showType: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showStorageRebate: Boolean = false) { objectConnection(first: $limit, after: $cursor, filter: { objectIds: $ids }) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_OBJECT_FIELDS } } }"#,
      fragments: [RPC_OBJECT_FIELDS.self]
    ))

  public var ids: [SuiAddressApollo]
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>
  public var showBcs: GraphQLNullable<Bool>
  public var showContent: GraphQLNullable<Bool>
  public var showType: GraphQLNullable<Bool>
  public var showOwner: GraphQLNullable<Bool>
  public var showPreviousTransaction: GraphQLNullable<Bool>
  public var showStorageRebate: GraphQLNullable<Bool>

  public init(
    ids: [SuiAddressApollo],
    limit: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>,
    showBcs: GraphQLNullable<Bool> = false,
    showContent: GraphQLNullable<Bool> = false,
    showType: GraphQLNullable<Bool> = false,
    showOwner: GraphQLNullable<Bool> = false,
    showPreviousTransaction: GraphQLNullable<Bool> = false,
    showStorageRebate: GraphQLNullable<Bool> = false
  ) {
    self.ids = ids
    self.limit = limit
    self.cursor = cursor
    self.showBcs = showBcs
    self.showContent = showContent
    self.showType = showType
    self.showOwner = showOwner
    self.showPreviousTransaction = showPreviousTransaction
    self.showStorageRebate = showStorageRebate
  }

  public var __variables: Variables? { [
    "ids": ids,
    "limit": limit,
    "cursor": cursor,
    "showBcs": showBcs,
    "showContent": showContent,
    "showType": showType,
    "showOwner": showOwner,
    "showPreviousTransaction": showPreviousTransaction,
    "showStorageRebate": showStorageRebate
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("objectConnection", ObjectConnection?.self, arguments: [
        "first": .variable("limit"),
        "after": .variable("cursor"),
        "filter": ["objectIds": .variable("ids")]
      ]),
    ] }

    public var objectConnection: ObjectConnection? { __data["objectConnection"] }

    /// ObjectConnection
    ///
    /// Parent Type: `ObjectConnection`
    public struct ObjectConnection: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ObjectConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self),
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// ObjectConnection.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// ObjectConnection.Node
      ///
      /// Parent Type: `Object`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RPC_OBJECT_FIELDS.self),
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
        public var owner: RPC_OBJECT_FIELDS.Owner? { __data["owner"] }
        /// The transaction block that created this version of the object.
        public var previousTransactionBlock: RPC_OBJECT_FIELDS.PreviousTransactionBlock? { __data["previousTransactionBlock"] }
        /// The amount of SUI we would rebate if this object gets deleted or mutated.
        /// This number is recalculated based on the present storage gas price.
        public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
        /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
        public var digest: String { __data["digest"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rPC_OBJECT_FIELDS: RPC_OBJECT_FIELDS { _toFragment() }
        }

        /// ObjectConnection.Node.AsMoveObject
        ///
        /// Parent Type: `MoveObject`
        public struct AsMoveObject: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }

          public var ifShowType: IfShowType? { _asInlineFragment() }
          public var ifShowContent: IfShowContent? { _asInlineFragment() }
          public var ifShowBcs: IfShowBcs? { _asInlineFragment() }

          /// ObjectConnection.Node.AsMoveObject.IfShowType
          ///
          /// Parent Type: `MoveObject`
          public struct IfShowType: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = MultiGetObjectsQuery.Data.ObjectConnection.Node.AsMoveObject
            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
              RPC_OBJECT_FIELDS.AsMoveObject.self
            ] }

            /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }

            /// ObjectConnection.Node.AsMoveObject.IfShowType.Contents
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

              /// ObjectConnection.Node.AsMoveObject.IfShowType.Contents.Type_SelectionSet
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

          /// ObjectConnection.Node.AsMoveObject.IfShowContent
          ///
          /// Parent Type: `MoveObject`
          public struct IfShowContent: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = MultiGetObjectsQuery.Data.ObjectConnection.Node.AsMoveObject
            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
              RPC_OBJECT_FIELDS.AsMoveObject.self
            ] }

            /// Determines whether a tx can transfer this object
            public var hasPublicTransfer: Bool? { __data["hasPublicTransfer"] }
            /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }

            /// ObjectConnection.Node.AsMoveObject.IfShowContent.Contents
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

              /// ObjectConnection.Node.AsMoveObject.IfShowContent.Contents.Type_SelectionSet
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

          /// ObjectConnection.Node.AsMoveObject.IfShowBcs
          ///
          /// Parent Type: `MoveObject`
          public struct IfShowBcs: SuiKit.InlineFragment, ApolloAPI.CompositeInlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = MultiGetObjectsQuery.Data.ObjectConnection.Node.AsMoveObject
            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
              RPC_OBJECT_FIELDS.AsMoveObject.self
            ] }

            /// Determines whether a tx can transfer this object
            public var hasPublicTransfer: Bool? { __data["hasPublicTransfer"] }
            /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }

            /// ObjectConnection.Node.AsMoveObject.IfShowBcs.Contents
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

              /// ObjectConnection.Node.AsMoveObject.IfShowBcs.Contents.Type_SelectionSet
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
}
