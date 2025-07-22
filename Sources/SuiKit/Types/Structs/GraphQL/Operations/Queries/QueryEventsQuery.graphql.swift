// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class QueryEventsQuery: GraphQLQuery {
  public static let operationName: String = "queryEvents"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query queryEvents($filter: EventFilter!, $before: String, $after: String, $first: Int, $last: Int) { events( filter: $filter first: $first after: $after last: $last before: $before ) { __typename pageInfo { __typename hasNextPage hasPreviousPage endCursor startCursor } nodes { __typename ...RPC_EVENTS_FIELDS } } }"#,
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

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("events", Events.self, arguments: [
        "filter": .variable("filter"),
        "first": .variable("first"),
        "after": .variable("after"),
        "last": .variable("last"),
        "before": .variable("before")
      ])
    ] }

    /// Query events that are emitted in the network.
    /// We currently do not support filtering by emitting module and event type
    /// at the same time so if both are provided in one filter, the query will error.
    public var events: Events { __data["events"] }

    /// Events
    ///
    /// Parent Type: `EventConnection`
    public struct Events: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.EventConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self)
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Events.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("hasPreviousPage", Bool.self),
          .field("endCursor", String?.self),
          .field("startCursor", String?.self)
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

      /// Events.Node
      ///
      /// Parent Type: `Event`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Event }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RPC_EVENTS_FIELDS.self)
        ] }

        /// The Move module containing some function that when called by
        /// a programmable transaction block (PTB) emitted this event.
        /// For example, if a PTB invokes A::m1::foo, which internally
        /// calls A::m2::emit_event to emit an event,
        /// the sending module would be A::m1.
        public var JSONApollo: SuiKit.JSONApollo { __data["JSONApollo"] }
        public var sendingModule: SendingModule? { __data["sendingModule"] }
        /// Address of the sender of the event
        public var sender: Sender? { __data["sender"] }
        /// The event's contents as a Move value.
        public var contents: Contents { __data["contents"] }
        /// UTC timestamp in milliseconds since epoch (1/1/1970)
        public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rPC_EVENTS_FIELDS: RPC_EVENTS_FIELDS { _toFragment() }
        }

        public typealias SendingModule = RPC_EVENTS_FIELDS.SendingModule

        public typealias Sender = RPC_EVENTS_FIELDS.Sender

        public typealias Contents = RPC_EVENTS_FIELDS.Contents
      }
    }
  }
}
