// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ResolveNameServiceAddressQuery: GraphQLQuery {
  public static let operationName: String = "resolveNameServiceAddress"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query resolveNameServiceAddress($name: String!) { resolveNameServiceAddress(name: $name) { __typename location } }"#
    ))

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var __variables: Variables? { ["name": name] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("resolveNameServiceAddress", ResolveNameServiceAddress?.self, arguments: ["name": .variable("name")]),
    ] }

    /// Resolves the owner address of the provided domain name
    public var resolveNameServiceAddress: ResolveNameServiceAddress? { __data["resolveNameServiceAddress"] }

    /// ResolveNameServiceAddress
    ///
    /// Parent Type: `Address`
    public struct ResolveNameServiceAddress: SuiKit.SelectionSet {
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
}
