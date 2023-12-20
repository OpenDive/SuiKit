// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDynamicFieldObjectQuery: GraphQLQuery {
  public static let operationName: String = "getDynamicFieldObject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getDynamicFieldObject($parentId: SuiAddress!, $name: DynamicFieldName!) { object(address: $parentId) { __typename dynamicObjectField(name: $name) { __typename name { __typename type { __typename repr } } value { __typename ... on MoveObject { contents { __typename json type { __typename repr } } asObject { __typename location digest version } } } } } }"#
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
        .field("dynamicObjectField", DynamicObjectField?.self, arguments: ["name": .variable("name")]),
      ] }

      /// Access a dynamic object field on an object using its name.
      /// Names are arbitrary Move values whose type have `copy`, `drop`, and `store`, and are specified
      /// using their type, and their BCS contents, Base64 encoded.
      /// The value of a dynamic object field can also be accessed off-chain directly via its address (e.g. using `Query.object`).
      /// Dynamic fields on wrapped objects can be accessed by using the same API under the Owner type.
      public var dynamicObjectField: DynamicObjectField? { __data["dynamicObjectField"] }

      /// Object.DynamicObjectField
      ///
      /// Parent Type: `DynamicField`
      public struct DynamicObjectField: SuiKit.SelectionSet {
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

        /// Object.DynamicObjectField.Name
        ///
        /// Parent Type: `MoveValue`
        public struct Name: SuiKit.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("type", Type_SelectionSet.self),
          ] }

          public var type: Type_SelectionSet { __data["type"] }

          /// Object.DynamicObjectField.Name.Type_SelectionSet
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

        /// Object.DynamicObjectField.Value
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

          /// Object.DynamicObjectField.Value.AsMoveObject
          ///
          /// Parent Type: `MoveObject`
          public struct AsMoveObject: SuiKit.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = GetDynamicFieldObjectQuery.Data.Object.DynamicObjectField.Value
            public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("contents", Contents?.self),
              .field("asObject", AsObject.self),
            ] }

            /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }
            /// Attempts to convert the Move object into an Object
            /// This provides additional information such as version and digest on the top-level
            public var asObject: AsObject { __data["asObject"] }

            /// Object.DynamicObjectField.Value.AsMoveObject.Contents
            ///
            /// Parent Type: `MoveValue`
            public struct Contents: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("json", SuiKit.JSONApollo.self),
                .field("type", Type_SelectionSet.self),
              ] }

              /// Representation of a Move value in JSON, where:
              ///
              /// - Addresses and UIDs are represented in canonical form, as JSON strings.
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
              public var type: Type_SelectionSet { __data["type"] }

              /// Object.DynamicObjectField.Value.AsMoveObject.Contents.Type_SelectionSet
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

            /// Object.DynamicObjectField.Value.AsMoveObject.AsObject
            ///
            /// Parent Type: `Object`
            public struct AsObject: SuiKit.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("location", SuiKit.SuiAddressApollo.self),
                .field("digest", String.self),
                .field("version", Int.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var location: SuiKit.SuiAddressApollo { __data["location"] }
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
