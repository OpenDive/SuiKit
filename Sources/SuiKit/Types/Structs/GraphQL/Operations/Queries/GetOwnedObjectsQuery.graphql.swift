// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetOwnedObjectsQuery: GraphQLQuery {
  public static let operationName: String = "getOwnedObjects"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getOwnedObjects($owner: SuiAddress!, $limit: Int, $cursor: String, $showBcs: Boolean = false, $showContent: Boolean = false, $showDisplay: Boolean = false, $showType: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showStorageRebate: Boolean = false, $filter: ObjectFilter) { address(address: $owner) { __typename objects(first: $limit, after: $cursor, filter: $filter) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_OBJECT_FIELDS } } } }"#,
      fragments: [RPC_MOVE_OBJECT_FIELDS.self, RPC_OBJECT_OWNER_FIELDS.self]
    ))

  public var owner: SuiAddressApollo
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>
  public var showBcs: GraphQLNullable<Bool>
  public var showContent: GraphQLNullable<Bool>
  public var showDisplay: GraphQLNullable<Bool>
  public var showType: GraphQLNullable<Bool>
  public var showOwner: GraphQLNullable<Bool>
  public var showPreviousTransaction: GraphQLNullable<Bool>
  public var showStorageRebate: GraphQLNullable<Bool>
  public var filter: GraphQLNullable<ObjectFilter>

  public init(
    owner: SuiAddressApollo,
    limit: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>,
    showBcs: GraphQLNullable<Bool> = false,
    showContent: GraphQLNullable<Bool> = false,
    showDisplay: GraphQLNullable<Bool> = false,
    showType: GraphQLNullable<Bool> = false,
    showOwner: GraphQLNullable<Bool> = false,
    showPreviousTransaction: GraphQLNullable<Bool> = false,
    showStorageRebate: GraphQLNullable<Bool> = false,
    filter: GraphQLNullable<ObjectFilter>
  ) {
    self.owner = owner
    self.limit = limit
    self.cursor = cursor
    self.showBcs = showBcs
    self.showContent = showContent
    self.showDisplay = showDisplay
    self.showType = showType
    self.showOwner = showOwner
    self.showPreviousTransaction = showPreviousTransaction
    self.showStorageRebate = showStorageRebate
    self.filter = filter
  }

  public var __variables: Variables? { [
    "owner": owner,
    "limit": limit,
    "cursor": cursor,
    "showBcs": showBcs,
    "showContent": showContent,
    "showDisplay": showDisplay,
    "showType": showType,
    "showOwner": showOwner,
    "showPreviousTransaction": showPreviousTransaction,
    "showStorageRebate": showStorageRebate,
    "filter": filter
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self, arguments: ["address": .variable("owner")])
    ] }

    /// Look-up an Account by its SuiAddressApollo.
    public var address: Address? { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Address }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("objects", Objects.self, arguments: [
          "first": .variable("limit"),
          "after": .variable("cursor"),
          "filter": .variable("filter")
        ])
      ] }

      /// Objects owned by this address, optionally `filter`-ed.
      public var objects: Objects { __data["objects"] }

      /// Address.Objects
      ///
      /// Parent Type: `MoveObjectConnection`
      public struct Objects: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObjectConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self)
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.Objects.PageInfo
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

        /// Address.Objects.Node
        ///
        /// Parent Type: `MoveObject`
        public struct Node: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(RPC_MOVE_OBJECT_FIELDS.self)
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

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var rPC_MOVE_OBJECT_FIELDS: RPC_MOVE_OBJECT_FIELDS { _toFragment() }
          }

          public typealias Contents = RPC_MOVE_OBJECT_FIELDS.Contents

          public typealias Owner = RPC_MOVE_OBJECT_FIELDS.Owner

          public typealias PreviousTransactionBlock = RPC_MOVE_OBJECT_FIELDS.PreviousTransactionBlock

          public typealias Display = RPC_MOVE_OBJECT_FIELDS.Display
        }
      }
    }
  }
}
