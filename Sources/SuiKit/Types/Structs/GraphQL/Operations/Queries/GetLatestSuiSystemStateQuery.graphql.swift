// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetLatestSuiSystemStateQuery: GraphQLQuery {
  public static let operationName: String = "getLatestSuiSystemState"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getLatestSuiSystemState { latestSuiSystemState { __typename referenceGasPrice safeMode { __typename enabled gasSummary { __typename computationCost nonRefundableStorageFee storageCost storageRebate } } stakeSubsidy { __typename balance currentDistributionAmount decreaseRate distributionCounter periodLength } storageFund { __typename nonRefundableBalance totalObjectStorageRebates } systemStateVersion systemParameters { __typename minValidatorCount maxValidatorCount minValidatorJoiningStake durationMs validatorLowStakeThreshold validatorLowStakeGracePeriod validatorVeryLowStakeThreshold } protocolConfigs { __typename protocolVersion } validatorSet { __typename activeValidators { __typename ...RPC_VALIDATOR_FIELDS } inactivePoolsSize pendingActiveValidatorsSize validatorCandidatesSize pendingRemovals totalStake } epoch { __typename epochId startTimestamp endTimestamp } } }"#,
      fragments: [RPC_CREDENTIAL_FIELDS.self, RPC_VALIDATOR_FIELDS.self]
    ))

  public init() {}

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("latestSuiSystemState", LatestSuiSystemState.self),
    ] }

    public var latestSuiSystemState: LatestSuiSystemState { __data["latestSuiSystemState"] }

    /// LatestSuiSystemState
    ///
    /// Parent Type: `SuiSystemStateSummary`
    public struct LatestSuiSystemState: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.SuiSystemStateSummary }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("referenceGasPrice", SuiKit.BigIntApollo?.self),
        .field("safeMode", SafeMode?.self),
        .field("stakeSubsidy", StakeSubsidy?.self),
        .field("storageFund", StorageFund?.self),
        .field("systemStateVersion", SuiKit.BigIntApollo?.self),
        .field("systemParameters", SystemParameters?.self),
        .field("protocolConfigs", ProtocolConfigs?.self),
        .field("validatorSet", ValidatorSet?.self),
        .field("epoch", Epoch?.self),
      ] }

      /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for.
      public var referenceGasPrice: SuiKit.BigIntApollo? { __data["referenceGasPrice"] }
      /// Information about whether last epoch change used safe mode, which happens if the full epoch
      /// change logic fails for some reason.
      public var safeMode: SafeMode? { __data["safeMode"] }
      /// Parameters related to subsiding staking rewards
      public var stakeSubsidy: StakeSubsidy? { __data["stakeSubsidy"] }
      /// SUI set aside to account for objects stored on-chain, at the start of the epoch.
      public var storageFund: StorageFund? { __data["storageFund"] }
      /// The value of the `version` field of `0x5`, the `0x3::sui::SuiSystemState` object.  This
      /// version changes whenever the fields contained in the system state object (held in a dynamic
      /// field attached to `0x5`) change.
      public var systemStateVersion: SuiKit.BigIntApollo? { __data["systemStateVersion"] }
      /// Details of the system that are decided during genesis.
      public var systemParameters: SystemParameters? { __data["systemParameters"] }
      /// Configuration for how the chain operates that can change from epoch to epoch (due to a
      /// protocol version upgrade).
      public var protocolConfigs: ProtocolConfigs? { __data["protocolConfigs"] }
      /// Details of the currently active validators and pending changes to that set.
      public var validatorSet: ValidatorSet? { __data["validatorSet"] }
      /// The epoch for which this is the system state.
      public var epoch: Epoch? { __data["epoch"] }

      /// LatestSuiSystemState.SafeMode
      ///
      /// Parent Type: `SafeMode`
      public struct SafeMode: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.SafeMode }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("enabled", Bool?.self),
          .field("gasSummary", GasSummary?.self),
        ] }

        /// Whether safe mode was used for the last epoch change.  The system will retry a full epoch
        /// change on every epoch boundary and automatically reset this flag if so.
        public var enabled: Bool? { __data["enabled"] }
        /// Accumulated fees for computation and cost that have not been added to the various reward
        /// pools, because the full epoch change did not happen.
        public var gasSummary: GasSummary? { __data["gasSummary"] }

        /// LatestSuiSystemState.SafeMode.GasSummary
        ///
        /// Parent Type: `GasCostSummary`
        public struct GasSummary: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.GasCostSummary }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("computationCost", SuiKit.BigIntApollo?.self),
            .field("nonRefundableStorageFee", SuiKit.BigIntApollo?.self),
            .field("storageCost", SuiKit.BigIntApollo?.self),
            .field("storageRebate", SuiKit.BigIntApollo?.self),
          ] }

          public var computationCost: SuiKit.BigIntApollo? { __data["computationCost"] }
          public var nonRefundableStorageFee: SuiKit.BigIntApollo? { __data["nonRefundableStorageFee"] }
          public var storageCost: SuiKit.BigIntApollo? { __data["storageCost"] }
          public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
        }
      }

      /// LatestSuiSystemState.StakeSubsidy
      ///
      /// Parent Type: `StakeSubsidy`
      public struct StakeSubsidy: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.StakeSubsidy }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("balance", SuiKit.BigIntApollo?.self),
          .field("currentDistributionAmount", SuiKit.BigIntApollo?.self),
          .field("decreaseRate", Int?.self),
          .field("distributionCounter", Int?.self),
          .field("periodLength", Int?.self),
        ] }

        /// SUI set aside for stake subsidies -- reduces over time as stake subsidies are paid out over
        /// time.
        public var balance: SuiKit.BigIntApollo? { __data["balance"] }
        /// Amount of stake subsidy deducted from the balance per distribution -- decays over time.
        public var currentDistributionAmount: SuiKit.BigIntApollo? { __data["currentDistributionAmount"] }
        /// Percentage of the current distribution amount to deduct at the end of the current subsidy
        /// period, expressed in basis points.
        public var decreaseRate: Int? { __data["decreaseRate"] }
        /// Number of times stake subsidies have been distributed subsidies are distributed with other
        /// staking rewards, at the end of the epoch.
        public var distributionCounter: Int? { __data["distributionCounter"] }
        /// Maximum number of stake subsidy distributions that occur with the same distribution amount
        /// (before the amount is reduced).
        public var periodLength: Int? { __data["periodLength"] }
      }

      /// LatestSuiSystemState.StorageFund
      ///
      /// Parent Type: `StorageFund`
      public struct StorageFund: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.StorageFund }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nonRefundableBalance", SuiKit.BigIntApollo?.self),
          .field("totalObjectStorageRebates", SuiKit.BigIntApollo?.self),
        ] }

        /// The portion of the storage fund that will never be refunded through storage rebates.
        ///
        /// The system maintains an invariant that the sum of all storage fees into the storage fund is
        /// equal to the sum of of all storage rebates out, the total storage rebates remaining, and the
        /// non-refundable balance.
        public var nonRefundableBalance: SuiKit.BigIntApollo? { __data["nonRefundableBalance"] }
        /// Sum of storage rebates of live objects on chain.
        public var totalObjectStorageRebates: SuiKit.BigIntApollo? { __data["totalObjectStorageRebates"] }
      }

      /// LatestSuiSystemState.SystemParameters
      ///
      /// Parent Type: `SystemParameters`
      public struct SystemParameters: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.SystemParameters }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("minValidatorCount", Int?.self),
          .field("maxValidatorCount", Int?.self),
          .field("minValidatorJoiningStake", SuiKit.BigIntApollo?.self),
          .field("durationMs", SuiKit.BigIntApollo?.self),
          .field("validatorLowStakeThreshold", SuiKit.BigIntApollo?.self),
          .field("validatorLowStakeGracePeriod", SuiKit.BigIntApollo?.self),
          .field("validatorVeryLowStakeThreshold", SuiKit.BigIntApollo?.self),
        ] }

        /// The minimum number of active validators that the system supports.
        public var minValidatorCount: Int? { __data["minValidatorCount"] }
        /// The maximum number of active validators that the system supports.
        public var maxValidatorCount: Int? { __data["maxValidatorCount"] }
        /// Minimum stake needed to become a new validator.
        public var minValidatorJoiningStake: SuiKit.BigIntApollo? { __data["minValidatorJoiningStake"] }
        /// Target duration of an epoch, in milliseconds.
        public var durationMs: SuiKit.BigIntApollo? { __data["durationMs"] }
        /// Validators with stake below this threshold will enter the grace period (see
        /// `validatorLowStakeGracePeriod`), after which they are removed from the active validator set.
        public var validatorLowStakeThreshold: SuiKit.BigIntApollo? { __data["validatorLowStakeThreshold"] }
        /// The number of epochs that a validator has to recover from having less than
        /// `validatorLowStakeThreshold` stake.
        public var validatorLowStakeGracePeriod: SuiKit.BigIntApollo? { __data["validatorLowStakeGracePeriod"] }
        /// Validators with stake below this threshold will be removed from the the active validator set
        /// at the next epoch boundary, without a grace period.
        public var validatorVeryLowStakeThreshold: SuiKit.BigIntApollo? { __data["validatorVeryLowStakeThreshold"] }
      }

      /// LatestSuiSystemState.ProtocolConfigs
      ///
      /// Parent Type: `ProtocolConfigs`
      public struct ProtocolConfigs: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ProtocolConfigs }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("protocolVersion", Int.self),
        ] }

        /// The protocol is not required to change on every epoch boundary, so the protocol version
        /// tracks which change to the protocol these configs are from.
        public var protocolVersion: Int { __data["protocolVersion"] }
      }

      /// LatestSuiSystemState.ValidatorSet
      ///
      /// Parent Type: `ValidatorSet`
      public struct ValidatorSet: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ValidatorSet }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("activeValidators", [ActiveValidator]?.self),
          .field("inactivePoolsSize", Int?.self),
          .field("pendingActiveValidatorsSize", Int?.self),
          .field("validatorCandidatesSize", Int?.self),
          .field("pendingRemovals", [Int]?.self),
          .field("totalStake", SuiKit.BigIntApollo?.self),
        ] }

        /// The current list of active validators.
        public var activeValidators: [ActiveValidator]? { __data["activeValidators"] }
        public var inactivePoolsSize: Int? { __data["inactivePoolsSize"] }
        public var pendingActiveValidatorsSize: Int? { __data["pendingActiveValidatorsSize"] }
        public var validatorCandidatesSize: Int? { __data["validatorCandidatesSize"] }
        /// Validators that are pending removal from the active validator set, expressed as indices in
        /// to `activeValidators`.
        public var pendingRemovals: [Int]? { __data["pendingRemovals"] }
        /// Total amount of stake for all active validators at the beginning of the epoch.
        public var totalStake: SuiKit.BigIntApollo? { __data["totalStake"] }

        /// LatestSuiSystemState.ValidatorSet.ActiveValidator
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

          /// LatestSuiSystemState.ValidatorSet.ActiveValidator.Credentials
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

          /// LatestSuiSystemState.ValidatorSet.ActiveValidator.NextEpochCredentials
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

      /// LatestSuiSystemState.Epoch
      ///
      /// Parent Type: `Epoch`
      public struct Epoch: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Epoch }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("epochId", Int.self),
          .field("startTimestamp", SuiKit.DateTimeApollo?.self),
          .field("endTimestamp", SuiKit.DateTimeApollo?.self),
        ] }

        /// The epoch's id as a sequence number that starts at 0 and it is incremented by one at every epoch change
        public var epochId: Int { __data["epochId"] }
        /// The epoch's starting timestamp
        public var startTimestamp: SuiKit.DateTimeApollo? { __data["startTimestamp"] }
        /// The epoch's ending timestamp
        public var endTimestamp: SuiKit.DateTimeApollo? { __data["endTimestamp"] }
      }
    }
  }
}
