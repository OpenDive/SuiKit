// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCurrentEpochQuery: GraphQLQuery {
  public static let operationName: String = "getCurrentEpoch"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCurrentEpoch { epoch { __typename epochId validatorSet { __typename activeValidators { __typename ...RPC_VALIDATOR_FIELDS } } firstCheckpoint: checkpointConnection(first: 1) { __typename nodes { __typename sequenceNumber } } startTimestamp endTimestamp referenceGasPrice } }"#,
      fragments: [RPC_CREDENTIAL_FIELDS.self, RPC_VALIDATOR_FIELDS.self]
    ))

  public init() {}

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("epoch", Epoch?.self),
    ] }

    public var epoch: Epoch? { __data["epoch"] }

    /// Epoch
    ///
    /// Parent Type: `Epoch`
    public struct Epoch: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Epoch }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("epochId", Int.self),
        .field("validatorSet", ValidatorSet?.self),
        .field("checkpointConnection", alias: "firstCheckpoint", FirstCheckpoint?.self, arguments: ["first": 1]),
        .field("startTimestamp", SuiKit.DateTimeApollo?.self),
        .field("endTimestamp", SuiKit.DateTimeApollo?.self),
        .field("referenceGasPrice", SuiKit.BigIntApollo?.self),
      ] }

      /// The epoch's id as a sequence number that starts at 0 and it is incremented by one at every epoch change
      public var epochId: Int { __data["epochId"] }
      /// Validator related properties, including the active validators
      public var validatorSet: ValidatorSet? { __data["validatorSet"] }
      /// The epoch's corresponding checkpoints
      public var firstCheckpoint: FirstCheckpoint? { __data["firstCheckpoint"] }
      /// The epoch's starting timestamp
      public var startTimestamp: SuiKit.DateTimeApollo? { __data["startTimestamp"] }
      /// The epoch's ending timestamp
      public var endTimestamp: SuiKit.DateTimeApollo? { __data["endTimestamp"] }
      /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for
      public var referenceGasPrice: SuiKit.BigIntApollo? { __data["referenceGasPrice"] }

      /// Epoch.ValidatorSet
      ///
      /// Parent Type: `ValidatorSet`
      public struct ValidatorSet: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ValidatorSet }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("activeValidators", [ActiveValidator]?.self),
        ] }

        /// The current list of active validators.
        public var activeValidators: [ActiveValidator]? { __data["activeValidators"] }

        /// Epoch.ValidatorSet.ActiveValidator
        ///
        /// Parent Type: `Validator`
        public struct ActiveValidator: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Validator }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(RPC_VALIDATOR_FIELDS.self),
          ] }

          public var atRisk: Int? { __data["atRisk"] }
          public var commissionRate: Int? { __data["commissionRate"] }
          public var exchangeRatesSize: Int? { __data["exchangeRatesSize"] }
          public var exchangeRates: RPC_VALIDATOR_FIELDS.ExchangeRates? { __data["exchangeRates"] }
          public var description: String? { __data["description"] }
          public var gasPrice: SuiKit.BigIntApollo? { __data["gasPrice"] }
          public var imageUrl: String? { __data["imageUrl"] }
          public var name: String? { __data["name"] }
          public var credentials: Credentials? { __data["credentials"] }
          public var nextEpochCommissionRate: Int? { __data["nextEpochCommissionRate"] }
          public var nextEpochGasPrice: SuiKit.BigIntApollo? { __data["nextEpochGasPrice"] }
          public var nextEpochCredentials: NextEpochCredentials? { __data["nextEpochCredentials"] }
          public var nextEpochStake: SuiKit.BigIntApollo? { __data["nextEpochStake"] }
          public var operationCap: RPC_VALIDATOR_FIELDS.OperationCap? { __data["operationCap"] }
          public var pendingPoolTokenWithdraw: SuiKit.BigIntApollo? { __data["pendingPoolTokenWithdraw"] }
          public var pendingStake: SuiKit.BigIntApollo? { __data["pendingStake"] }
          public var pendingTotalSuiWithdraw: SuiKit.BigIntApollo? { __data["pendingTotalSuiWithdraw"] }
          public var poolTokenBalance: SuiKit.BigIntApollo? { __data["poolTokenBalance"] }
          public var projectUrl: String? { __data["projectUrl"] }
          public var rewardsPool: SuiKit.BigIntApollo? { __data["rewardsPool"] }
          public var stakingPool: RPC_VALIDATOR_FIELDS.StakingPool? { __data["stakingPool"] }
          public var stakingPoolActivationEpoch: Int? { __data["stakingPoolActivationEpoch"] }
          public var stakingPoolSuiBalance: SuiKit.BigIntApollo? { __data["stakingPoolSuiBalance"] }
          public var address: RPC_VALIDATOR_FIELDS.Address { __data["address"] }
          public var votingPower: Int? { __data["votingPower"] }
          public var reportRecords: [SuiKit.SuiAddressApollo]? { __data["reportRecords"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var rPC_VALIDATOR_FIELDS: RPC_VALIDATOR_FIELDS { _toFragment() }
          }

          /// Epoch.ValidatorSet.ActiveValidator.Credentials
          ///
          /// Parent Type: `ValidatorCredentials`
          public struct Credentials: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ValidatorCredentials }

            public var netAddress: String? { __data["netAddress"] }
            public var networkPubKey: SuiKit.Base64Apollo? { __data["networkPubKey"] }
            public var p2PAddress: String? { __data["p2PAddress"] }
            public var primaryAddress: String? { __data["primaryAddress"] }
            public var workerPubKey: SuiKit.Base64Apollo? { __data["workerPubKey"] }
            public var workerAddress: String? { __data["workerAddress"] }
            public var proofOfPossession: SuiKit.Base64Apollo? { __data["proofOfPossession"] }
            public var protocolPubKey: SuiKit.Base64Apollo? { __data["protocolPubKey"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var rPC_CREDENTIAL_FIELDS: RPC_CREDENTIAL_FIELDS { _toFragment() }
            }
          }

          /// Epoch.ValidatorSet.ActiveValidator.NextEpochCredentials
          ///
          /// Parent Type: `ValidatorCredentials`
          public struct NextEpochCredentials: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ValidatorCredentials }

            public var netAddress: String? { __data["netAddress"] }
            public var networkPubKey: SuiKit.Base64Apollo? { __data["networkPubKey"] }
            public var p2PAddress: String? { __data["p2PAddress"] }
            public var primaryAddress: String? { __data["primaryAddress"] }
            public var workerPubKey: SuiKit.Base64Apollo? { __data["workerPubKey"] }
            public var workerAddress: String? { __data["workerAddress"] }
            public var proofOfPossession: SuiKit.Base64Apollo? { __data["proofOfPossession"] }
            public var protocolPubKey: SuiKit.Base64Apollo? { __data["protocolPubKey"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var rPC_CREDENTIAL_FIELDS: RPC_CREDENTIAL_FIELDS { _toFragment() }
            }
          }
        }
      }

      /// Epoch.FirstCheckpoint
      ///
      /// Parent Type: `CheckpointConnection`
      public struct FirstCheckpoint: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.CheckpointConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node].self),
        ] }

        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Epoch.FirstCheckpoint.Node
        ///
        /// Parent Type: `Checkpoint`
        public struct Node: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Checkpoint }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sequenceNumber", Int.self),
          ] }

          /// This checkpoint's position in the total order of finalised checkpoints, agreed upon by consensus.
          public var sequenceNumber: Int { __data["sequenceNumber"] }
        }
      }
    }
  }
}
