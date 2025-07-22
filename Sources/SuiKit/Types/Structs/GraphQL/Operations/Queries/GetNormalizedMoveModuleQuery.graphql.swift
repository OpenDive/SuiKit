// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetNormalizedMoveModuleQuery: GraphQLQuery {
  public static let operationName: String = "getNormalizedMoveModule"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getNormalizedMoveModule($packageId: SuiAddress!, $module: String!) { object(address: $packageId) { __typename asMovePackage { __typename module(name: $module) { __typename ...RPC_MOVE_MODULE_FIELDS } } } }"#,
      fragments: [RPC_MOVE_ENUM_FIELDS.self, RPC_MOVE_FUNCTION_FIELDS.self, RPC_MOVE_MODULE_FIELDS.self, RPC_MOVE_STRUCT_FIELDS.self]
    ))

  public var packageId: SuiAddressApollo
  public var module: String

  public init(
    packageId: SuiAddressApollo,
    module: String
  ) {
    self.packageId = packageId
    self.module = module
  }

  public var __variables: Variables? { [
    "packageId": packageId,
    "module": module
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
            .fragment(RPC_MOVE_MODULE_FIELDS.self)
          ] }

          /// The module's (unqualified) name.
          public var name: String { __data["name"] }
          /// Modules that this module considers friends (these modules can access `public(friend)`
          /// functions from this module).
          public var friends: Friends { __data["friends"] }
          /// Iterate through the structs defined in this module.
          public var structs: Structs? { __data["structs"] }
          /// Iterate through the enums defined in this module.
          public var enums: Enums? { __data["enums"] }
          /// Format version of this module's bytecode.
          public var fileFormatVersion: Int { __data["fileFormatVersion"] }
          /// Iterate through the signatures of functions defined in this module.
          public var functions: Functions? { __data["functions"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var rPC_MOVE_MODULE_FIELDS: RPC_MOVE_MODULE_FIELDS { _toFragment() }
          }

          public typealias Friends = RPC_MOVE_MODULE_FIELDS.Friends

          public typealias Structs = RPC_MOVE_MODULE_FIELDS.Structs

          public typealias Enums = RPC_MOVE_MODULE_FIELDS.Enums

          public typealias Functions = RPC_MOVE_MODULE_FIELDS.Functions
        }
      }
    }
  }
}
