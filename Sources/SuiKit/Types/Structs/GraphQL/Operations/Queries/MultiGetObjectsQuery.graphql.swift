// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MultiGetObjectsQuery: GraphQLQuery {
  public static let operationName: String = "multiGetObjects"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query multiGetObjects($ids: [SuiAddress!]!, $limit: Int, $cursor: String, $showBcs: Boolean = false, $showContent: Boolean = false, $showDisplay: Boolean = false, $showType: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showStorageRebate: Boolean = false) { objects(first: $limit, after: $cursor, filter: { objectIds: $ids }) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_OBJECT_FIELDS } } }"#,
      fragments: [RPC_OBJECT_FIELDS.self, RPC_OBJECT_OWNER_FIELDS.self]
    ))

  public var ids: [SuiAddressApollo]
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>
  public var showBcs: GraphQLNullable<Bool>
  public var showContent: GraphQLNullable<Bool>
  public var showDisplay: GraphQLNullable<Bool>
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
    showDisplay: GraphQLNullable<Bool> = false,
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
    self.showDisplay = showDisplay
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
    "showDisplay": showDisplay,
    "showType": showType,
    "showOwner": showOwner,
    "showPreviousTransaction": showPreviousTransaction,
    "showStorageRebate": showStorageRebate
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("objects", Objects.self, arguments: [
        "first": .variable("limit"),
        "after": .variable("cursor"),
        "filter": ["objectIds": .variable("ids")]
      ])
    ] }

    /// The objects that exist in the network.
    public var objects: Objects { __data["objects"] }

    /// Objects
    ///
    /// Parent Type: `ObjectConnection`
    public struct Objects: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ObjectConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self)
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Objects.PageInfo
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

      /// Objects.Node
      ///
      /// Parent Type: `Object`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RPC_OBJECT_FIELDS.self)
        ] }

        public var objectId: SuiKit.SuiAddressApollo { __data["objectId"] }
        public var version: SuiKit.UInt53Apollo { __data["version"] }
        /// Attempts to convert the object into a MoveObject
        public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
        /// The owner type of this object: Immutable, Shared, Parent, Address
        /// Immutable and Shared Objects do not have owners.
        public var owner: Owner? { __data["owner"] }
        /// The transaction block that created this version of the object.
        public var previousTransactionBlock: PreviousTransactionBlock? { __data["previousTransactionBlock"] }
        /// The amount of SUI we would rebate if this object gets deleted or mutated. This number is
        /// recalculated based on the present storage gas price.
        public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
        /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
        public var digest: String? { __data["digest"] }
        /// The set of named templates defined on-chain for the type of this object, to be handled
        /// off-chain. The server substitutes data from the object into these templates to generate a
        /// display string per template.
        public var display: [Display]? { __data["display"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rPC_OBJECT_FIELDS: RPC_OBJECT_FIELDS { _toFragment() }
        }

        public typealias AsMoveObject = RPC_OBJECT_FIELDS.AsMoveObject

        public typealias Owner = RPC_OBJECT_FIELDS.Owner

        public typealias PreviousTransactionBlock = RPC_OBJECT_FIELDS.PreviousTransactionBlock

        public typealias Display = RPC_OBJECT_FIELDS.Display
      }
    }
  }
}
