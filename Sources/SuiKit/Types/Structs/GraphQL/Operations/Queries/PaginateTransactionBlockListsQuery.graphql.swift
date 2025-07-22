// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PaginateTransactionBlockListsQuery: GraphQLQuery {
  public static let operationName: String = "paginateTransactionBlockLists"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query paginateTransactionBlockLists($digest: String!, $hasMoreEvents: Boolean!, $hasMoreBalanceChanges: Boolean!, $hasMoreObjectChanges: Boolean!, $afterEvents: String, $afterBalanceChanges: String, $afterObjectChanges: String) { transactionBlock(digest: $digest) { __typename ...PAGINATE_TRANSACTION_LISTS } }"#,
      fragments: [PAGINATE_TRANSACTION_LISTS.self, RPC_EVENTS_FIELDS.self]
    ))

  public var digest: String
  public var hasMoreEvents: Bool
  public var hasMoreBalanceChanges: Bool
  public var hasMoreObjectChanges: Bool
  public var afterEvents: GraphQLNullable<String>
  public var afterBalanceChanges: GraphQLNullable<String>
  public var afterObjectChanges: GraphQLNullable<String>

  public init(
    digest: String,
    hasMoreEvents: Bool,
    hasMoreBalanceChanges: Bool,
    hasMoreObjectChanges: Bool,
    afterEvents: GraphQLNullable<String>,
    afterBalanceChanges: GraphQLNullable<String>,
    afterObjectChanges: GraphQLNullable<String>
  ) {
    self.digest = digest
    self.hasMoreEvents = hasMoreEvents
    self.hasMoreBalanceChanges = hasMoreBalanceChanges
    self.hasMoreObjectChanges = hasMoreObjectChanges
    self.afterEvents = afterEvents
    self.afterBalanceChanges = afterBalanceChanges
    self.afterObjectChanges = afterObjectChanges
  }

  public var __variables: Variables? { [
    "digest": digest,
    "hasMoreEvents": hasMoreEvents,
    "hasMoreBalanceChanges": hasMoreBalanceChanges,
    "hasMoreObjectChanges": hasMoreObjectChanges,
    "afterEvents": afterEvents,
    "afterBalanceChanges": afterBalanceChanges,
    "afterObjectChanges": afterObjectChanges
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("transactionBlock", TransactionBlock?.self, arguments: ["digest": .variable("digest")])
    ] }

    /// Fetch a transaction block by its transaction digest.
    public var transactionBlock: TransactionBlock? { __data["transactionBlock"] }

    /// TransactionBlock
    ///
    /// Parent Type: `TransactionBlock`
    public struct TransactionBlock: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(PAGINATE_TRANSACTION_LISTS.self)
      ] }

      /// The effects field captures the results to the chain of executing this transaction.
      public var effects: Effects? { __data["effects"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var pAGINATE_TRANSACTION_LISTS: PAGINATE_TRANSACTION_LISTS { _toFragment() }
      }

      public typealias Effects = PAGINATE_TRANSACTION_LISTS.Effects
    }
  }
}
