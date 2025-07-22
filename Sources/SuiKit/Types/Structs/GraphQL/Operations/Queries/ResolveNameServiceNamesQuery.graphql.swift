// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ResolveNameServiceNamesQuery: GraphQLQuery {
  public static let operationName: String = "resolveNameServiceNames"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query resolveNameServiceNames($address: SuiAddress!, $limit: Int, $cursor: String) { address(address: $address) { __typename suinsRegistrations(first: $limit, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename domain } } } }"#
    ))

  public var address: SuiAddressApollo
  public var limit: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>

  public init(
    address: SuiAddressApollo,
    limit: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>
  ) {
    self.address = address
    self.limit = limit
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "address": address,
    "limit": limit,
    "cursor": cursor
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self, arguments: ["address": .variable("address")])
    ] }

    /// Look-up an Account by its SuiAddressApollo.
    public var address: Address? { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Address }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("suinsRegistrations", SuinsRegistrations.self, arguments: [
          "first": .variable("limit"),
          "after": .variable("cursor")
        ])
      ] }

      /// The SuinsRegistration NFTs owned by this address. These grant the owner the capability to
      /// manage the associated domain.
      public var suinsRegistrations: SuinsRegistrations { __data["suinsRegistrations"] }

      /// Address.SuinsRegistrations
      ///
      /// Parent Type: `SuinsRegistrationConnection`
      public struct SuinsRegistrations: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.SuinsRegistrationConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self)
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.SuinsRegistrations.PageInfo
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

        /// Address.SuinsRegistrations.Node
        ///
        /// Parent Type: `SuinsRegistration`
        public struct Node: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.SuinsRegistration }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("domain", String.self)
          ] }

          /// Domain name of the SuinsRegistration object
          public var domain: String { __data["domain"] }
        }
      }
    }
  }
}
