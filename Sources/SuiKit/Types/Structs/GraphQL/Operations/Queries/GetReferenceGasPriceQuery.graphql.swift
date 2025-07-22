// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetReferenceGasPriceQuery: GraphQLQuery {
  public static let operationName: String = "getReferenceGasPrice"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getReferenceGasPrice { epoch { __typename referenceGasPrice } }"#
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
        .field("referenceGasPrice", SuiKit.BigIntApollo?.self)
      ] }

      /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for.
      public var referenceGasPrice: SuiKit.BigIntApollo? { __data["referenceGasPrice"] }
    }
  }
}
