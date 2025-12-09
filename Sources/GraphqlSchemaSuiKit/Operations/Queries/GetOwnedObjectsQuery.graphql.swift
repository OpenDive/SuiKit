// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetOwnedObjectsQuery: GraphQLQuery {
  public static let operationName: String = "getOwnedObjects"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getOwnedObjects($owner: SuiAddress!, $limit: Int, $cursor: String, $filter: ObjectFilter) { address(address: $owner) { __typename objects(first: $limit, after: $cursor, filter: $filter) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...MOVE_OBJECT_FIELDS } } } }"#,
      fragments: [MOVE_OBJECT_FIELDS.self, OBJECT_OWNER_FIELDS.self]
    ))

  public var owner: SuiAddress
  public var limit: GraphQLNullable<Int32>
  public var cursor: GraphQLNullable<String>
  public var filter: GraphQLNullable<ObjectFilter>

  public init(
    owner: SuiAddress,
    limit: GraphQLNullable<Int32>,
    cursor: GraphQLNullable<String>,
    filter: GraphQLNullable<ObjectFilter>
  ) {
    self.owner = owner
    self.limit = limit
    self.cursor = cursor
    self.filter = filter
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "owner": owner,
    "limit": limit,
    "cursor": cursor,
    "filter": filter
  ] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address.self, arguments: ["address": .variable("owner")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetOwnedObjectsQuery.Data.self
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
        .field("objects", Objects?.self, arguments: [
          "first": .variable("limit"),
          "after": .variable("cursor"),
          "filter": .variable("filter")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetOwnedObjectsQuery.Data.Address.self
      ] }

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
          GetOwnedObjectsQuery.Data.Address.Objects.self
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
            GetOwnedObjectsQuery.Data.Address.Objects.PageInfo.self
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
            .fragment(MOVE_OBJECT_FIELDS.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetOwnedObjectsQuery.Data.Address.Objects.Node.self,
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

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var mOVE_OBJECT_FIELDS: MOVE_OBJECT_FIELDS { _toFragment() }
          }

          public typealias Contents = MOVE_OBJECT_FIELDS.Contents

          public typealias Owner = MOVE_OBJECT_FIELDS.Owner

          public typealias PreviousTransaction = MOVE_OBJECT_FIELDS.PreviousTransaction
        }
      }
    }
  }
}
