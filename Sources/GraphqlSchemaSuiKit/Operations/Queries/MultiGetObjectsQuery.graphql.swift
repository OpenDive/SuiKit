// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct MultiGetObjectsQuery: GraphQLQuery {
  public static let operationName: String = "multiGetObjects"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query multiGetObjects($objectKeys: [ObjectKey!]!) { multiGetObjects(keys: $objectKeys) { __typename ...OBJECT_FIELDS } }"#,
      fragments: [OBJECT_FIELDS.self, OBJECT_OWNER_FIELDS.self]
    ))

  public var objectKeys: [ObjectKey]

  public init(objectKeys: [ObjectKey]) {
    self.objectKeys = objectKeys
  }

  @_spi(Unsafe) public var __variables: Variables? { ["objectKeys": objectKeys] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("multiGetObjects", [MultiGetObject?].self, arguments: ["keys": .variable("objectKeys")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MultiGetObjectsQuery.Data.self
    ] }

    /// Fetch objects by their keys.
    ///
    /// Returns a list of objects that is guaranteed to be the same length as `keys`. If an object in `keys` could not be found in the store, its corresponding entry in the result will be `null`. This could be because the object never existed, or because it was pruned.
    public var multiGetObjects: [MultiGetObject?] { __data["multiGetObjects"] }

    /// MultiGetObject
    ///
    /// Parent Type: `Object`
    public struct MultiGetObject: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Object }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(OBJECT_FIELDS.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MultiGetObjectsQuery.Data.MultiGetObject.self,
        OBJECT_FIELDS.self
      ] }

      /// The Object's ID.
      public var address: GraphqlSchemaSuiKit.SuiAddress { __data["address"] }
      /// 32-byte hash that identifies the object's contents, encoded in Base58.
      public var digest: String? { __data["digest"] }
      /// The version of this object that this content comes from.
      public var version: GraphqlSchemaSuiKit.UInt53? { __data["version"] }
      /// Attempts to convert the object into a MoveObject.
      public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
      /// The object's owner kind.
      public var owner: Owner? { __data["owner"] }
      /// The transaction that created this version of the object.
      public var previousTransaction: PreviousTransaction? { __data["previousTransaction"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var oBJECT_FIELDS: OBJECT_FIELDS { _toFragment() }
      }

      public typealias AsMoveObject = OBJECT_FIELDS.AsMoveObject

      public typealias Owner = OBJECT_FIELDS.Owner

      public typealias PreviousTransaction = OBJECT_FIELDS.PreviousTransaction
    }
  }
}
