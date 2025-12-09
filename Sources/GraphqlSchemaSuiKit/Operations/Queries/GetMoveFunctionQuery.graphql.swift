// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetMoveFunctionQuery: GraphQLQuery {
  public static let operationName: String = "getMoveFunction"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getMoveFunction($package: SuiAddress!, $module: String!, $function: String!) { package(address: $package) { __typename module(name: $module) { __typename function(name: $function) { __typename name visibility isEntry typeParameters { __typename constraints } parameters { __typename signature } return { __typename signature } } } } }"#
    ))

  public var package: SuiAddress
  public var module: String
  public var function: String

  public init(
    package: SuiAddress,
    module: String,
    function: String
  ) {
    self.package = package
    self.module = module
    self.function = function
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "package": package,
    "module": module,
    "function": function
  ] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("package", Package?.self, arguments: ["address": .variable("package")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetMoveFunctionQuery.Data.self
    ] }

    /// Fetch a package by its address.
    ///
    /// If `version` is specified, the package loaded is the one that shares its original ID with the package at `address`, but whose version is `version`.
    ///
    /// If `atCheckpoint` is specified, the package loaded is the one with the largest version among all packages sharing an original ID with the package at `address` and was published at or before `atCheckpoint`.
    ///
    /// If neither are specified, the package is fetched at the latest checkpoint.
    ///
    /// It is an error to specify both `version` and `atCheckpoint`, and `null` will be returned if the package cannot be found as of the latest checkpoint, or the address points to an object that is not a package.
    ///
    /// Note that this interpretation of `version` and "latest" differs from the one used by `Query.object`, because non-system package upgrades generate objects with different IDs. To fetch a package using the versioning semantics of objects, use `Object.asMovePackage` nested under `Query.object`.
    public var package: Package? { __data["package"] }

    /// Package
    ///
    /// Parent Type: `MovePackage`
    public struct Package: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MovePackage }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("module", Module?.self, arguments: ["name": .variable("module")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetMoveFunctionQuery.Data.Package.self
      ] }

      /// The module named `name` in this package.
      public var module: Module? { __data["module"] }

      /// Package.Module
      ///
      /// Parent Type: `MoveModule`
      public struct Module: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveModule }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("function", Function?.self, arguments: ["name": .variable("function")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetMoveFunctionQuery.Data.Package.Module.self
        ] }

        /// The function named `name` in this module.
        public var function: Function? { __data["function"] }

        /// Package.Module.Function
        ///
        /// Parent Type: `MoveFunction`
        public struct Function: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveFunction }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("visibility", GraphQLEnum<GraphqlSchemaSuiKit.MoveVisibility>?.self),
            .field("isEntry", Bool?.self),
            .field("typeParameters", [TypeParameter]?.self),
            .field("parameters", [Parameter]?.self),
            .field("return", [Return]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetMoveFunctionQuery.Data.Package.Module.Function.self
          ] }

          /// The function's unqualified name.
          public var name: String { __data["name"] }
          /// The function's visibility: `public`, `public(friend)`, or `private`.
          public var visibility: GraphQLEnum<GraphqlSchemaSuiKit.MoveVisibility>? { __data["visibility"] }
          /// Whether the function is marked `entry` or not.
          public var isEntry: Bool? { __data["isEntry"] }
          /// Constraints on the function's formal type parameters.
          ///
          /// Move bytecode does not name type parameters, so when they are referenced (e.g. in parameter and return types), they are identified by their index in this list.
          public var typeParameters: [TypeParameter]? { __data["typeParameters"] }
          /// The function's parameter types. These types can reference type parameters introduced by this function (see `typeParameters`).
          public var parameters: [Parameter]? { __data["parameters"] }
          /// The function's return types. There can be multiple because functions in Move can return multiple values. These types can reference type parameters introduced by this function (see `typeParameters`).
          public var `return`: [Return]? { __data["return"] }

          /// Package.Module.Function.TypeParameter
          ///
          /// Parent Type: `MoveFunctionTypeParameter`
          public struct TypeParameter: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveFunctionTypeParameter }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("constraints", [GraphQLEnum<GraphqlSchemaSuiKit.MoveAbility>].self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetMoveFunctionQuery.Data.Package.Module.Function.TypeParameter.self
            ] }

            /// Ability constraints on this type parameter.
            public var constraints: [GraphQLEnum<GraphqlSchemaSuiKit.MoveAbility>] { __data["constraints"] }
          }

          /// Package.Module.Function.Parameter
          ///
          /// Parent Type: `OpenMoveType`
          public struct Parameter: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.OpenMoveType }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("signature", GraphqlSchemaSuiKit.OpenMoveTypeSignature.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetMoveFunctionQuery.Data.Package.Module.Function.Parameter.self
            ] }

            /// Structured representation of the type signature.
            public var signature: GraphqlSchemaSuiKit.OpenMoveTypeSignature { __data["signature"] }
          }

          /// Package.Module.Function.Return
          ///
          /// Parent Type: `OpenMoveType`
          public struct Return: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.OpenMoveType }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("signature", GraphqlSchemaSuiKit.OpenMoveTypeSignature.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetMoveFunctionQuery.Data.Package.Module.Function.Return.self
            ] }

            /// Structured representation of the type signature.
            public var signature: GraphqlSchemaSuiKit.OpenMoveTypeSignature { __data["signature"] }
          }
        }
      }
    }
  }
}
