// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCoinsQuery: GraphQLQuery {
  public static let operationName: String = "getCoins"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCoins($owner: SuiAddress!, $first: Int, $cursor: String, $type: String = "0x2::sui::SUI") { address(address: $owner) { __typename address coinConnection(first: $first, after: $cursor, type: $type) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename balance asMoveObject { __typename contents { __typename type { __typename repr } } asObject { __typename coinObjectId: address version digest previousTransactionBlock { __typename digest } } } } } } }"#
    ))

  public var owner: SuiAddressApollo
  public var first: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>
  public var type: GraphQLNullable<String>

  public init(
    owner: SuiAddressApollo,
    first: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>,
    type: GraphQLNullable<String> = "0x2::sui::SUI"
  ) {
    self.owner = owner
    self.first = first
    self.cursor = cursor
    self.type = type
  }

  public var __variables: Variables? { [
    "owner": owner,
    "first": first,
    "cursor": cursor,
    "type": type
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address?.self, arguments: ["address": .variable("owner")]),
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
        .field("address", SuiKit.SuiAddressApollo.self),
        .field("coinConnection", CoinConnection?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("cursor"),
          "type": .variable("type")
        ]),
      ] }

      public var address: SuiKit.SuiAddressApollo { __data["address"] }
      /// The coin objects for the given address.
      /// The type field is a string of the inner type of the coin
      /// by which to filter (e.g., 0x2::sui::SUI).
      public var coinConnection: CoinConnection? { __data["coinConnection"] }

      /// Address.CoinConnection
      ///
      /// Parent Type: `CoinConnection`
      public struct CoinConnection: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.CoinConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.CoinConnection.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Address.CoinConnection.Node
        ///
        /// Parent Type: `Coin`
        public struct Node: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Coin }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("balance", SuiKit.BigIntApollo?.self),
            .field("asMoveObject", AsMoveObject.self),
          ] }

          /// Balance of the coin object
          public var balance: SuiKit.BigIntApollo? { __data["balance"] }
          /// Convert the coin object into a Move object
          public var asMoveObject: AsMoveObject { __data["asMoveObject"] }

          /// Address.CoinConnection.Node.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("contents", Contents?.self),
              .field("asObject", AsObject.self),
            ] }

            /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }
            /// Attempts to convert the Move object into an Object
            /// This provides additional information such as version and digest on the top-level
            public var asObject: AsObject { __data["asObject"] }

            /// Address.CoinConnection.Node.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("type", Type_SelectionSet.self),
              ] }

              public var type: Type_SelectionSet { __data["type"] }

              /// Address.CoinConnection.Node.AsMoveObject.Contents.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self),
                ] }

                /// Flat representation of the type signature, as a displayable string.
                public var repr: String { __data["repr"] }
              }
            }

            /// Address.CoinConnection.Node.AsMoveObject.AsObject
            ///
            /// Parent Type: `Object`
            public struct AsObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("address", alias: "coinObjectId", SuiKit.SuiAddressApollo.self),
                .field("version", Int.self),
                .field("digest", String.self),
                .field("previousTransactionBlock", PreviousTransactionBlock?.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var coinObjectId: SuiKit.SuiAddressApollo { __data["coinObjectId"] }
              public var version: Int { __data["version"] }
              /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
              public var digest: String { __data["digest"] }
              /// The transaction block that created this version of the object.
              public var previousTransactionBlock: PreviousTransactionBlock? { __data["previousTransactionBlock"] }

              /// Address.CoinConnection.Node.AsMoveObject.AsObject.PreviousTransactionBlock
              ///
              /// Parent Type: `TransactionBlock`
              public struct PreviousTransactionBlock: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("digest", String.self),
                ] }

                /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
                /// This serves as a unique id for the block on chain.
                public var digest: String { __data["digest"] }
              }
            }
          }
        }
      }
    }
  }
}
