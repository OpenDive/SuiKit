// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCommitteeInfoQuery: GraphQLQuery {
  public static let operationName: String = "getCommitteeInfo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCommitteeInfo($epochId: UInt53, $after: String) { epoch(id: $epochId) { __typename epochId validatorSet { __typename activeValidators(after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename credentials { __typename protocolPubKey } votingPower } } } } }"#
    ))

  public var epochId: GraphQLNullable<UInt53Apollo>
  public var after: GraphQLNullable<String>

  public init(
    epochId: GraphQLNullable<UInt53Apollo>,
    after: GraphQLNullable<String>
  ) {
    self.epochId = epochId
    self.after = after
  }

  public var __variables: Variables? { [
    "epochId": epochId,
    "after": after
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("epoch", Epoch?.self, arguments: ["id": .variable("epochId")])
    ] }

    /// Fetch epoch information by ID (defaults to the latest epoch).
    public var epoch: Epoch? { __data["epoch"] }

    /// Epoch
    ///
    /// Parent Type: `Epoch`
    public struct Epoch: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Epoch }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("epochId", SuiKit.UInt53Apollo.self),
        .field("validatorSet", ValidatorSet?.self)
      ] }

      /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
      public var epochId: SuiKit.UInt53Apollo { __data["epochId"] }
      /// Validator related properties, including the active validators.
      public var validatorSet: ValidatorSet? { __data["validatorSet"] }

      /// Epoch.ValidatorSet
      ///
      /// Parent Type: `ValidatorSet`
      public struct ValidatorSet: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ValidatorSet }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("activeValidators", ActiveValidators.self, arguments: ["after": .variable("after")])
        ] }

        /// The current set of active validators.
        public var activeValidators: ActiveValidators { __data["activeValidators"] }

        /// Epoch.ValidatorSet.ActiveValidators
        ///
        /// Parent Type: `ValidatorConnection`
        public struct ActiveValidators: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ValidatorConnection }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("pageInfo", PageInfo.self),
            .field("nodes", [Node].self)
          ] }

          /// Information to aid in pagination.
          public var pageInfo: PageInfo { __data["pageInfo"] }
          /// A list of nodes.
          public var nodes: [Node] { __data["nodes"] }

          /// Epoch.ValidatorSet.ActiveValidators.PageInfo
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

          /// Epoch.ValidatorSet.ActiveValidators.Node
          ///
          /// Parent Type: `Validator`
          public struct Node: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Validator }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("credentials", Credentials?.self),
              .field("votingPower", Int?.self)
            ] }

            /// Validator's set of credentials such as public keys, network addresses and others.
            public var credentials: Credentials? { __data["credentials"] }
            /// The voting power of this validator in basis points (e.g., 100 = 1% voting power).
            public var votingPower: Int? { __data["votingPower"] }

            /// Epoch.ValidatorSet.ActiveValidators.Node.Credentials
            ///
            /// Parent Type: `ValidatorCredentials`
            public struct Credentials: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ValidatorCredentials }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("protocolPubKey", SuiKit.Base64Apollo?.self)
              ] }

              public var protocolPubKey: SuiKit.Base64Apollo? { __data["protocolPubKey"] }
            }
          }
        }
      }
    }
  }
}
