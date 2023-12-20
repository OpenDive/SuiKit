// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_VALIDATOR_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_VALIDATOR_FIELDS on Validator { __typename atRisk commissionRate exchangeRatesSize exchangeRates { __typename contents { __typename json } asObject { __typename location } } description gasPrice imageUrl name credentials { __typename ...RPC_CREDENTIAL_FIELDS } nextEpochCommissionRate nextEpochGasPrice nextEpochCredentials { __typename ...RPC_CREDENTIAL_FIELDS } nextEpochStake nextEpochCommissionRate operationCap { __typename asObject { __typename location } } pendingPoolTokenWithdraw pendingStake pendingTotalSuiWithdraw poolTokenBalance projectUrl rewardsPool stakingPool { __typename asObject { __typename location } } stakingPoolActivationEpoch stakingPoolSuiBalance address { __typename location } votingPower reportRecords }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Validator }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("atRisk", Int?.self),
    .field("commissionRate", Int?.self),
    .field("exchangeRatesSize", Int?.self),
    .field("exchangeRates", ExchangeRates?.self),
    .field("description", String?.self),
    .field("gasPrice", SuiKit.BigIntApollo?.self),
    .field("imageUrl", String?.self),
    .field("name", String?.self),
    .field("credentials", Credentials?.self),
    .field("nextEpochCommissionRate", Int?.self),
    .field("nextEpochGasPrice", SuiKit.BigIntApollo?.self),
    .field("nextEpochCredentials", NextEpochCredentials?.self),
    .field("nextEpochStake", SuiKit.BigIntApollo?.self),
    .field("operationCap", OperationCap?.self),
    .field("pendingPoolTokenWithdraw", SuiKit.BigIntApollo?.self),
    .field("pendingStake", SuiKit.BigIntApollo?.self),
    .field("pendingTotalSuiWithdraw", SuiKit.BigIntApollo?.self),
    .field("poolTokenBalance", SuiKit.BigIntApollo?.self),
    .field("projectUrl", String?.self),
    .field("rewardsPool", SuiKit.BigIntApollo?.self),
    .field("stakingPool", StakingPool?.self),
    .field("stakingPoolActivationEpoch", Int?.self),
    .field("stakingPoolSuiBalance", SuiKit.BigIntApollo?.self),
    .field("address", Address.self),
    .field("votingPower", Int?.self),
    .field("reportRecords", [SuiKit.SuiAddressApollo]?.self),
  ] }

  public var atRisk: Int? { __data["atRisk"] }
  public var commissionRate: Int? { __data["commissionRate"] }
  public var exchangeRatesSize: Int? { __data["exchangeRatesSize"] }
  public var exchangeRates: ExchangeRates? { __data["exchangeRates"] }
  public var description: String? { __data["description"] }
  public var gasPrice: SuiKit.BigIntApollo? { __data["gasPrice"] }
  public var imageUrl: String? { __data["imageUrl"] }
  public var name: String? { __data["name"] }
  public var credentials: Credentials? { __data["credentials"] }
  public var nextEpochCommissionRate: Int? { __data["nextEpochCommissionRate"] }
  public var nextEpochGasPrice: SuiKit.BigIntApollo? { __data["nextEpochGasPrice"] }
  public var nextEpochCredentials: NextEpochCredentials? { __data["nextEpochCredentials"] }
  public var nextEpochStake: SuiKit.BigIntApollo? { __data["nextEpochStake"] }
  public var operationCap: OperationCap? { __data["operationCap"] }
  public var pendingPoolTokenWithdraw: SuiKit.BigIntApollo? { __data["pendingPoolTokenWithdraw"] }
  public var pendingStake: SuiKit.BigIntApollo? { __data["pendingStake"] }
  public var pendingTotalSuiWithdraw: SuiKit.BigIntApollo? { __data["pendingTotalSuiWithdraw"] }
  public var poolTokenBalance: SuiKit.BigIntApollo? { __data["poolTokenBalance"] }
  public var projectUrl: String? { __data["projectUrl"] }
  public var rewardsPool: SuiKit.BigIntApollo? { __data["rewardsPool"] }
  public var stakingPool: StakingPool? { __data["stakingPool"] }
  public var stakingPoolActivationEpoch: Int? { __data["stakingPoolActivationEpoch"] }
  public var stakingPoolSuiBalance: SuiKit.BigIntApollo? { __data["stakingPoolSuiBalance"] }
  public var address: Address { __data["address"] }
  public var votingPower: Int? { __data["votingPower"] }
  public var reportRecords: [SuiKit.SuiAddressApollo]? { __data["reportRecords"] }

  /// ExchangeRates
  ///
  /// Parent Type: `MoveObject`
  public struct ExchangeRates: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("contents", Contents?.self),
      .field("asObject", AsObject.self),
    ] }

    /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
    /// provides the flat representation of the type signature, and the bcs of the corresponding
    /// data
    public var contents: Contents? { __data["contents"] }
    /// Attempts to convert the Move object into an Object
    /// This provides additional information such as version and digest on the top-level
    public var asObject: AsObject { __data["asObject"] }

    /// ExchangeRates.Contents
    ///
    /// Parent Type: `MoveValue`
    public struct Contents: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("json", SuiKit.JSONApollo.self),
      ] }

      /// Representation of a Move value in JSON, where:
      ///
      /// - Addresses and UIDs are represented in canonical form, as JSON strings.
      /// - Bools are represented by JSON boolean literals.
      /// - u8, u16, and u32 are represented as JSON numbers.
      /// - u64, u128, and u256 are represented as JSON strings.
      /// - Vectors are represented by JSON arrays.
      /// - Structs are represented by JSON objects.
      /// - Empty optional values are represented by `null`.
      ///
      /// This form is offered as a less verbose convenience in cases where the layout of the type is
      /// known by the client.
      public var json: SuiKit.JSONApollo { __data["json"] }
    }

    /// ExchangeRates.AsObject
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

  /// Credentials
  ///
  /// Parent Type: `ValidatorCredentials`
  public struct Credentials: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ValidatorCredentials }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(RPC_CREDENTIAL_FIELDS.self),
    ] }

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

  /// NextEpochCredentials
  ///
  /// Parent Type: `ValidatorCredentials`
  public struct NextEpochCredentials: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.ValidatorCredentials }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(RPC_CREDENTIAL_FIELDS.self),
    ] }

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

  /// OperationCap
  ///
  /// Parent Type: `MoveObject`
  public struct OperationCap: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("asObject", AsObject.self),
    ] }

    /// Attempts to convert the Move object into an Object
    /// This provides additional information such as version and digest on the top-level
    public var asObject: AsObject { __data["asObject"] }

    /// OperationCap.AsObject
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

  /// StakingPool
  ///
  /// Parent Type: `MoveObject`
  public struct StakingPool: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("asObject", AsObject.self),
    ] }

    /// Attempts to convert the Move object into an Object
    /// This provides additional information such as version and digest on the top-level
    public var asObject: AsObject { __data["asObject"] }

    /// StakingPool.AsObject
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

  /// Address
  ///
  /// Parent Type: `Address`
  public struct Address: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("location", SuiKit.SuiAddressApollo.self),
    ] }

    public var location: SuiKit.SuiAddressApollo { __data["location"] }
  }
}
