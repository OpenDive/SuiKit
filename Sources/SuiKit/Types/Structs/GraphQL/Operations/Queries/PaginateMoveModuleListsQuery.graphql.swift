// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PaginateMoveModuleListsQuery: GraphQLQuery {
  public static let operationName: String = "paginateMoveModuleLists"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query paginateMoveModuleLists($packageId: SuiAddress!, $module: String!, $hasMoreFriends: Boolean!, $hasMoreStructs: Boolean!, $hasMoreFunctions: Boolean!, $hasMoreEnums: Boolean!, $afterFriends: String, $afterStructs: String, $afterFunctions: String, $afterEnums: String) { object(address: $packageId) { __typename asMovePackage { __typename module(name: $module) { __typename friends(after: $afterFriends) @include(if: $hasMoreFriends) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename name package { __typename address } } } structs(after: $afterStructs) @include(if: $hasMoreStructs) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_STRUCT_FIELDS } } enums(after: $afterEnums) @include(if: $hasMoreEnums) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_ENUM_FIELDS } } functions(after: $afterFunctions) @include(if: $hasMoreFunctions) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_FUNCTION_FIELDS } } } } } }"#,
      fragments: [RPC_MOVE_ENUM_FIELDS.self, RPC_MOVE_FUNCTION_FIELDS.self, RPC_MOVE_STRUCT_FIELDS.self]
    ))

  public var packageId: SuiAddressApollo
  public var module: String
  public var hasMoreFriends: Bool
  public var hasMoreStructs: Bool
  public var hasMoreFunctions: Bool
  public var hasMoreEnums: Bool
  public var afterFriends: GraphQLNullable<String>
  public var afterStructs: GraphQLNullable<String>
  public var afterFunctions: GraphQLNullable<String>
  public var afterEnums: GraphQLNullable<String>

  public init(
    packageId: SuiAddressApollo,
    module: String,
    hasMoreFriends: Bool,
    hasMoreStructs: Bool,
    hasMoreFunctions: Bool,
    hasMoreEnums: Bool,
    afterFriends: GraphQLNullable<String>,
    afterStructs: GraphQLNullable<String>,
    afterFunctions: GraphQLNullable<String>,
    afterEnums: GraphQLNullable<String>
  ) {
    self.packageId = packageId
    self.module = module
    self.hasMoreFriends = hasMoreFriends
    self.hasMoreStructs = hasMoreStructs
    self.hasMoreFunctions = hasMoreFunctions
    self.hasMoreEnums = hasMoreEnums
    self.afterFriends = afterFriends
    self.afterStructs = afterStructs
    self.afterFunctions = afterFunctions
    self.afterEnums = afterEnums
  }

  public var __variables: Variables? { [
    "packageId": packageId,
    "module": module,
    "hasMoreFriends": hasMoreFriends,
    "hasMoreStructs": hasMoreStructs,
    "hasMoreFunctions": hasMoreFunctions,
    "hasMoreEnums": hasMoreEnums,
    "afterFriends": afterFriends,
    "afterStructs": afterStructs,
    "afterFunctions": afterFunctions,
    "afterEnums": afterEnums
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("object", Object?.self, arguments: ["address": .variable("packageId")])
    ] }

    /// The object corresponding to the given address at the (optionally) given version.
    /// When no version is given, the latest version is returned.
    public var object: Object? { __data["object"] }

    /// Object
    ///
    /// Parent Type: `Object`
    public struct Object: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("asMovePackage", AsMovePackage?.self)
      ] }

      /// Attempts to convert the object into a MovePackage
      public var asMovePackage: AsMovePackage? { __data["asMovePackage"] }

      /// Object.AsMovePackage
      ///
      /// Parent Type: `MovePackage`
      public struct AsMovePackage: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MovePackage }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("module", Module?.self, arguments: ["name": .variable("module")])
        ] }

        /// A representation of the module called `name` in this package, including the
        /// structs and functions it defines.
        public var module: Module? { __data["module"] }

        /// Object.AsMovePackage.Module
        ///
        /// Parent Type: `MoveModule`
        public struct Module: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveModule }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .include(if: "hasMoreFriends", .field("friends", Friends.self, arguments: ["after": .variable("afterFriends")])),
            .include(if: "hasMoreStructs", .field("structs", Structs?.self, arguments: ["after": .variable("afterStructs")])),
            .include(if: "hasMoreEnums", .field("enums", Enums?.self, arguments: ["after": .variable("afterEnums")])),
            .include(if: "hasMoreFunctions", .field("functions", Functions?.self, arguments: ["after": .variable("afterFunctions")]))
          ] }

          /// Modules that this module considers friends (these modules can access `public(friend)`
          /// functions from this module).
          public var friends: Friends? { __data["friends"] }
          /// Iterate through the structs defined in this module.
          public var structs: Structs? { __data["structs"] }
          /// Iterate through the enums defined in this module.
          public var enums: Enums? { __data["enums"] }
          /// Iterate through the signatures of functions defined in this module.
          public var functions: Functions? { __data["functions"] }

          /// Object.AsMovePackage.Module.Friends
          ///
          /// Parent Type: `MoveModuleConnection`
          public struct Friends: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveModuleConnection }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("pageInfo", PageInfo.self),
              .field("nodes", [Node].self)
            ] }

            /// Information to aid in pagination.
            public var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            public var nodes: [Node] { __data["nodes"] }

            /// Object.AsMovePackage.Module.Friends.PageInfo
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

            /// Object.AsMovePackage.Module.Friends.Node
            ///
            /// Parent Type: `MoveModule`
            public struct Node: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveModule }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("name", String.self),
                .field("package", Package.self)
              ] }

              /// The module's (unqualified) name.
              public var name: String { __data["name"] }
              /// The package that this Move module was defined in
              public var package: Package { __data["package"] }

              /// Object.AsMovePackage.Module.Friends.Node.Package
              ///
              /// Parent Type: `MovePackage`
              public struct Package: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MovePackage }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("address", SuiKit.SuiAddressApollo.self)
                ] }

                public var address: SuiKit.SuiAddressApollo { __data["address"] }
              }
            }
          }

          /// Object.AsMovePackage.Module.Structs
          ///
          /// Parent Type: `MoveStructConnection`
          public struct Structs: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveStructConnection }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("pageInfo", PageInfo.self),
              .field("nodes", [Node].self)
            ] }

            /// Information to aid in pagination.
            public var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            public var nodes: [Node] { __data["nodes"] }

            /// Object.AsMovePackage.Module.Structs.PageInfo
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

            /// Object.AsMovePackage.Module.Structs.Node
            ///
            /// Parent Type: `MoveStruct`
            public struct Node: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveStruct }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(RPC_MOVE_STRUCT_FIELDS.self)
              ] }

              /// The struct's (unqualified) type name.
              public var name: String { __data["name"] }
              /// Abilities this struct has.
              public var abilities: [GraphQLEnum<SuiKit.MoveAbility>]? { __data["abilities"] }
              /// The names and types of the struct's fields.  Field types reference type parameters, by their
              /// index in the defining struct's `typeParameters` list.
              public var fields: [Field]? { __data["fields"] }
              /// Constraints on the struct's formal type parameters.  Move bytecode does not name type
              /// parameters, so when they are referenced (e.g. in field types) they are identified by their
              /// index in this list.
              public var typeParameters: [TypeParameter]? { __data["typeParameters"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var rPC_MOVE_STRUCT_FIELDS: RPC_MOVE_STRUCT_FIELDS { _toFragment() }
              }

              public typealias Field = RPC_MOVE_STRUCT_FIELDS.Field

              public typealias TypeParameter = RPC_MOVE_STRUCT_FIELDS.TypeParameter
            }
          }

          /// Object.AsMovePackage.Module.Enums
          ///
          /// Parent Type: `MoveEnumConnection`
          public struct Enums: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveEnumConnection }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("pageInfo", PageInfo.self),
              .field("nodes", [Node].self)
            ] }

            /// Information to aid in pagination.
            public var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            public var nodes: [Node] { __data["nodes"] }

            /// Object.AsMovePackage.Module.Enums.PageInfo
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

            /// Object.AsMovePackage.Module.Enums.Node
            ///
            /// Parent Type: `MoveEnum`
            public struct Node: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveEnum }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(RPC_MOVE_ENUM_FIELDS.self)
              ] }

              /// The enum's (unqualified) type name.
              public var name: String { __data["name"] }
              /// The enum's abilities.
              public var abilities: [GraphQLEnum<SuiKit.MoveAbility>]? { __data["abilities"] }
              /// Constraints on the enum's formal type parameters.  Move bytecode does not name type
              /// parameters, so when they are referenced (e.g. in field types) they are identified by their
              /// index in this list.
              public var typeParameters: [TypeParameter]? { __data["typeParameters"] }
              /// The names and types of the enum's fields.  Field types reference type parameters, by their
              /// index in the defining enum's `typeParameters` list.
              public var variants: [Variant]? { __data["variants"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var rPC_MOVE_ENUM_FIELDS: RPC_MOVE_ENUM_FIELDS { _toFragment() }
              }

              public typealias TypeParameter = RPC_MOVE_ENUM_FIELDS.TypeParameter

              public typealias Variant = RPC_MOVE_ENUM_FIELDS.Variant
            }
          }

          /// Object.AsMovePackage.Module.Functions
          ///
          /// Parent Type: `MoveFunctionConnection`
          public struct Functions: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveFunctionConnection }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("pageInfo", PageInfo.self),
              .field("nodes", [Node].self)
            ] }

            /// Information to aid in pagination.
            public var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            public var nodes: [Node] { __data["nodes"] }

            /// Object.AsMovePackage.Module.Functions.PageInfo
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

            /// Object.AsMovePackage.Module.Functions.Node
            ///
            /// Parent Type: `MoveFunction`
            public struct Node: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveFunction }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(RPC_MOVE_FUNCTION_FIELDS.self)
              ] }

              /// The function's (unqualified) name.
              public var name: String { __data["name"] }
              /// The function's visibility: `public`, `public(friend)`, or `private`.
              public var visibility: GraphQLEnum<SuiKit.MoveVisibility>? { __data["visibility"] }
              /// Whether the function has the `entry` modifier or not.
              public var isEntry: Bool? { __data["isEntry"] }
              /// The function's parameter types.  These types can reference type parameters introduce by this
              /// function (see `typeParameters`).
              public var parameters: [Parameter]? { __data["parameters"] }
              /// Constraints on the function's formal type parameters.  Move bytecode does not name type
              /// parameters, so when they are referenced (e.g. in parameter and return types) they are
              /// identified by their index in this list.
              public var typeParameters: [TypeParameter]? { __data["typeParameters"] }
              /// The function's return types.  There can be multiple because functions in Move can return
              /// multiple values.  These types can reference type parameters introduced by this function (see
              /// `typeParameters`).
              public var `return`: [Return]? { __data["return"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var rPC_MOVE_FUNCTION_FIELDS: RPC_MOVE_FUNCTION_FIELDS { _toFragment() }
              }

              public typealias Parameter = RPC_MOVE_FUNCTION_FIELDS.Parameter

              public typealias TypeParameter = RPC_MOVE_FUNCTION_FIELDS.TypeParameter

              public typealias Return = RPC_MOVE_FUNCTION_FIELDS.Return
            }
          }
        }
      }
    }
  }
}
