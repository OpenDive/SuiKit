// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ResolveNameServiceNamesQuery: GraphQLQuery {
  public static let operationName: String = "resolveNameServiceNames"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query resolveNameServiceNames($address: SuiAddress!) { address(address: $address) { __typename defaultNameServiceName } }"#
    ))

  public var address: SuiAddressApollo

  public init(address: SuiAddressApollo) {
    self.address = address
  }

  public var __variables: Variables? { ["address": address] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self, arguments: ["address": .variable("address")]),
    ] }

    public var address: Address? { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Address }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("defaultNameServiceName", String?.self),
      ] }

      public var defaultNameServiceName: String? { __data["defaultNameServiceName"] }
    }
  }
}
