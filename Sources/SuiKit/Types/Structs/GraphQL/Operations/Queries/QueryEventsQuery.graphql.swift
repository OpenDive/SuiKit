// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class QueryEventsQuery: GraphQLQuery {
  public static let operationName: String = "queryEvents"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query queryEvents($filter: EventFilter!, $before: String, $after: String, $first: Int, $last: Int) { eventConnection( filter: $filter first: $first after: $after last: $last before: $before ) { __typename pageInfo { __typename hasNextPage hasPreviousPage endCursor startCursor } nodes { __typename ...RPC_EVENTS_FIELDS } } }"#,
      fragments: [RPC_EVENTS_FIELDS.self]
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
          .fragment(RPC_EVENTS_FIELDS.self),
        ] }

        /// The Move module containing some function that when called by
        /// a programmable transaction block (PTB) emitted this event.
        /// For example, if a PTB invokes A::m1::foo, which internally
        /// calls A::m2::emit_event to emit an event,
        /// the sending module would be A::m1.
        public var sendingModule: RPC_EVENTS_FIELDS.SendingModule? { __data["sendingModule"] }
        /// Addresses of the senders of the event
        public var senders: [RPC_EVENTS_FIELDS.Sender]? { __data["senders"] }
        public var type: RPC_EVENTS_FIELDS.Type_SelectionSet { __data["type"] }
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

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rPC_EVENTS_FIELDS: RPC_EVENTS_FIELDS { _toFragment() }
        }
      }
    }
  }
}
