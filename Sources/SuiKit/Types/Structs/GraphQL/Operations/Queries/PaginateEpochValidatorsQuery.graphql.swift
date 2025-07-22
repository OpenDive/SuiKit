// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PaginateEpochValidatorsQuery: GraphQLQuery {
  public static let operationName: String = "paginateEpochValidators"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query paginateEpochValidators($id: UInt53!, $after: String) { epoch(id: $id) { __typename validatorSet { __typename activeValidators(after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_VALIDATOR_FIELDS } } } } }"#,
      fragments: [RPC_CREDENTIAL_FIELDS.self, RPC_VALIDATOR_FIELDS.self]
    ))

  public var id: UInt53Apollo
  public var after: GraphQLNullable<String>

  public init(
    id: UInt53Apollo,
    after: GraphQLNullable<String>
  ) {
    self.id = id
    self.after = after
  }

  public var __variables: Variables? { [
    "id": id,
    "after": after
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("epoch", Epoch?.self, arguments: ["id": .variable("id")])
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
        .field("validatorSet", ValidatorSet?.self)
      ] }

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
