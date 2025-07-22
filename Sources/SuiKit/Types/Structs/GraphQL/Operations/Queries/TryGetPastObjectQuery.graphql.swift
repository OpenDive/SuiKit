// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TryGetPastObjectQuery: GraphQLQuery {
  public static let operationName: String = "tryGetPastObject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query tryGetPastObject($id: SuiAddress!, $version: UInt53, $showBcs: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showContent: Boolean = false, $showDisplay: Boolean = false, $showType: Boolean = false, $showStorageRebate: Boolean = false) { current: object(address: $id) { __typename address version } object(address: $id, version: $version) { __typename ...RPC_OBJECT_FIELDS } }"#,
      fragments: [RPC_OBJECT_FIELDS.self, RPC_OBJECT_OWNER_FIELDS.self]
    ))

  public var id: SuiAddressApollo
  public var version: GraphQLNullable<UInt53Apollo>
  public var showBcs: GraphQLNullable<Bool>
  public var showOwner: GraphQLNullable<Bool>
  public var showPreviousTransaction: GraphQLNullable<Bool>
  public var showContent: GraphQLNullable<Bool>
  public var showDisplay: GraphQLNullable<Bool>
  public var showType: GraphQLNullable<Bool>
  public var showStorageRebate: GraphQLNullable<Bool>

  public init(
    id: SuiAddressApollo,
    version: GraphQLNullable<UInt53Apollo>,
    showBcs: GraphQLNullable<Bool> = false,
    showOwner: GraphQLNullable<Bool> = false,
    showPreviousTransaction: GraphQLNullable<Bool> = false,
    showContent: GraphQLNullable<Bool> = false,
    showDisplay: GraphQLNullable<Bool> = false,
    showType: GraphQLNullable<Bool> = false,
    showStorageRebate: GraphQLNullable<Bool> = false
  ) {
    self.id = id
    self.version = version
    self.showBcs = showBcs
    self.showOwner = showOwner
    self.showPreviousTransaction = showPreviousTransaction
    self.showContent = showContent
    self.showDisplay = showDisplay
    self.showType = showType
    self.showStorageRebate = showStorageRebate
  }

  public var __variables: Variables? { [
    "id": id,
    "version": version,
    "showBcs": showBcs,
    "showOwner": showOwner,
    "showPreviousTransaction": showPreviousTransaction,
    "showContent": showContent,
    "showDisplay": showDisplay,
    "showType": showType,
    "showStorageRebate": showStorageRebate
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("object", alias: "current", Current?.self, arguments: ["address": .variable("id")]),
      .field("object", Object?.self, arguments: [
        "address": .variable("id"),
        "version": .variable("version")
      ])
    ] }

    /// The object corresponding to the given address at the (optionally) given version.
    /// When no version is given, the latest version is returned.
    public var current: Current? { __data["current"] }
    /// The object corresponding to the given address at the (optionally) given version.
    /// When no version is given, the latest version is returned.
    public var object: Object? { __data["object"] }

    /// Current
    ///
    /// Parent Type: `Object`
    public struct Current: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("address", SuiKit.SuiAddressApollo.self),
        .field("version", SuiKit.UInt53Apollo.self)
      ] }

      public var address: SuiKit.SuiAddressApollo { __data["address"] }
      public var version: SuiKit.UInt53Apollo { __data["version"] }
    }

    /// Object
    ///
    /// Parent Type: `Object`
    public struct Object: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(RPC_OBJECT_FIELDS.self)
      ] }

      public var objectId: SuiKit.SuiAddressApollo { __data["objectId"] }
      public var version: SuiKit.UInt53Apollo { __data["version"] }
      /// Attempts to convert the object into a MoveObject
      public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
      /// The owner type of this object: Immutable, Shared, Parent, Address
      /// Immutable and Shared Objects do not have owners.
      public var owner: Owner? { __data["owner"] }
      /// The transaction block that created this version of the object.
      public var previousTransactionBlock: PreviousTransactionBlock? { __data["previousTransactionBlock"] }
      /// The amount of SUI we would rebate if this object gets deleted or mutated. This number is
      /// recalculated based on the present storage gas price.
      public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
      /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
      public var digest: String? { __data["digest"] }
      /// The set of named templates defined on-chain for the type of this object, to be handled
      /// off-chain. The server substitutes data from the object into these templates to generate a
      /// display string per template.
      public var display: [Display]? { __data["display"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var rPC_OBJECT_FIELDS: RPC_OBJECT_FIELDS { _toFragment() }
      }

      public typealias AsMoveObject = RPC_OBJECT_FIELDS.AsMoveObject

      public typealias Owner = RPC_OBJECT_FIELDS.Owner

      public typealias PreviousTransactionBlock = RPC_OBJECT_FIELDS.PreviousTransactionBlock

      public typealias Display = RPC_OBJECT_FIELDS.Display
    }
  }
}
