// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetChainIdentifierQuery: GraphQLQuery {
  public static let operationName: String = "getChainIdentifier"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getChainIdentifier { chainIdentifier }"#
    ))

  public init() {}

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("chainIdentifier", String.self)
    ] }

    /// First four bytes of the network's genesis checkpoint digest (uniquely identifies the
    /// network).
    public var chainIdentifier: String { __data["chainIdentifier"] }
  }
}
