// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetTypeLayoutQuery: GraphQLQuery {
  public static let operationName: String = "getTypeLayout"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getTypeLayout($type: String!) { type(type: $type) { __typename layout } }"#
    ))

  public var type: String

  public init(type: String) {
    self.type = type
  }

  public var __variables: Variables? { ["type": type] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("type", Type_SelectionSet.self, arguments: ["type": .variable("type")])
    ] }

    /// Fetch a structured representation of a concrete type, including its layout information.
    /// Fails if the type is malformed.
    public var type: Type_SelectionSet { __data["type"] }

    /// Type_SelectionSet
    ///
    /// Parent Type: `MoveType`
    public struct Type_SelectionSet: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.MoveType }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("layout", SuiKit.MoveTypeLayoutApollo?.self)
      ] }

      /// Structured representation of the "shape" of values that match this type. May return no
      /// layout if the type is invalid.
      public var layout: SuiKit.MoveTypeLayoutApollo? { __data["layout"] }
    }
  }
}
