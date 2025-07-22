// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetLatestSuiSystemStateQuery: GraphQLQuery {
  public static let operationName: String = "getLatestSuiSystemState"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getLatestSuiSystemState { epoch { __typename epochId startTimestamp endTimestamp referenceGasPrice safeMode { __typename enabled gasSummary { __typename computationCost nonRefundableStorageFee storageCost storageRebate } } systemStakeSubsidy { __typename balance currentDistributionAmount decreaseRate distributionCounter periodLength } storageFund { __typename nonRefundableBalance totalObjectStorageRebates } systemStateVersion systemParameters { __typename minValidatorCount maxValidatorCount minValidatorJoiningStake durationMs validatorLowStakeThreshold validatorLowStakeGracePeriod validatorVeryLowStakeThreshold stakeSubsidyStartEpoch } protocolConfigs { __typename protocolVersion } validatorSet { __typename activeValidators { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_VALIDATOR_FIELDS } } inactivePoolsSize pendingActiveValidatorsSize stakingPoolMappingsSize validatorCandidatesSize pendingRemovals totalStake stakingPoolMappingsId pendingActiveValidatorsId validatorCandidatesId inactivePoolsId } } }"#,
      fragments: [RPC_CREDENTIAL_FIELDS.self, RPC_VALIDATOR_FIELDS.self]
    ))

  public init() {}

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("epoch", Epoch?.self)
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
        .field("startTimestamp", SuiKit.DateTimeApollo.self),
        .field("endTimestamp", SuiKit.DateTimeApollo?.self),
        .field("referenceGasPrice", SuiKit.BigIntApollo?.self),
        .field("safeMode", SafeMode?.self),
        .field("systemStakeSubsidy", SystemStakeSubsidy?.self),
        .field("storageFund", StorageFund?.self),
        .field("systemStateVersion", SuiKit.UInt53Apollo?.self),
        .field("systemParameters", SystemParameters?.self),
        .field("protocolConfigs", ProtocolConfigs.self),
        .field("validatorSet", ValidatorSet?.self)
      ] }

      /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
      public var epochId: SuiKit.UInt53Apollo { __data["epochId"] }
      /// The epoch's starting timestamp.
      public var startTimestamp: SuiKit.DateTimeApollo { __data["startTimestamp"] }
      /// The epoch's ending timestamp.
      public var endTimestamp: SuiKit.DateTimeApollo? { __data["endTimestamp"] }
      /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for.
      public var referenceGasPrice: SuiKit.BigIntApollo? { __data["referenceGasPrice"] }
      /// Information about whether this epoch was started in safe mode, which happens if the full epoch
      /// change logic fails for some reason.
      public var safeMode: SafeMode? { __data["safeMode"] }
      /// Parameters related to the subsidy that supplements staking rewards
      public var systemStakeSubsidy: SystemStakeSubsidy? { __data["systemStakeSubsidy"] }
      /// SUI set aside to account for objects stored on-chain, at the start of the epoch.
      /// This is also used for storage rebates.
      public var storageFund: StorageFund? { __data["storageFund"] }
      /// The value of the `version` field of `0x5`, the `0x3::sui::SuiSystemState` object.  This
      /// version changes whenever the fields contained in the system state object (held in a dynamic
      /// field attached to `0x5`) change.
      public var systemStateVersion: SuiKit.UInt53Apollo? { __data["systemStateVersion"] }
      /// Details of the system that are decided during genesis.
      public var systemParameters: SystemParameters? { __data["systemParameters"] }
      /// The epoch's corresponding protocol configuration, including the feature flags and the
      /// configuration options.
      public var protocolConfigs: ProtocolConfigs { __data["protocolConfigs"] }
      /// Validator related properties, including the active validators.
      public var validatorSet: ValidatorSet? { __data["validatorSet"] }

      /// Epoch.SafeMode
      ///
      /// Parent Type: `SafeMode`
      public struct SafeMode: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.SafeMode }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("enabled", Bool?.self),
          .field("gasSummary", GasSummary?.self)
        ] }

        /// Whether safe mode was used for the last epoch change.  The system will retry a full epoch
        /// change on every epoch boundary and automatically reset this flag if so.
        public var enabled: Bool? { __data["enabled"] }
        /// Accumulated fees for computation and cost that have not been added to the various reward
        /// pools, because the full epoch change did not happen.
        public var gasSummary: GasSummary? { __data["gasSummary"] }

        /// Epoch.SafeMode.GasSummary
        ///
        /// Parent Type: `GasCostSummary`
        public struct GasSummary: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.GasCostSummary }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("computationCost", SuiKit.BigIntApollo?.self),
            .field("nonRefundableStorageFee", SuiKit.BigIntApollo?.self),
            .field("storageCost", SuiKit.BigIntApollo?.self),
            .field("storageRebate", SuiKit.BigIntApollo?.self)
          ] }

          /// Gas paid for executing this transaction (in MIST).
          public var computationCost: SuiKit.BigIntApollo? { __data["computationCost"] }
          /// Part of storage cost that is not reclaimed when data created by this transaction is cleaned
          /// up (in MIST).
          public var nonRefundableStorageFee: SuiKit.BigIntApollo? { __data["nonRefundableStorageFee"] }
          /// Gas paid for the data stored on-chain by this transaction (in MIST).
          public var storageCost: SuiKit.BigIntApollo? { __data["storageCost"] }
          /// Part of storage cost that can be reclaimed by cleaning up data created by this transaction
          /// (when objects are deleted or an object is modified, which is treated as a deletion followed
          /// by a creation) (in MIST).
          public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
        }
      }

      /// Epoch.SystemStakeSubsidy
      ///
      /// Parent Type: `StakeSubsidy`
      public struct SystemStakeSubsidy: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.StakeSubsidy }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("balance", SuiKit.BigIntApollo?.self),
          .field("currentDistributionAmount", SuiKit.BigIntApollo?.self),
          .field("decreaseRate", Int?.self),
          .field("distributionCounter", Int?.self),
          .field("periodLength", Int?.self)
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

      /// Epoch.StorageFund
      ///
      /// Parent Type: `StorageFund`
      public struct StorageFund: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.StorageFund }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nonRefundableBalance", SuiKit.BigIntApollo?.self),
          .field("totalObjectStorageRebates", SuiKit.BigIntApollo?.self)
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

      /// Epoch.SystemParameters
      ///
      /// Parent Type: `SystemParameters`
      public struct SystemParameters: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.SystemParameters }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("minValidatorCount", Int?.self),
          .field("maxValidatorCount", Int?.self),
          .field("minValidatorJoiningStake", SuiKit.BigIntApollo?.self),
          .field("durationMs", SuiKit.BigIntApollo?.self),
          .field("validatorLowStakeThreshold", SuiKit.BigIntApollo?.self),
          .field("validatorLowStakeGracePeriod", SuiKit.BigIntApollo?.self),
          .field("validatorVeryLowStakeThreshold", SuiKit.BigIntApollo?.self),
          .field("stakeSubsidyStartEpoch", SuiKit.UInt53Apollo?.self)
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
        /// Validators with stake below this threshold will be removed from the active validator set
        /// at the next epoch boundary, without a grace period.
        public var validatorVeryLowStakeThreshold: SuiKit.BigIntApollo? { __data["validatorVeryLowStakeThreshold"] }
        /// The epoch at which stake subsidies start being paid out.
        public var stakeSubsidyStartEpoch: SuiKit.UInt53Apollo? { __data["stakeSubsidyStartEpoch"] }
      }

      /// Epoch.ProtocolConfigs
      ///
      /// Parent Type: `ProtocolConfigs`
      public struct ProtocolConfigs: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ProtocolConfigs }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("protocolVersion", SuiKit.UInt53Apollo.self)
        ] }

        /// The protocol is not required to change on every epoch boundary, so the protocol version
        /// tracks which change to the protocol these configs are from.
        public var protocolVersion: SuiKit.UInt53Apollo { __data["protocolVersion"] }
      }

      /// Epoch.ValidatorSet
      ///
      /// Parent Type: `ValidatorSet`
      public struct ValidatorSet: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ValidatorSet }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("activeValidators", ActiveValidators.self),
          .field("inactivePoolsSize", Int?.self),
          .field("pendingActiveValidatorsSize", Int?.self),
          .field("stakingPoolMappingsSize", Int?.self),
          .field("validatorCandidatesSize", Int?.self),
          .field("pendingRemovals", [Int]?.self),
          .field("totalStake", SuiKit.BigIntApollo?.self),
          .field("stakingPoolMappingsId", SuiKit.SuiAddressApollo?.self),
          .field("pendingActiveValidatorsId", SuiKit.SuiAddressApollo?.self),
          .field("validatorCandidatesId", SuiKit.SuiAddressApollo?.self),
          .field("inactivePoolsId", SuiKit.SuiAddressApollo?.self)
        ] }

        /// The current set of active validators.
        public var activeValidators: ActiveValidators { __data["activeValidators"] }
        /// Size of the inactive pools `Table`.
        public var inactivePoolsSize: Int? { __data["inactivePoolsSize"] }
        /// Size of the pending active validators table.
        public var pendingActiveValidatorsSize: Int? { __data["pendingActiveValidatorsSize"] }
        /// Size of the stake pool mappings `Table`.
        public var stakingPoolMappingsSize: Int? { __data["stakingPoolMappingsSize"] }
        /// Size of the validator candidates `Table`.
        public var validatorCandidatesSize: Int? { __data["validatorCandidatesSize"] }
        /// Validators that are pending removal from the active validator set, expressed as indices in
        /// to `activeValidators`.
        public var pendingRemovals: [Int]? { __data["pendingRemovals"] }
        /// Total amount of stake for all active validators at the beginning of the epoch.
        public var totalStake: SuiKit.BigIntApollo? { __data["totalStake"] }
        /// Object ID of the `Table` storing the mapping from staking pool ids to the addresses
        /// of the corresponding validators. This is needed because a validator's address
        /// can potentially change but the object ID of its pool will not.
        public var stakingPoolMappingsId: SuiKit.SuiAddressApollo? { __data["stakingPoolMappingsId"] }
        /// Object ID of the wrapped object `TableVec` storing the pending active validators.
        public var pendingActiveValidatorsId: SuiKit.SuiAddressApollo? { __data["pendingActiveValidatorsId"] }
        /// Object ID of the `Table` storing the validator candidates.
        public var validatorCandidatesId: SuiKit.SuiAddressApollo? { __data["validatorCandidatesId"] }
        /// Object ID of the `Table` storing the inactive staking pools.
        public var inactivePoolsId: SuiKit.SuiAddressApollo? { __data["inactivePoolsId"] }

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
              .fragment(RPC_VALIDATOR_FIELDS.self)
            ] }

            /// The number of epochs for which this validator has been below the
            /// low stake threshold.
            public var atRisk: SuiKit.UInt53Apollo? { __data["atRisk"] }
            /// The fee charged by the validator for staking services.
            public var commissionRate: Int? { __data["commissionRate"] }
            /// Number of exchange rates in the table.
            public var exchangeRatesSize: SuiKit.UInt53Apollo? { __data["exchangeRatesSize"] }
            /// The validator's current exchange object. The exchange rate is used to determine
            /// the amount of SUI tokens that each past SUI staker can withdraw in the future.
            @available(*, deprecated, message: "The exchange object is a wrapped object. Access its dynamic fields through the `exchangeRatesTable` query.")
            public var exchangeRates: ExchangeRates? { __data["exchangeRates"] }
            /// Validator's description.
            public var description: String? { __data["description"] }
            /// The reference gas price for this epoch.
            public var gasPrice: SuiKit.BigIntApollo? { __data["gasPrice"] }
            /// Validator's url containing their custom image.
            public var imageUrl: String? { __data["imageUrl"] }
            /// Validator's name.
            public var name: String? { __data["name"] }
            /// Validator's set of credentials such as public keys, network addresses and others.
            public var credentials: Credentials? { __data["credentials"] }
            /// The proposed next epoch fee for the validator's staking services.
            public var nextEpochCommissionRate: Int? { __data["nextEpochCommissionRate"] }
            /// The validator's gas price quote for the next epoch.
            public var nextEpochGasPrice: SuiKit.BigIntApollo? { __data["nextEpochGasPrice"] }
            /// Validator's set of credentials for the next epoch.
            public var nextEpochCredentials: NextEpochCredentials? { __data["nextEpochCredentials"] }
            /// The total number of SUI tokens in this pool plus
            /// the pending stake amount for this epoch.
            public var nextEpochStake: SuiKit.BigIntApollo? { __data["nextEpochStake"] }
            /// The validator's current valid `Cap` object. Validators can delegate
            /// the operation ability to another address. The address holding this `Cap` object
            /// can then update the reference gas price and tallying rule on behalf of the validator.
            public var operationCap: OperationCap? { __data["operationCap"] }
            /// Pending pool token withdrawn during the current epoch, emptied at epoch boundaries.
            public var pendingPoolTokenWithdraw: SuiKit.BigIntApollo? { __data["pendingPoolTokenWithdraw"] }
            /// Pending stake amount for this epoch.
            public var pendingStake: SuiKit.BigIntApollo? { __data["pendingStake"] }
            /// Pending stake withdrawn during the current epoch, emptied at epoch boundaries.
            public var pendingTotalSuiWithdraw: SuiKit.BigIntApollo? { __data["pendingTotalSuiWithdraw"] }
            /// Total number of pool tokens issued by the pool.
            public var poolTokenBalance: SuiKit.BigIntApollo? { __data["poolTokenBalance"] }
            /// Validator's homepage URL.
            public var projectUrl: String? { __data["projectUrl"] }
            /// The epoch stake rewards will be added here at the end of each epoch.
            public var rewardsPool: SuiKit.BigIntApollo? { __data["rewardsPool"] }
            /// The validator's current staking pool object, used to track the amount of stake
            /// and to compound staking rewards.
            @available(*, deprecated, message: "The staking pool is a wrapped object. Access its fields directly on the `Validator` type.")
            public var stakingPool: StakingPool? { __data["stakingPool"] }
            /// The epoch at which this pool became active.
            public var stakingPoolActivationEpoch: SuiKit.UInt53Apollo? { __data["stakingPoolActivationEpoch"] }
            /// The total number of SUI tokens in this pool.
            public var stakingPoolSuiBalance: SuiKit.BigIntApollo? { __data["stakingPoolSuiBalance"] }
            /// The validator's address.
            public var address: Address { __data["address"] }
            /// The voting power of this validator in basis points (e.g., 100 = 1% voting power).
            public var votingPower: Int? { __data["votingPower"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var rPC_VALIDATOR_FIELDS: RPC_VALIDATOR_FIELDS { _toFragment() }
            }

            public typealias ExchangeRates = RPC_VALIDATOR_FIELDS.ExchangeRates

            public typealias Credentials = RPC_VALIDATOR_FIELDS.Credentials

            public typealias NextEpochCredentials = RPC_VALIDATOR_FIELDS.NextEpochCredentials

            public typealias OperationCap = RPC_VALIDATOR_FIELDS.OperationCap

            public typealias StakingPool = RPC_VALIDATOR_FIELDS.StakingPool

            public typealias Address = RPC_VALIDATOR_FIELDS.Address
          }
        }
      }
    }
  }
}
