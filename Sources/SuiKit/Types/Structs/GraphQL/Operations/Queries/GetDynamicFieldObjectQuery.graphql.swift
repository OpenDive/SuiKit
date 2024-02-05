// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDynamicFieldObjectQuery: GraphQLQuery {
  public static let operationName: String = "getDynamicFieldObject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getDynamicFieldObject($parentId: SuiAddress!, $name: DynamicFieldNameApollo!) { object(address: $parentId) { __typename dynamicObjectField(name: $name) { __typename name { __typename type { __typename repr } } value { __typename ... on MoveObject { contents { __typename data type { __typename layout repr } } hasPublicTransfer asObject { __typename address digest version display { __typename key value error } } } } } } }"#
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
      /// using their type, and their BCS contents, Base64Apollo encoded.
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
              .field("hasPublicTransfer", Bool.self),
              .field("asObject", AsObject.self),
            ] }

            /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
            /// provides the flat representation of the type signature, and the bcs of the corresponding
            /// data
            public var contents: Contents? { __data["contents"] }
            /// Determines whether a transaction can transfer this object, using the TransferObjects
            /// transaction command or `sui::transfer::public_transfer`, both of which require the object to
            /// have the `key` and `store` abilities.
            public var hasPublicTransfer: Bool { __data["hasPublicTransfer"] }
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
                .field("data", SuiKit.MoveDataApollo.self),
                .field("type", Type_SelectionSet.self),
              ] }

              /// Structured contents of a Move value.
              public var data: SuiKit.MoveDataApollo { __data["data"] }
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
                  .field("layout", SuiKit.MoveTypeLayoutApollo.self),
                  .field("repr", String.self),
                ] }

                /// Structured representation of the "shape" of values that match this type.
                public var layout: SuiKit.MoveTypeLayoutApollo { __data["layout"] }
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
                .field("address", SuiKit.SuiAddressApollo.self),
                .field("digest", String.self),
                .field("version", Int.self),
                .field("display", [Display]?.self),
              ] }

              /// The address of the object, named as such to avoid conflict with the address type.
              public var address: SuiKit.SuiAddressApollo { __data["address"] }
              /// 32-byte hash that identifies the object's current contents, encoded as a Base58 string.
              public var digest: String { __data["digest"] }
              public var version: Int { __data["version"] }
              /// The set of named templates defined on-chain for the type of this object,
              /// to be handled off-chain. The server substitutes data from the object
              /// into these templates to generate a display string per template.
              public var display: [Display]? { __data["display"] }

              /// Object.DynamicObjectField.Value.AsMoveObject.AsObject.Display
              ///
              /// Parent Type: `DisplayEntry`
              public struct Display: SuiKit.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.DisplayEntry }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("key", String.self),
                  .field("value", String?.self),
                  .field("error", String?.self),
                ] }

                /// The identifier for a particular template string of the Display object.
                public var key: String { __data["key"] }
                /// The template string for the key with placeholder values substituted.
                public var value: String? { __data["value"] }
                /// An error string describing why the template could not be rendered.
                public var error: String? { __data["error"] }
              }
            }
          }
        }
      }
    }
  }
}
