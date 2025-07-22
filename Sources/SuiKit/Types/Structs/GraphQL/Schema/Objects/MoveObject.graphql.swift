// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// The representation of an object as a Move Object, which exposes additional information
  /// (content, module that governs it, version, is transferrable, etc.) about this object.
  static let MoveObject = ApolloAPI.Object(
    typename: "MoveObject",
    implementedInterfaces: [
      Interfaces.IMoveObject.self,
      Interfaces.IObject.self,
      Interfaces.IOwner.self
    ]
  )
}
