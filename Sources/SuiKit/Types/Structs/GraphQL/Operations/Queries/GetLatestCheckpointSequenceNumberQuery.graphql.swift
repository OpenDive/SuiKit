// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetLatestCheckpointSequenceNumberQuery: GraphQLQuery {
  public static let operationName: String = "getLatestCheckpointSequenceNumber"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getLatestCheckpointSequenceNumber { checkpoint { __typename sequenceNumber } }"#
    ))

  public init() {}

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("checkpoint", Checkpoint?.self),
    ] }

    public var checkpoint: Checkpoint? { __data["checkpoint"] }

    /// Checkpoint
    ///
    /// Parent Type: `Checkpoint`
    public struct Checkpoint: SuiKit.SelectionSet {
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
