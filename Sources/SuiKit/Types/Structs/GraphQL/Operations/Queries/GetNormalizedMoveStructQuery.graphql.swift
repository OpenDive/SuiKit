// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetNormalizedMoveStructQuery: GraphQLQuery {
  public static let operationName: String = "getNormalizedMoveStruct"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getNormalizedMoveStruct($packageId: SuiAddress!, $module: String!, $struct: String!) { object(address: $packageId) { __typename asMovePackage { __typename address module(name: $module) { __typename fileFormatVersion struct(name: $struct) { __typename ...RPC_MOVE_STRUCT_FIELDS } } } } }"#,
      fragments: [RPC_MOVE_STRUCT_FIELDS.self]
    ))

  public var packageId: SuiAddressApollo
  public var module: String
  public var `struct`: String

  public init(
    packageId: SuiAddressApollo,
    module: String,
    `struct`: String
  ) {
    self.packageId = packageId
    self.module = module
    self.`struct` = `struct`
  }

  public var __variables: Variables? { [
    "packageId": packageId,
    "module": module,
    "struct": `struct`
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
          .field("address", SuiKit.SuiAddressApollo.self),
          .field("module", Module?.self, arguments: ["name": .variable("module")])
        ] }

        public var address: SuiKit.SuiAddressApollo { __data["address"] }
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
            .field("fileFormatVersion", Int.self),
            .field("struct", Struct?.self, arguments: ["name": .variable("struct")])
          ] }

          /// Format version of this module's bytecode.
          public var fileFormatVersion: Int { __data["fileFormatVersion"] }
          /// Look-up the definition of a struct defined in this module, by its name.
          public var `struct`: Struct? { __data["struct"] }

          /// Object.AsMovePackage.Module.Struct
          ///
          /// Parent Type: `MoveStruct`
          public struct Struct: SuiKit.SelectionSet {
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
      }
    }
  }
}
