// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class QueryEventsQuery: GraphQLQuery {
  public static let operationName: String = "queryEvents"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query queryEvents($filter: EventFilter!, $before: String, $after: String, $first: Int, $last: Int) { eventConnection( filter: $filter first: $first after: $after last: $last before: $before ) { __typename pageInfo { __typename hasNextPage hasPreviousPage endCursor startCursor } nodes { __typename sendingModule { __typename package { __typename asObject { __typename location } } name } senders { __typename location } eventType { __typename repr } json bcs timestamp } } }"#
    ))

  public var filter: EventFilter
  public var before: GraphQLNullable<String>
  public var after: GraphQLNullable<String>
  public var first: GraphQLNullable<Int>
  public var last: GraphQLNullable<Int>

  public init(
    filter: EventFilter,
    before: GraphQLNullable<String>,
    after: GraphQLNullable<String>,
    first: GraphQLNullable<Int>,
    last: GraphQLNullable<Int>
  ) {
    self.filter = filter
    self.before = before
    self.after = after
    self.first = first
    self.last = last
  }

  public var __variables: Variables? { [
    "filter": filter,
    "before": before,
    "after": after,
    "first": first,
    "last": last
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("eventConnection", EventConnection?.self, arguments: [
        "filter": .variable("filter"),
        "first": .variable("first"),
        "after": .variable("after"),
        "last": .variable("last"),
        "before": .variable("before")
      ]),
    ] }

    public var eventConnection: EventConnection? { __data["eventConnection"] }

    /// EventConnection
    ///
    /// Parent Type: `EventConnection`
    public struct EventConnection: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.EventConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self),
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// EventConnection.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("hasPreviousPage", Bool.self),
          .field("endCursor", String?.self),
          .field("startCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool { __data["hasPreviousPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? { __data["startCursor"] }
      }

      /// EventConnection.Node
      ///
      /// Parent Type: `Event`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Event }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("sendingModule", SendingModule?.self),
          .field("senders", [Sender]?.self),
          .field("eventType", EventType?.self),
          .field("json", String?.self),
          .field("bcs", SuiKit.Base64Apollo?.self),
          .field("timestamp", SuiKit.DateTimeApollo?.self),
        ] }

        /// The Move module that the event was emitted in.
        public var sendingModule: SendingModule? { __data["sendingModule"] }
        public var senders: [Sender]? { __data["senders"] }
        /// Package, module, and type of the event
        public var eventType: EventType? { __data["eventType"] }
        /// JSON string representation of the event
        public var json: String? { __data["json"] }
        /// Base64 encoded bcs bytes of the Move event
        public var bcs: SuiKit.Base64Apollo? { __data["bcs"] }
        /// UTC timestamp in milliseconds since epoch (1/1/1970)
        public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }

        /// EventConnection.Node.SendingModule
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

          /// EventConnection.Node.SendingModule.Package
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

            /// EventConnection.Node.SendingModule.Package.AsObject
            ///
            /// Parent Type: `Object`
            public struct AsObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("location", SuiKit.SuiAddressApollo.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var location: SuiKit.SuiAddressApollo { __data["location"] }
            }
          }
        }

        /// EventConnection.Node.Sender
        ///
        /// Parent Type: `Address`
        public struct Sender: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("location", SuiKit.SuiAddressApollo.self),
          ] }

          public var location: SuiKit.SuiAddressApollo { __data["location"] }
        }

        /// EventConnection.Node.EventType
        ///
        /// Parent Type: `MoveType`
        public struct EventType: SuiKit.SelectionSet {
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
    }
  }
}
