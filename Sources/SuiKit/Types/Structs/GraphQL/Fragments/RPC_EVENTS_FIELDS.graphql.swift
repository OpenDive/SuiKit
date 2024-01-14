// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_EVENTS_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_EVENTS_FIELDS on Event { __typename sendingModule { __typename package { __typename asObject { __typename address } } name } senders { __typename address } type { __typename repr } JSONApollo bcs timestamp }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Event }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("sendingModule", SendingModule?.self),
    .field("senders", [Sender]?.self),
    .field("type", Type_SelectionSet.self),
    .field("JSONApollo", SuiKit.JSONApollo.self),
    .field("bcs", SuiKit.Base64Apollo.self),
    .field("timestamp", SuiKit.DateTimeApollo?.self),
  ] }

  /// The Move module containing some function that when called by
  /// a programmable transaction block (PTB) emitted this event.
  /// For example, if a PTB invokes A::m1::foo, which internally
  /// calls A::m2::emit_event to emit an event,
  /// the sending module would be A::m1.
  public var sendingModule: SendingModule? { __data["sendingModule"] }
  /// Addresses of the senders of the event
  public var senders: [Sender]? { __data["senders"] }
  public var type: Type_SelectionSet { __data["type"] }
  /// Representation of a Move value in JSONApollo, where:
  ///
  /// - Addresses, IDs, and UIDs are represented in canonical form, as JSONApollo strings.
  /// - Bools are represented by JSONApollo boolean literals.
  /// - u8, u16, and u32 are represented as JSONApollo numbers.
  /// - u64, u128, and u256 are represented as JSONApollo strings.
  /// - Vectors are represented by JSONApollo arrays.
  /// - Structs are represented by JSONApollo objects.
  /// - Empty optional values are represented by `null`.
  ///
  /// This form is offered as a less verbose convenience in cases where the layout of the type is
  /// known by the client.
  public var JSONApollo: SuiKit.JSONApollo { __data["JSONApollo"] }
  public var bcs: SuiKit.Base64Apollo { __data["bcs"] }
  /// UTC timestamp in milliseconds since epoch (1/1/1970)
  public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }

  /// SendingModule
  ///
  /// Parent Type: `MoveModule`
  public struct SendingModule: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveModule }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("package", Package.self),
      .field("name", String.self),
    ] }

    /// The package that this Move module was defined in
    public var package: Package { __data["package"] }
    /// The module's (unqualified) name.
    public var name: String { __data["name"] }

    /// SendingModule.Package
    ///
    /// Parent Type: `MovePackage`
    public struct Package: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MovePackage }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("asObject", AsObject.self),
      ] }

      public var asObject: AsObject { __data["asObject"] }

      /// SendingModule.Package.AsObject
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
    }
  }

  /// Sender
  ///
  /// Parent Type: `Address`
  public struct Sender: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("address", SuiKit.SuiAddressApollo.self),
    ] }

    public var address: SuiKit.SuiAddressApollo { __data["address"] }
  }

  /// Type_SelectionSet
  ///
  /// Parent Type: `MoveType`
  public struct Type_SelectionSet: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("repr", String.self),
    ] }

    /// Flat representation of the type signature, as a displayable string.
    public var repr: String { __data["repr"] }
  }
}
