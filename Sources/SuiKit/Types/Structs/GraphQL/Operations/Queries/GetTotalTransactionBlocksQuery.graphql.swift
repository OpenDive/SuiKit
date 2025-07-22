// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetTotalTransactionBlocksQuery: GraphQLQuery {
  public static let operationName: String = "getTotalTransactionBlocks"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getTotalTransactionBlocks { checkpoint { __typename networkTotalTransactions } }"#
    ))

  public init() {}

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("checkpoint", Checkpoint?.self)
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
        .field("networkTotalTransactions", SuiKit.UInt53Apollo?.self)
      ] }

      /// The total number of transaction blocks in the network by the end of this checkpoint.
      public var networkTotalTransactions: SuiKit.UInt53Apollo? { __data["networkTotalTransactions"] }
    }
  }
}
