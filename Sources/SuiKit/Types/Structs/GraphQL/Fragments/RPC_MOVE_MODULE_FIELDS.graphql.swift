// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_MOVE_MODULE_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_MOVE_MODULE_FIELDS on MoveModule { name friends(first: 50) { nodes { name package { asObject { address } } } } structs(first: 50) { nodes { ...RPC_MOVE_STRUCT_FIELDS } } fileFormatVersion functions(first: 50) { nodes { ...RPC_MOVE_FUNCTION_FIELDS } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveModule }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("name", String.self),
    .field("friends", Friends.self, arguments: ["first": .scalar(50)]),
    .field("structs", Structs?.self, arguments: ["first": .scalar(50)]),
    .field("fileFormatVersion", Int.self),
    .field("functions", Functions?.self, arguments: ["first": .scalar(50)]),
  ] }

  /// The module's (unqualified) name.
  public var name: String { __data["name"] }
  /// Modules that this module considers friends (these modules can access `public(friend)`
  /// functions from this module).
  public var friends: Friends { __data["friends"] }
  /// Iterate through the structs defined in this module.
  public var structs: Structs? { __data["structs"] }
  /// Format version of this module's bytecode.
  public var fileFormatVersion: Int { __data["fileFormatVersion"] }
  /// Iterate through the signatures of functions defined in this module.
  public var functions: Functions? { __data["functions"] }

  /// Friends
  ///
  /// Parent Type: `MoveModuleConnection`
  public struct Friends: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveModuleConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("nodes", [Node].self),
    ] }

    /// A list of nodes.
    public var nodes: [Node] { __data["nodes"] }

    /// Friends.Node
    ///
    /// Parent Type: `MoveModule`
    public struct Node: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveModule }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("name", String.self),
        .field("package", Package.self),
      ] }

      /// The module's (unqualified) name.
      public var name: String { __data["name"] }
      /// The package that this Move module was defined in
      public var package: Package { __data["package"] }

      /// Friends.Node.Package
      ///
      /// Parent Type: `MovePackage`
      public struct Package: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MovePackage }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("asObject", AsObject.self),
        ] }

        public var asObject: AsObject { __data["asObject"] }

        /// Friends.Node.Package.AsObject
        ///
        /// Parent Type: `Object`
        public struct AsObject: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("address", SuiKit.SuiAddressApollo.self),
          ] }

          /// The address of the object, named as such to avoid conflict with the address type.
          public var address: SuiKit.SuiAddressApollo { __data["address"] }
        }
      }
    }
  }

  /// Structs
  ///
  /// Parent Type: `MoveStructConnection`
  public struct Structs: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveStructConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("nodes", [Node].self),
    ] }

    /// A list of nodes.
    public var nodes: [Node] { __data["nodes"] }

    /// Structs.Node
    ///
    /// Parent Type: `MoveStruct`
    public struct Node: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveStruct }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(RPC_MOVE_STRUCT_FIELDS.self),
      ] }

      /// The struct's (unqualified) type name.
      public var name: String { __data["name"] }
      /// Abilities this struct has.
      public var abilities: [GraphQLEnum<SuiKit.MoveAbility>]? { __data["abilities"] }
      /// The names and types of the struct's fields.  Field types reference type parameters, by their
      /// index in the defining struct's `typeParameters` list.
      public var fields: [RPC_MOVE_STRUCT_FIELDS.Field]? { __data["fields"] }
      /// Constraints on the struct's formal type parameters.  Move bytecode does not name type
      /// parameters, so when they are referenced (e.g. in field types) they are identified by their
      /// index in this list.
      public var typeParameters: [RPC_MOVE_STRUCT_FIELDS.TypeParameter]? { __data["typeParameters"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_MOVE_STRUCT_FIELDS: RPC_MOVE_STRUCT_FIELDS { _toFragment() }
      }
    }
  }

  /// Functions
  ///
  /// Parent Type: `MoveFunctionConnection`
  public struct Functions: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveFunctionConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("nodes", [Node].self),
    ] }

    /// A list of nodes.
    public var nodes: [Node] { __data["nodes"] }
      
      public func filterUsable() -> [Node] {
          return self.nodes.filter {
              ($0.visibility != nil && ($0.visibility! == .public || $0.visibility! == .friend)) ||
              ($0.isEntry != nil && $0.isEntry!)
          }
      }

    /// Functions.Node
    ///
    /// Parent Type: `MoveFunction`
    public struct Node: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveFunction }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(RPC_MOVE_FUNCTION_FIELDS.self),
      ] }

      /// The function's (unqualified) name.
      public var name: String { __data["name"] }
      /// The function's visibility: `public`, `public(friend)`, or `private`.
      public var visibility: GraphQLEnum<SuiKit.MoveVisibility>? { __data["visibility"] }
      /// Whether the function has the `entry` modifier or not.
      public var isEntry: Bool? { __data["isEntry"] }
      /// The function's parameter types.  These types can reference type parameters introduce by this
      /// function (see `typeParameters`).
      public var parameters: [RPC_MOVE_FUNCTION_FIELDS.Parameter]? { __data["parameters"] }
      /// Constraints on the function's formal type parameters.  Move bytecode does not name type
      /// parameters, so when they are referenced (e.g. in parameter and return types) they are
      /// identified by their index in this list.
      public var typeParameters: [RPC_MOVE_FUNCTION_FIELDS.TypeParameter]? { __data["typeParameters"] }
      /// The function's return types.  There can be multiple because functions in Move can return
      /// multiple values.  These types can reference type parameters introduced by this function (see
      /// `typeParameters`).
      public var `return`: [RPC_MOVE_FUNCTION_FIELDS.Return]? { __data["return"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_MOVE_FUNCTION_FIELDS: RPC_MOVE_FUNCTION_FIELDS { _toFragment() }
      }
    }
  }
}
