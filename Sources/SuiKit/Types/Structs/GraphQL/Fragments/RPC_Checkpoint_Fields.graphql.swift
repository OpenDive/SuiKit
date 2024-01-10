// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_Checkpoint_Fields: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_Checkpoint_Fields on Checkpoint { __typename digest endOfEpoch { __typename newCommittee { __typename authorityName stakeUnit } nextProtocolVersion } epoch { __typename epochId } rollingGasSummary { __typename computationCost storageCost storageRebate nonRefundableStorageFee } networkTotalTransactions previousCheckpointDigest sequenceNumber timestamp transactionBlockConnection { __typename nodes { __typename digest } } validatorSignature }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Checkpoint }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("digest", String.self),
    .field("endOfEpoch", EndOfEpoch?.self),
    .field("epoch", Epoch?.self),
    .field("rollingGasSummary", RollingGasSummary?.self),
    .field("networkTotalTransactions", Int?.self),
    .field("previousCheckpointDigest", String?.self),
    .field("sequenceNumber", Int.self),
    .field("timestamp", SuiKit.DateTimeApollo?.self),
    .field("transactionBlockConnection", TransactionBlockConnection?.self),
    .field("validatorSignature", SuiKit.Base64Apollo?.self),
  ] }

  /// A 32-byte hash that uniquely identifies the checkpoint contents, encoded in Base58.
  /// This hash can be used to verify checkpoint contents by checking signatures against the committee,
  /// Hashing contents to match digest, and checking that the previous checkpoint digest matches.
  public var digest: String { __data["digest"] }
  /// End of epoch data is only available on the final checkpoint of an epoch.
  /// This field provides information on the new committee and protocol version for the next epoch.
  public var endOfEpoch: EndOfEpoch? { __data["endOfEpoch"] }
  public var epoch: Epoch? { __data["epoch"] }
  /// The computation and storage cost, storage rebate, and nonrefundable storage fee accumulated
  /// during this epoch, up to and including this checkpoint.
  /// These values increase monotonically across checkpoints in the same epoch.
  public var rollingGasSummary: RollingGasSummary? { __data["rollingGasSummary"] }
  /// Tracks the total number of transaction blocks in the network at the time of the checkpoint.
  public var networkTotalTransactions: Int? { __data["networkTotalTransactions"] }
  /// The digest of the checkpoint at the previous sequence number.
  public var previousCheckpointDigest: String? { __data["previousCheckpointDigest"] }
  /// This checkpoint's position in the total order of finalised checkpoints, agreed upon by consensus.
  public var sequenceNumber: Int { __data["sequenceNumber"] }
  /// The timestamp at which the checkpoint is agreed to have happened according to consensus.
  /// Transactions that access time in this checkpoint will observe this timestamp.
  public var timestamp: SuiKit.DateTimeApollo? { __data["timestamp"] }
  public var transactionBlockConnection: TransactionBlockConnection? { __data["transactionBlockConnection"] }
  /// This is an aggregation of signatures from a quorum of validators for the checkpoint proposal.
  public var validatorSignature: SuiKit.Base64Apollo? { __data["validatorSignature"] }

  /// EndOfEpoch
  ///
  /// Parent Type: `EndOfEpochData`
  public struct EndOfEpoch: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.EndOfEpochData }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("newCommittee", [NewCommittee]?.self),
      .field("nextProtocolVersion", Int?.self),
    ] }

    public var newCommittee: [NewCommittee]? { __data["newCommittee"] }
    public var nextProtocolVersion: Int? { __data["nextProtocolVersion"] }

    /// EndOfEpoch.NewCommittee
    ///
    /// Parent Type: `CommitteeMember`
    public struct NewCommittee: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.CommitteeMember }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("authorityName", String?.self),
        .field("stakeUnit", Int?.self),
      ] }

      public var authorityName: String? { __data["authorityName"] }
      public var stakeUnit: Int? { __data["stakeUnit"] }
    }
  }

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
    ] }

    /// The epoch's id as a sequence number that starts at 0 and it is incremented by one at every epoch change
    public var epochId: Int { __data["epochId"] }
  }

  /// RollingGasSummary
  ///
  /// Parent Type: `GasCostSummary`
  public struct RollingGasSummary: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.GasCostSummary }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("computationCost", SuiKit.BigIntApollo?.self),
      .field("storageCost", SuiKit.BigIntApollo?.self),
      .field("storageRebate", SuiKit.BigIntApollo?.self),
      .field("nonRefundableStorageFee", SuiKit.BigIntApollo?.self),
    ] }

    public var computationCost: SuiKit.BigIntApollo? { __data["computationCost"] }
    public var storageCost: SuiKit.BigIntApollo? { __data["storageCost"] }
    public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
    public var nonRefundableStorageFee: SuiKit.BigIntApollo? { __data["nonRefundableStorageFee"] }
  }

  /// TransactionBlockConnection
  ///
  /// Parent Type: `TransactionBlockConnection`
  public struct TransactionBlockConnection: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlockConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("nodes", [Node].self),
    ] }

    /// A list of nodes.
    public var nodes: [Node] { __data["nodes"] }

    /// TransactionBlockConnection.Node
    ///
    /// Parent Type: `TransactionBlock`
    public struct Node: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("digest", String.self),
      ] }

      /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
      /// This serves as a unique id for the block on chain
      public var digest: String { __data["digest"] }
    }
  }
}