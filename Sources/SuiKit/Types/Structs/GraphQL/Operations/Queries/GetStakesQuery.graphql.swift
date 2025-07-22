// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetStakesQuery: GraphQLQuery {
  public static let operationName: String = "getStakes"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getStakes($owner: SuiAddress!, $limit: Int, $cursor: String) { address(address: $owner) { __typename stakedSuis(first: $limit, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_STAKE_FIELDS } } } }"#,
      fragments: [RPC_STAKE_FIELDS.self]
    ))

  public var owner: SuiAddressApollo
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>

  public init(
    owner: SuiAddressApollo,
    limit: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>
  ) {
    self.owner = owner
    self.limit = limit
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "owner": owner,
    "limit": limit,
    "cursor": cursor
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self, arguments: ["address": .variable("owner")])
    ] }

    /// Look-up an Account by its SuiAddressApollo.
    public var address: Address? { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Address }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("stakedSuis", StakedSuis.self, arguments: [
          "first": .variable("limit"),
          "after": .variable("cursor")
        ])
      ] }

      /// The `0x3::staking_pool::StakedSui` objects owned by this address.
      public var stakedSuis: StakedSuis { __data["stakedSuis"] }

      /// Address.StakedSuis
      ///
      /// Parent Type: `StakedSuiConnection`
      public struct StakedSuis: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.StakedSuiConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self)
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.StakedSuis.PageInfo
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

        /// Address.StakedSuis.Node
        ///
        /// Parent Type: `StakedSui`
        public struct Node: SuiKit.SelectionSet {
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
