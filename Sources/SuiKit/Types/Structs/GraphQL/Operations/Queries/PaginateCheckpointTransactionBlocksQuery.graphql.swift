// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PaginateCheckpointTransactionBlocksQuery: GraphQLQuery {
  public static let operationName: String = "paginateCheckpointTransactionBlocks"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query paginateCheckpointTransactionBlocks($id: CheckpointId, $after: String) { checkpoint(id: $id) { __typename transactionBlocks(after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename digest } } } }"#
    ))

  public var id: GraphQLNullable<CheckpointId>
  public var after: GraphQLNullable<String>

  public init(
    id: GraphQLNullable<CheckpointId>,
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
        .field("transactionBlocks", TransactionBlocks.self, arguments: ["after": .variable("after")])
      ] }

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

      /// Checkpoint.TransactionBlocks
      ///
      /// Parent Type: `TransactionBlockConnection`
      public struct TransactionBlocks: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlockConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self)
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Checkpoint.TransactionBlocks.PageInfo
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

        /// Checkpoint.TransactionBlocks.Node
        ///
        /// Parent Type: `TransactionBlock`
        public struct Node: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("digest", String?.self)
          ] }

          /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
          /// This serves as a unique id for the block on chain.
          public var digest: String? { __data["digest"] }
        }
      }
    }
  }
}
