// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDynamicFieldsQuery: GraphQLQuery {
  public static let operationName: String = "getDynamicFields"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getDynamicFields($parentId: SuiAddress!, $first: Int, $cursor: String) { object(address: $parentId) { __typename dynamicFieldConnection(first: $first, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename name { __typename bcs JSONApollo type { __typename layout repr } } value { __typename ... on MoveObject { contents { __typename type { __typename repr } JSONApollo } asObject { __typename storageRebate address digest version } } } } } } }"#
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

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("object", Object?.self, arguments: ["address": .variable("parentId")]),
    ] }

    public var object: Object? { __data["object"] }

    /// Object
    ///
    /// Parent Type: `Object`
    public struct Object: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("dynamicFieldConnection", DynamicFieldConnection?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("cursor")
        ]),
      ] }

      /// The dynamic fields on an object.
      /// Dynamic fields on wrapped objects can be accessed by using the same API under the Owner type.
      public var dynamicFieldConnection: DynamicFieldConnection? { __data["dynamicFieldConnection"] }

      /// Object.DynamicFieldConnection
      ///
      /// Parent Type: `DynamicFieldConnection`
      public struct DynamicFieldConnection: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.DynamicFieldConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Object.DynamicFieldConnection.PageInfo
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

        /// Object.DynamicFieldConnection.Node
        ///
        /// Parent Type: `DynamicField`
        public struct Node: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.DynamicField }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", Name?.self),
            .field("value", Value?.self),
          ] }

          /// The string type, data, and serialized value of the DynamicField's 'name' field.
          /// This field is used to uniquely identify a child of the parent object.
          public var name: Name? { __data["name"] }
          /// The actual data stored in the dynamic field.
          /// The returned dynamic field is an object if its return type is MoveObject,
          /// in which case it is also accessible off-chain via its address.
          public var value: Value? { __data["value"] }

          /// Object.DynamicFieldConnection.Node.Name
          ///
          /// Parent Type: `MoveValue`
          public struct Name: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("bcs", SuiKit.Base64Apollo.self),
              .field("JSONApollo", SuiKit.JSONApollo.self),
              .field("type", Type_SelectionSet.self),
            ] }

            public var bcs: SuiKit.Base64Apollo { __data["bcs"] }
            /// Representation of a Move value in JSONApollo, where:
            ///
            /// - Addresses, IDs, and UIDs are represented in canonical form, as JSONApollo strings.
            /// - Bools are represented by JSONApollo boolean literals.
            /// - u8, u16, and u32 are represented as JSONApollo numbers.
            /// - u64, u128, and u256 are represented as JSONApollo strings.
            /// - Vectors are represented by JSONApollo arrays.
            /// - Structs are represented by JSONApollo objects.
            /// - Empty optional values are represented by `null`.
            ///
            /// This form is offered as a less verbose convenience in cases where the layout of the type is
            /// known by the client.
            public var JSONApollo: SuiKit.JSONApollo { __data["JSONApollo"] }
            public var type: Type_SelectionSet { __data["type"] }

            /// Object.DynamicFieldConnection.Node.Name.Type_SelectionSet
            ///
            /// Parent Type: `MoveType`
            public struct Type_SelectionSet: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveType }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("layout", SuiKit.MoveTypeLayoutApollo.self),
                .field("repr", String.self),
              ] }

              /// Structured representation of the "shape" of values that match this type.
              public var layout: SuiKit.MoveTypeLayoutApollo { __data["layout"] }
              /// Flat representation of the type signature, as a displayable string.
              public var repr: String { __data["repr"] }
            }
          }

          /// Object.DynamicFieldConnection.Node.Value
          ///
          /// Parent Type: `DynamicFieldValue`
          public struct Value: SuiKit.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { SuiKit.Unions.DynamicFieldValue }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .inlineFragment(AsMoveObject.self),
            ] }

            public var asMoveObject: AsMoveObject? { _asInlineFragment() }

            /// Object.DynamicFieldConnection.Node.Value.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            public struct AsMoveObject: SuiKit.InlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetDynamicFieldsQuery.Data.Object.DynamicFieldConnection.Node.Value
              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
              public static var __selections: [ApolloAPI.Selection] { [
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

              /// Object.DynamicFieldConnection.Node.Value.AsMoveObject.Contents
              ///
              /// Parent Type: `MoveValue`
              public struct Contents: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("type", Type_SelectionSet.self),
                  .field("JSONApollo", SuiKit.JSONApollo.self),
                ] }

                public var type: Type_SelectionSet { __data["type"] }
                /// Representation of a Move value in JSONApollo, where:
                ///
                /// - Addresses, IDs, and UIDs are represented in canonical form, as JSONApollo strings.
                /// - Bools are represented by JSONApollo boolean literals.
                /// - u8, u16, and u32 are represented as JSONApollo numbers.
                /// - u64, u128, and u256 are represented as JSONApollo strings.
                /// - Vectors are represented by JSONApollo arrays.
                /// - Structs are represented by JSONApollo objects.
                /// - Empty optional values are represented by `null`.
                ///
                /// This form is offered as a less verbose convenience in cases where the layout of the type is
                /// known by the client.
                public var JSONApollo: SuiKit.JSONApollo { __data["JSONApollo"] }

                /// Object.DynamicFieldConnection.Node.Value.AsMoveObject.Contents.Type_SelectionSet
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

              /// Object.DynamicFieldConnection.Node.Value.AsMoveObject.AsObject
              ///
              /// Parent Type: `Object`
              public struct AsObject: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("storageRebate", SuiKit.BigIntApollo?.self),
                  .field("address", SuiKit.SuiAddressApollo.self),
                  .field("digest", String.self),
                  .field("version", Int.self),
                ] }

                /// The amount of SUI we would rebate if this object gets deleted or mutated.
                /// This number is recalculated based on the present storage gas price.
                public var storageRebate: SuiKit.BigIntApollo? { __data["storageRebate"] }
                /// The address of the object, named as such to avoid conflict with the address type.
                public var address: SuiKit.SuiAddressApollo { __data["address"] }
                /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
                public var digest: String { __data["digest"] }
                public var version: Int { __data["version"] }
              }
            }
          }
        }
      }
    }
  }
}
