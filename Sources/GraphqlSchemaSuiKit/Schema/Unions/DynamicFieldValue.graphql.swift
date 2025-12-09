// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// The value of a dynamic field (`MoveValue`) or dynamic object field (`MoveObject`).
  static let DynamicFieldValue = Union(
    name: "DynamicFieldValue",
    possibleTypes: [
      Objects.MoveObject.self,
      Objects.MoveValue.self
    ]
  )
}