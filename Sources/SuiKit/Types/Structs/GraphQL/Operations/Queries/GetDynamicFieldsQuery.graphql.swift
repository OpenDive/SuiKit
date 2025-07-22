// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDynamicFieldsQuery: GraphQLQuery {
  public static let operationName: String = "getDynamicFields"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getDynamicFields($parentId: SuiAddress!, $first: Int, $cursor: String) { owner(address: $parentId) { __typename dynamicFields(first: $first, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename name { __typename bcs json type { __typename layout repr } } value { __typename ... on MoveValue { json type { __typename repr } } ... on MoveObject { contents { __typename type { __typename repr } json } address digest version } } } } } }"#
    ))

  public var parentId: SuiAddressApollo
  public var first: GraphQLNullable<Int>
  public var cursor: GraphQLNullable<String>

  public init(
    parentId: SuiAddressApollo,
    first: GraphQLNullable<Int>,
    cursor: GraphQLNullable<String>
  ) {
    self.parentId = parentId
    self.first = first
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "parentId": parentId,
    "first": first,
    "cursor": cursor
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
        .field("dynamicFields", DynamicFields.self, arguments: [
          "first": .variable("first"),
          "after": .variable("cursor")
        ])
      ] }

      /// The dynamic fields and dynamic object fields on an object.
      ///
      /// This field exists as a convenience when accessing a dynamic field on a wrapped object.
      public var dynamicFields: DynamicFields { __data["dynamicFields"] }

      /// Owner.DynamicFields
      ///
      /// Parent Type: `DynamicFieldConnection`
      public struct DynamicFields: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DynamicFieldConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self)
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Owner.DynamicFields.PageInfo
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

        /// Owner.DynamicFields.Node
        ///
        /// Parent Type: `DynamicField`
        public struct Node: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.DynamicField }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", Name?.self),
            .field("value", Value?.self)
          ] }

          /// The string type, data, and serialized value of the DynamicField's 'name' field.
          /// This field is used to uniquely identify a child of the parent object.
          public var name: Name? { __data["name"] }
          /// The returned dynamic field is an object if its return type is `MoveObject`,
          /// in which case it is also accessible off-chain via its address. Its contents
          /// will be from the latest version that is at most equal to its parent object's
          /// version
          public var value: Value? { __data["value"] }

          /// Owner.DynamicFields.Node.Name
          ///
          /// Parent Type: `MoveValue`
          public struct Name: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("bcs", SuiKit.Base64Apollo.self),
              .field("json", SuiKit.JSONApollo.self),
              .field("type", Type_SelectionSet.self)
            ] }

            /// The BCS representation of this value, Base64 encoded.
            public var bcs: SuiKit.Base64Apollo { __data["bcs"] }
            /// Representation of a Move value in JSON, where:
            ///
            /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
            /// - Bools are represented by JSON boolean literals.
            /// - u8, u16, and u32 are represented as JSON numbers.
            /// - u64, u128, and u256 are represented as JSON strings.
            /// - Vectors are represented by JSON arrays.
            /// - Structs are represented by JSON objects.
            /// - Empty optional values are represented by `null`.
            ///
            /// This form is offered as a less verbose convenience in cases where the layout of the type is
            /// known by the client.
            public var json: SuiKit.JSONApollo { __data["json"] }
            /// The value's Move type.
            public var type: Type_SelectionSet { __data["type"] }

            /// Owner.DynamicFields.Node.Name.Type_SelectionSet
            ///
            /// Parent Type: `MoveType`
            public struct Type_SelectionSet: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveType }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("layout", SuiKit.MoveTypeLayoutApollo?.self),
                .field("repr", String.self)
              ] }

              /// Structured representation of the "shape" of values that match this type. May return no
              /// layout if the type is invalid.
              public var layout: SuiKit.MoveTypeLayoutApollo? { __data["layout"] }
              /// Flat representation of the type signature, as a displayable string.
              public var repr: String { __data["repr"] }
            }
          }

          /// Owner.DynamicFields.Node.Value
          ///
          /// Parent Type: `DynamicFieldValue`
          public struct Value: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { SuiKit.Unions.DynamicFieldValue }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .inlineFragment(AsMoveValue.self),
              .inlineFragment(AsMoveObject.self)
            ] }

            public var asMoveValue: AsMoveValue? { _asInlineFragment() }
            public var asMoveObject: AsMoveObject? { _asInlineFragment() }

            /// Owner.DynamicFields.Node.Value.AsMoveValue
            ///
            /// Parent Type: `MoveValue`
            public struct AsMoveValue: SuiKit.InlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetDynamicFieldsQuery.Data.Owner.DynamicFields.Node.Value
              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("json", SuiKit.JSONApollo.self),
                .field("type", Type_SelectionSet.self)
              ] }

              /// Representation of a Move value in JSON, where:
              ///
              /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
              /// - Bools are represented by JSON boolean literals.
              /// - u8, u16, and u32 are represented as JSON numbers.
              /// - u64, u128, and u256 are represented as JSON strings.
              /// - Vectors are represented by JSON arrays.
              /// - Structs are represented by JSON objects.
              /// - Empty optional values are represented by `null`.
              ///
              /// This form is offered as a less verbose convenience in cases where the layout of the type is
              /// known by the client.
              public var json: SuiKit.JSONApollo { __data["json"] }
              /// The value's Move type.
              public var type: Type_SelectionSet { __data["type"] }

              /// Owner.DynamicFields.Node.Value.AsMoveValue.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self)
                ] }

                /// Flat representation of the type signature, as a displayable string.
                public var repr: String { __data["repr"] }
              }
            }

            /// Owner.DynamicFields.Node.Value.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            public struct AsMoveObject: SuiKit.InlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetDynamicFieldsQuery.Data.Owner.DynamicFields.Node.Value
              public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("contents", Contents?.self),
                .field("address", SuiKit.SuiAddressApollo.self),
                .field("digest", String?.self),
                .field("version", SuiKit.UInt53Apollo.self)
              ] }

              /// Displays the contents of the Move object in a JSON string and through GraphQL types. Also
              /// provides the flat representation of the type signature, and the BCS of the corresponding
              /// data.
              public var contents: Contents? { __data["contents"] }
              public var address: SuiKit.SuiAddressApollo { __data["address"] }
              /// 32-byte hash that identifies the object's contents, encoded as a Base58 string.
              public var digest: String? { __data["digest"] }
              public var version: SuiKit.UInt53Apollo { __data["version"] }

              /// Owner.DynamicFields.Node.Value.AsMoveObject.Contents
              ///
              /// Parent Type: `MoveValue`
              public struct Contents: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("type", Type_SelectionSet.self),
                  .field("json", SuiKit.JSONApollo.self)
                ] }

                /// The value's Move type.
                public var type: Type_SelectionSet { __data["type"] }
                /// Representation of a Move value in JSON, where:
                ///
                /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
                /// - Bools are represented by JSON boolean literals.
                /// - u8, u16, and u32 are represented as JSON numbers.
                /// - u64, u128, and u256 are represented as JSON strings.
                /// - Vectors are represented by JSON arrays.
                /// - Structs are represented by JSON objects.
                /// - Empty optional values are represented by `null`.
                ///
                /// This form is offered as a less verbose convenience in cases where the layout of the type is
                /// known by the client.
                public var json: SuiKit.JSONApollo { __data["json"] }

                /// Owner.DynamicFields.Node.Value.AsMoveObject.Contents.Type_SelectionSet
                ///
                /// Parent Type: `MoveType`
                public struct Type_SelectionSet: SuiKit.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveType }
                  public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("repr", String.self)
                  ] }

                  /// Flat representation of the type signature, as a displayable string.
                  public var repr: String { __data["repr"] }
                }
              }
            }
          }
        }
      }
    }
  }
}
