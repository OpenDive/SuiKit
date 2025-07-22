// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDynamicFieldObjectQuery: GraphQLQuery {
  public static let operationName: String = "getDynamicFieldObject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getDynamicFieldObject($parentId: SuiAddress!, $name: DynamicFieldName!) { owner(address: $parentId) { __typename dynamicObjectField(name: $name) { __typename value { __typename ... on MoveObject { owner { __typename ... on Parent { parent { __typename asObject { __typename address digest version storageRebate owner { __typename ... on Parent { parent { __typename address } } } previousTransactionBlock { __typename digest } asMoveObject { __typename contents { __typename data type { __typename repr layout } } hasPublicTransfer } } } } } } } } } }"#
    ))

  public var parentId: SuiAddressApollo
  public var name: DynamicFieldNameApollo

  public init(
    parentId: SuiAddressApollo,
    name: DynamicFieldNameApollo
  ) {
    self.parentId = parentId
    self.name = name
  }

  public var __variables: Variables? { [
    "parentId": parentId,
    "name": name
  ] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("owner", Owner?.self, arguments: ["address": .variable("parentId")])
    ] }

    /// Look up an Owner by its SuiAddressApollo.
    ///
    /// `rootVersion` represents the version of the root object in some nested chain of dynamic
    /// fields. It allows consistent historical queries for the case of wrapped objects, which don't
    /// have a version. For example, if querying the dynamic field of a table wrapped in a parent
    /// object, passing the parent object's version here will ensure we get the dynamic field's
    /// state at the moment that parent's version was created.
    ///
    /// Also, if this Owner is an object itself, `rootVersion` will be used to bound its version
    /// from above when querying `Owner.asObject`. This can be used, for example, to get the
    /// contents of a dynamic object field when its parent was at `rootVersion`.
    ///
    /// If `rootVersion` is omitted, dynamic fields will be from a consistent snapshot of the Sui
    /// state at the latest checkpoint known to the GraphQL RPC. Similarly, `Owner.asObject` will
    /// return the object's version at the latest checkpoint.
    public var owner: Owner? { __data["owner"] }

    /// Owner
    ///
    /// Parent Type: `Owner`
    public struct Owner: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Owner }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("dynamicObjectField", DynamicObjectField?.self, arguments: ["name": .variable("name")])
      ] }

      /// Access a dynamic object field on an object using its name. Names are arbitrary Move values
      /// whose type have `copy`, `drop`, and `store`, and are specified using their type, and their
      /// BCS contents, Base64 encoded. The value of a dynamic object field can also be accessed
      /// off-chain directly via its address (e.g. using `Query.object`).
      ///
      /// This field exists as a convenience when accessing a dynamic field on a wrapped object.
      public var dynamicObjectField: DynamicObjectField? { __data["dynamicObjectField"] }

      /// Owner.DynamicObjectField
      ///
      /// Parent Type: `DynamicField`
      public struct DynamicObjectField: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DynamicField }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("value", Value?.self)
        ] }

        /// The returned dynamic field is an object if its return type is `MoveObject`,
        /// in which case it is also accessible off-chain via its address. Its contents
        /// will be from the latest version that is at most equal to its parent object's
        /// version
        public var value: Value? { __data["value"] }

        /// Owner.DynamicObjectField.Value
        ///
        /// Parent Type: `DynamicFieldValue`
        public struct Value: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Unions.DynamicFieldValue }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsMoveObject.self)
          ] }

          public var asMoveObject: AsMoveObject? { _asInlineFragment() }

          /// Owner.DynamicObjectField.Value.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = GetDynamicFieldObjectQuery.Data.Owner.DynamicObjectField.Value
            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("owner", Owner?.self)
            ] }

            /// The owner type of this object: Immutable, Shared, Parent, Address
            public var owner: Owner? { __data["owner"] }

            /// Owner.DynamicObjectField.Value.AsMoveObject.Owner
            ///
            /// Parent Type: `ObjectOwner`
            public struct Owner: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Unions.ObjectOwner }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .inlineFragment(AsParent.self)
              ] }

              public var asParent: AsParent? { _asInlineFragment() }

              /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent
              ///
              /// Parent Type: `Parent`
              public struct AsParent: SuiKit.InlineFragment {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public typealias RootEntityType = GetDynamicFieldObjectQuery.Data.Owner.DynamicObjectField.Value.AsMoveObject.Owner
                public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Parent }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("parent", Parent?.self)
                ] }

                public var parent: Parent? { __data["parent"] }

                /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent
                ///
                /// Parent Type: `Owner`
                public struct Parent: SuiKit.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Owner }
                  public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("asObject", AsObject?.self)
                  ] }

                  public var asObject: AsObject? { __data["asObject"] }

                  /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject
                  ///
                  /// Parent Type: `Object`
                  public struct AsObject: SuiKit.SelectionSet {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
                    public static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("address", SuiKit.SuiAddressApollo.self),
                      .field("digest", String?.self),
                      .field("version", SuiKit.UInt53Apollo.self),
                      .field("storageRebate", SuiKit.BigIntApollo?.self),
                      .field("owner", Owner?.self),
                      .field("previousTransactionBlock", PreviousTransactionBlock?.self),
                      .field("asMoveObject", AsMoveObject?.self)
                    ] }

                    public var address: SuiKit.SuiAddressApollo { __data["address"] }
                    /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
                    public var digest: String? { __data["digest"] }
                    public var version: SuiKit.UInt53Apollo { __data["version"] }
                    /// The amount of SUI we would rebate if this object gets deleted or mutated. This number is
                    /// recalculated based on the present storage gas price.
                    public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
                    /// The owner type of this object: Immutable, Shared, Parent, Address
                    /// Immutable and Shared Objects do not have owners.
                    public var owner: Owner? { __data["owner"] }
                    /// The transaction block that created this version of the object.
                    public var previousTransactionBlock: PreviousTransactionBlock? { __data["previousTransactionBlock"] }
                    /// Attempts to convert the object into a MoveObject
                    public var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

                    /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.Owner
                    ///
                    /// Parent Type: `ObjectOwner`
                    public struct Owner: SuiKit.SelectionSet {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Unions.ObjectOwner }
                      public static var __selections: [ApolloAPI.Selection] { [
                        .field("__typename", String.self),
                        .inlineFragment(AsParent.self)
                      ] }

                      public var asParent: AsParent? { _asInlineFragment() }

                      /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.Owner.AsParent
                      ///
                      /// Parent Type: `Parent`
                      public struct AsParent: SuiKit.InlineFragment {
                        public let __data: DataDict
                        public init(_dataDict: DataDict) { __data = _dataDict }

                        public typealias RootEntityType = GetDynamicFieldObjectQuery.Data.Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.Owner
                        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Parent }
                        public static var __selections: [ApolloAPI.Selection] { [
                          .field("parent", Parent?.self)
                        ] }

                        public var parent: Parent? { __data["parent"] }

                        /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.Owner.AsParent.Parent
                        ///
                        /// Parent Type: `Owner`
                        public struct Parent: SuiKit.SelectionSet {
                          public let __data: DataDict
                          public init(_dataDict: DataDict) { __data = _dataDict }

                          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Owner }
                          public static var __selections: [ApolloAPI.Selection] { [
                            .field("__typename", String.self),
                            .field("address", SuiKit.SuiAddressApollo.self)
                          ] }

                          public var address: SuiKit.SuiAddressApollo { __data["address"] }
                        }
                      }
                    }

                    /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.PreviousTransactionBlock
                    ///
                    /// Parent Type: `TransactionBlock`
                    public struct PreviousTransactionBlock: SuiKit.SelectionSet {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.TransactionBlock }
                      public static var __selections: [ApolloAPI.Selection] { [
                        .field("__typename", String.self),
                        .field("digest", String?.self)
                      ] }

                      /// A 32-byte hash that uniquely identifies the transaction block contents, encoded in Base58.
                      /// This serves as a unique id for the block on chain.
                      public var digest: String? { __data["digest"] }
                    }

                    /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.AsMoveObject
                    ///
                    /// Parent Type: `MoveObject`
                    public struct AsMoveObject: SuiKit.SelectionSet {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
                      public static var __selections: [ApolloAPI.Selection] { [
                        .field("__typename", String.self),
                        .field("contents", Contents?.self),
                        .field("hasPublicTransfer", Bool.self)
                      ] }

                      /// Displays the contents of the Move object in a JSON string and through GraphQL types. Also
                      /// provides the flat representation of the type signature, and the BCS of the corresponding
                      /// data.
                      public var contents: Contents? { __data["contents"] }
                      /// Determines whether a transaction can transfer this object, using the TransferObjects
                      /// transaction command or `sui::transfer::public_transfer`, both of which require the object to
                      /// have the `key` and `store` abilities.
                      public var hasPublicTransfer: Bool { __data["hasPublicTransfer"] }

                      /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.AsMoveObject.Contents
                      ///
                      /// Parent Type: `MoveValue`
                      public struct Contents: SuiKit.SelectionSet {
                        public let __data: DataDict
                        public init(_dataDict: DataDict) { __data = _dataDict }

                        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
                        public static var __selections: [ApolloAPI.Selection] { [
                          .field("__typename", String.self),
                          .field("data", SuiKit.MoveDataApollo.self),
                          .field("type", Type_SelectionSet.self)
                        ] }

                        /// Structured contents of a Move value.
                        public var data: SuiKit.MoveDataApollo { __data["data"] }
                        /// The value's Move type.
                        public var type: Type_SelectionSet { __data["type"] }

                        /// Owner.DynamicObjectField.Value.AsMoveObject.Owner.AsParent.Parent.AsObject.AsMoveObject.Contents.Type_SelectionSet
                        ///
                        /// Parent Type: `MoveType`
                        public struct Type_SelectionSet: SuiKit.SelectionSet {
                          public let __data: DataDict
                          public init(_dataDict: DataDict) { __data = _dataDict }

                          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                          public static var __selections: [ApolloAPI.Selection] { [
                            .field("__typename", String.self),
                            .field("repr", String.self),
                            .field("layout", SuiKit.MoveTypeLayoutApollo?.self)
                          ] }

                          /// Flat representation of the type signature, as a displayable string.
                          public var repr: String { __data["repr"] }
                          /// Structured representation of the "shape" of values that match this type. May return no
                          /// layout if the type is invalid.
                          public var layout: SuiKit.MoveTypeLayoutApollo? { __data["layout"] }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
