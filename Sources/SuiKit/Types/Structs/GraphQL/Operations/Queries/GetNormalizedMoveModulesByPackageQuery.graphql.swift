// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetNormalizedMoveModulesByPackageQuery: GraphQLQuery {
  public static let operationName: String = "getNormalizedMoveModulesByPackage"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getNormalizedMoveModulesByPackage($packageId: SuiAddressApollo!, $limit: Int = 50, $cursor: String) { object(address: $packageId) { __typename asMovePackage { __typename asObject { __typename address } modules(first: $limit, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_MODULE_FIELDS } } } } }"#,
      fragments: [RPC_MOVE_FUNCTION_FIELDS.self, RPC_MOVE_MODULE_FIELDS.self, RPC_MOVE_STRUCT_FIELDS.self]
    ))

  public var packageId: SuiAddressApollo
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>

  public init(
    packageId: SuiAddressApollo,
    limit: GraphQLNullable<Int> = 50,
    cursor: GraphQLNullable<String>
  ) {
    self.packageId = packageId
    self.limit = limit
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "packageId": packageId,
    "limit": limit,
    "cursor": cursor
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("object", Object?.self, arguments: ["address": .variable("packageId")]),
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
        .field("asMovePackage", AsMovePackage?.self),
      ] }

      /// Attempts to convert the object into a MovePackage
      public var asMovePackage: AsMovePackage? { __data["asMovePackage"] }

      /// Object.AsMovePackage
      ///
      /// Parent Type: `MovePackage`
      public struct AsMovePackage: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MovePackage }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("asObject", AsObject.self),
          .field("modules", Modules?.self, arguments: [
            "first": .variable("limit"),
            "after": .variable("cursor")
          ]),
        ] }

        public var asObject: AsObject { __data["asObject"] }
        /// Paginate through the MoveModules defined in this package.
        public var modules: Modules? { __data["modules"] }

        /// Object.AsMovePackage.AsObject
        ///
        /// Parent Type: `Object`
        public struct AsObject: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("address", SuiKit.SuiAddressApollo.self),
          ] }

          /// The address of the object, named as such to avoid conflict with the address type.
          public var address: SuiKit.SuiAddressApollo { __data["address"] }
        }

        /// Object.AsMovePackage.Modules
        ///
        /// Parent Type: `MoveModuleConnection`
        public struct Modules: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveModuleConnection }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("pageInfo", PageInfo.self),
            .field("nodes", [Node].self),
          ] }

          /// Information to aid in pagination.
          public var pageInfo: PageInfo { __data["pageInfo"] }
          /// A list of nodes.
          public var nodes: [Node] { __data["nodes"] }

          /// Object.AsMovePackage.Modules.PageInfo
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

          /// Object.AsMovePackage.Modules.Node
          ///
          /// Parent Type: `MoveModule`
          public struct Node: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveModule }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(RPC_MOVE_MODULE_FIELDS.self),
            ] }

            /// The module's (unqualified) name.
            public var name: String { __data["name"] }
            /// Modules that this module considers friends (these modules can access `public(friend)`
            /// functions from this module).
            public var friends: RPC_MOVE_MODULE_FIELDS.Friends { __data["friends"] }
            /// Iterate through the structs defined in this module.
            public var structs: RPC_MOVE_MODULE_FIELDS.Structs? { __data["structs"] }
            /// Format version of this module's bytecode.
            public var fileFormatVersion: Int { __data["fileFormatVersion"] }
            /// Iterate through the signatures of functions defined in this module.
            public var functions: RPC_MOVE_MODULE_FIELDS.Functions? { __data["functions"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var rPC_MOVE_MODULE_FIELDS: RPC_MOVE_MODULE_FIELDS { _toFragment() }
            }
          }
        }
      }
    }
  }
}
