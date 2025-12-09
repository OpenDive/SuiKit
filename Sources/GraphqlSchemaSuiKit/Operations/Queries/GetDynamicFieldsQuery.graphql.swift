// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetDynamicFieldsQuery: GraphQLQuery {
  public static let operationName: String = "getDynamicFields"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getDynamicFields($parentId: SuiAddress!, $first: Int, $cursor: String) { address(address: $parentId) { __typename dynamicFields(first: $first, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename name { __typename bcs type { __typename repr } } value { __typename ... on MoveValue { type { __typename repr } } ... on MoveObject { contents { __typename type { __typename repr } } } } } } } }"#
    ))

  public var parentId: SuiAddress
  public var first: GraphQLNullable<Int32>
  public var cursor: GraphQLNullable<String>

  public init(
    parentId: SuiAddress,
    first: GraphQLNullable<Int32>,
    cursor: GraphQLNullable<String>
  ) {
    self.parentId = parentId
    self.first = first
    self.cursor = cursor
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "parentId": parentId,
    "first": first,
    "cursor": cursor
  ] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("address", Address.self, arguments: ["address": .variable("parentId")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetDynamicFieldsQuery.Data.self
    ] }

    /// Look-up an account by its SuiAddress.
    ///
    /// If `rootVersion` is specified, nested dynamic field accesses will be fetched at or before this version. This can be used to fetch a child or ancestor object bounded by its root object's version, when its immediate parent is wrapped, or a value in a dynamic object field. For any wrapped or child (object-owned) object, its root object can be defined recursively as:
    ///
    /// - The root object of the object it is wrapped in, if it is wrapped.
    /// - The root object of its owner, if it is owned by another object.
    /// - The object itself, if it is not object-owned or wrapped.
    ///
    /// Specifying a `rootVersion` disables nested queries for paginating owned objects or dynamic fields (these queries are only supported at checkpoint boundaries).
    public var address: Address { __data["address"] }

    /// Address
    ///
    /// Parent Type: `Address`
    public struct Address: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Address }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("dynamicFields", DynamicFields?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("cursor")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetDynamicFieldsQuery.Data.Address.self
      ] }

      /// Dynamic fields owned by this address.
      ///
      /// The address must correspond to an object (account addresses cannot own dynamic fields), but that object may be wrapped.
      public var dynamicFields: DynamicFields? { __data["dynamicFields"] }

      /// Address.DynamicFields
      ///
      /// Parent Type: `DynamicFieldConnection`
      public struct DynamicFields: GraphqlSchemaSuiKit.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.DynamicFieldConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetDynamicFieldsQuery.Data.Address.DynamicFields.self
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node] { __data["nodes"] }

        /// Address.DynamicFields.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.PageInfo }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetDynamicFieldsQuery.Data.Address.DynamicFields.PageInfo.self
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Address.DynamicFields.Node
        ///
        /// Parent Type: `DynamicField`
        public struct Node: GraphqlSchemaSuiKit.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.DynamicField }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", Name?.self),
            .field("value", Value?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.self
          ] }

          /// The dynamic field's name, as a Move value.
          public var name: Name? { __data["name"] }
          /// The dynamic field's value, as a Move value for dynamic fields and as a MoveObject for dynamic object fields.
          public var value: Value? { __data["value"] }

          /// Address.DynamicFields.Node.Name
          ///
          /// Parent Type: `MoveValue`
          public struct Name: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("bcs", GraphqlSchemaSuiKit.Base64?.self),
              .field("type", Type_SelectionSet?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Name.self
            ] }

            /// The BCS representation of this value, Base64-encoded.
            public var bcs: GraphqlSchemaSuiKit.Base64? { __data["bcs"] }
            /// The value's type.
            public var type: Type_SelectionSet? { __data["type"] }

            /// Address.DynamicFields.Node.Name.Type_SelectionSet
            ///
            /// Parent Type: `MoveType`
            public struct Type_SelectionSet: GraphqlSchemaSuiKit.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("repr", String.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Name.Type_SelectionSet.self
              ] }

              /// Flat representation of the type signature, as a displayable string.
              public var repr: String { __data["repr"] }
            }
          }

          /// Address.DynamicFields.Node.Value
          ///
          /// Parent Type: `DynamicFieldValue`
          public struct Value: GraphqlSchemaSuiKit.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Unions.DynamicFieldValue }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .inlineFragment(AsMoveValue.self),
              .inlineFragment(AsMoveObject.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.self
            ] }

            public var asMoveValue: AsMoveValue? { _asInlineFragment() }
            public var asMoveObject: AsMoveObject? { _asInlineFragment() }

            /// Address.DynamicFields.Node.Value.AsMoveValue
            ///
            /// Parent Type: `MoveValue`
            public struct AsMoveValue: GraphqlSchemaSuiKit.InlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("type", Type_SelectionSet?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.self,
                GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveValue.self
              ] }

              /// The value's type.
              public var type: Type_SelectionSet? { __data["type"] }

              /// Address.DynamicFields.Node.Value.AsMoveValue.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              public struct Type_SelectionSet: GraphqlSchemaSuiKit.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("repr", String.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveValue.Type_SelectionSet.self
                ] }

                /// Flat representation of the type signature, as a displayable string.
                public var repr: String { __data["repr"] }
              }
            }

            /// Address.DynamicFields.Node.Value.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            public struct AsMoveObject: GraphqlSchemaSuiKit.InlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveObject }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("contents", Contents?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.self,
                GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveObject.self
              ] }

              /// The structured representation of the object's contents.
              public var contents: Contents? { __data["contents"] }

              /// Address.DynamicFields.Node.Value.AsMoveObject.Contents
              ///
              /// Parent Type: `MoveValue`
              public struct Contents: GraphqlSchemaSuiKit.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveValue }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("type", Type_SelectionSet?.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveObject.Contents.self
                ] }

                /// The value's type.
                public var type: Type_SelectionSet? { __data["type"] }

                /// Address.DynamicFields.Node.Value.AsMoveObject.Contents.Type_SelectionSet
                ///
                /// Parent Type: `MoveType`
                public struct Type_SelectionSet: GraphqlSchemaSuiKit.SelectionSet {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.MoveType }
                  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("repr", String.self),
                  ] }
                  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveObject.Contents.Type_SelectionSet.self
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
