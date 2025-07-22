// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetStakesByIdsQuery: GraphQLQuery {
  public static let operationName: String = "getStakesByIds"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getStakesByIds($ids: [SuiAddress!]!, $limit: Int, $cursor: String) { objects(first: $limit, after: $cursor, filter: { objectIds: $ids }) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename asMoveObject { __typename asStakedSui { __typename ...RPC_STAKE_FIELDS } } } } }"#,
      fragments: [RPC_STAKE_FIELDS.self]
    ))

  public var ids: [SuiAddressApollo]
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>

  public init(
    ids: [SuiAddressApollo],
    limit: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>
  ) {
    self.ids = ids
    self.limit = limit
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "ids": ids,
    "limit": limit,
    "cursor": cursor
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("objects", Objects.self, arguments: [
        "first": .variable("limit"),
        "after": .variable("cursor"),
        "filter": ["objectIds": .variable("ids")]
      ])
    ] }

    /// The objects that exist in the network.
    public var objects: Objects { __data["objects"] }

    /// Objects
    ///
    /// Parent Type: `ObjectConnection`
    public struct Objects: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ObjectConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node].self)
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node] { __data["nodes"] }

      /// Objects.PageInfo
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

      /// Objects.Node
      ///
      /// Parent Type: `Object`
      public struct Node: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("asMoveObject", AsMoveObject?.self)
        ] }

        /// Attempts to convert the object into a MoveObject
        public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

        /// Objects.Node.AsMoveObject
        ///
        /// Parent Type: `MoveObject`
        public struct AsMoveObject: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("asStakedSui", AsStakedSui?.self)
          ] }

          /// Attempts to convert the Move object into a `0x3::staking_pool::StakedSui`.
          public var asStakedSui: AsStakedSui? { __data["asStakedSui"] }

          /// Objects.Node.AsMoveObject.AsStakedSui
          ///
          /// Parent Type: `StakedSui`
          public struct AsStakedSui: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.StakedSui }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(RPC_STAKE_FIELDS.self)
            ] }

            /// The SUI that was initially staked.
            public var principal: SuiKit.BigIntApollo? { __data["principal"] }
            /// The epoch at which this stake became active.
            public var activatedEpoch: ActivatedEpoch? { __data["activatedEpoch"] }
            /// A stake can be pending, active, or unstaked
            public var stakeStatus: GraphQLEnum<SuiKit.StakeStatusApollo> { __data["stakeStatus"] }
            /// The epoch at which this object was requested to join a stake pool.
            public var requestedEpoch: RequestedEpoch? { __data["requestedEpoch"] }
            /// Displays the contents of the Move object in a JSON string and through GraphQL types. Also
            /// provides the flat representation of the type signature, and the BCS of the corresponding
            /// data.
            public var contents: Contents? { __data["contents"] }
            public var address: SuiKit.SuiAddressApollo { __data["address"] }
            /// The estimated reward for this stake object, calculated as:
            ///
            /// principal * (initial_stake_rate / current_stake_rate - 1.0)
            ///
            /// Or 0, if this value is negative, where:
            ///
            /// - `initial_stake_rate` is the stake rate at the epoch this stake was activated at.
            /// - `current_stake_rate` is the stake rate in the current epoch.
            ///
            /// This value is only available if the stake is active.
            public var estimatedReward: SuiKit.BigIntApollo? { __data["estimatedReward"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var rPC_STAKE_FIELDS: RPC_STAKE_FIELDS { _toFragment() }
            }

            public typealias ActivatedEpoch = RPC_STAKE_FIELDS.ActivatedEpoch

            public typealias RequestedEpoch = RPC_STAKE_FIELDS.RequestedEpoch

            public typealias Contents = RPC_STAKE_FIELDS.Contents
          }
        }
      }
    }
  }
}
