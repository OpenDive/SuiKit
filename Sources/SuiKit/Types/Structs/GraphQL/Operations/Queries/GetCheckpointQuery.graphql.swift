// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCheckpointQuery: GraphQLQuery {
  public static let operationName: String = "getCheckpoint"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCheckpoint($id: CheckpointId) { checkpoint(id: $id) { __typename ...RPC_Checkpoint_Fields } }"#,
      fragments: [RPC_Checkpoint_Fields.self]
    ))

  public var id: GraphQLNullable<CheckpointId>

  public init(id: GraphQLNullable<CheckpointId>) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("checkpoint", Checkpoint?.self, arguments: ["id": .variable("id")])
    ] }

    /// Fetch checkpoint information by sequence number or digest (defaults to the latest available
    /// checkpoint).
    public var checkpoint: Checkpoint? { __data["checkpoint"] }

    /// Checkpoint
    ///
    /// Parent Type: `Checkpoint`
    public struct Checkpoint: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Checkpoint }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(RPC_Checkpoint_Fields.self)
      ] }

      /// A 32-byte hash that uniquely identifies the checkpoint contents, encoded in Base58. This
      /// hash can be used to verify checkpoint contents by checking signatures against the committee,
      /// Hashing contents to match digest, and checking that the previous checkpoint digest matches.
      public var digest: String { __data["digest"] }
      /// The epoch this checkpoint is part of.
      public var epoch: Epoch? { __data["epoch"] }
      /// The computation cost, storage cost, storage rebate, and non-refundable storage fee
      /// accumulated during this epoch, up to and including this checkpoint. These values increase
      /// monotonically across checkpoints in the same epoch, and reset on epoch boundaries.
      public var rollingGasSummary: RollingGasSummary? { __data["rollingGasSummary"] }
      /// The total number of transaction blocks in the network by the end of this checkpoint.
      public var networkTotalTransactions: SuiKit.UInt53Apollo? { __data["networkTotalTransactions"] }
      /// The digest of the checkpoint at the previous sequence number.
      public var previousCheckpointDigest: String? { __data["previousCheckpointDigest"] }
      /// This checkpoint's position in the total order of finalized checkpoints, agreed upon by
      /// consensus.
      public var sequenceNumber: SuiKit.UInt53Apollo { __data["sequenceNumber"] }
      /// The timestamp at which the checkpoint is agreed to have happened according to consensus.
      /// Transactions that access time in this checkpoint will observe this timestamp.
      public var timestamp: SuiKit.DateTimeApollo { __data["timestamp"] }
      /// This is an aggregation of signatures from a quorum of validators for the checkpoint
      /// proposal.
      public var validatorSignatures: SuiKit.Base64Apollo { __data["validatorSignatures"] }
      /// Transactions in this checkpoint.
      ///
      /// `scanLimit` restricts the number of candidate transactions scanned when gathering a page of
      /// results. It is required for queries that apply more than two complex filters (on function,
      /// kind, sender, recipient, input object, changed object, or ids), and can be at most
      /// `serviceConfig.maxScanLimit`.
      ///
      /// When the scan limit is reached the page will be returned even if it has fewer than `first`
      /// results when paginating forward (`last` when paginating backwards). If there are more
      /// transactions to scan, `pageInfo.hasNextPage` (or `pageInfo.hasPreviousPage`) will be set to
      /// `true`, and `PageInfo.endCursor` (or `PageInfo.startCursor`) will be set to the last
      /// transaction that was scanned as opposed to the last (or first) transaction in the page.
      ///
      /// Requesting the next (or previous) page after this cursor will resume the search, scanning
      /// the next `scanLimit` many transactions in the direction of pagination, and so on until all
      /// transactions in the scanning range have been visited.
      ///
      /// By default, the scanning range consists of all transactions in this checkpoint.
      public var transactionBlocks: TransactionBlocks { __data["transactionBlocks"] }
      /// Transactions in this checkpoint.
      ///
      /// `scanLimit` restricts the number of candidate transactions scanned when gathering a page of
      /// results. It is required for queries that apply more than two complex filters (on function,
      /// kind, sender, recipient, input object, changed object, or ids), and can be at most
      /// `serviceConfig.maxScanLimit`.
      ///
      /// When the scan limit is reached the page will be returned even if it has fewer than `first`
      /// results when paginating forward (`last` when paginating backwards). If there are more
      /// transactions to scan, `pageInfo.hasNextPage` (or `pageInfo.hasPreviousPage`) will be set to
      /// `true`, and `PageInfo.endCursor` (or `PageInfo.startCursor`) will be set to the last
      /// transaction that was scanned as opposed to the last (or first) transaction in the page.
      ///
      /// Requesting the next (or previous) page after this cursor will resume the search, scanning
      /// the next `scanLimit` many transactions in the direction of pagination, and so on until all
      /// transactions in the scanning range have been visited.
      ///
      /// By default, the scanning range consists of all transactions in this checkpoint.
      public var endOfEpoch: EndOfEpoch { __data["endOfEpoch"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_Checkpoint_Fields: RPC_Checkpoint_Fields { _toFragment() }
      }

      public typealias Epoch = RPC_Checkpoint_Fields.Epoch

      public typealias RollingGasSummary = RPC_Checkpoint_Fields.RollingGasSummary

      public typealias TransactionBlocks = RPC_Checkpoint_Fields.TransactionBlocks

      public typealias EndOfEpoch = RPC_Checkpoint_Fields.EndOfEpoch
    }
  }
}
