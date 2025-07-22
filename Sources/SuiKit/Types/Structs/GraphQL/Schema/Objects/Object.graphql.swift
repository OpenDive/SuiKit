// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// An object in Sui is a package (set of Move bytecode modules) or object (typed data structure
  /// with fields) with additional metadata detailing its id, version, transaction digest, owner
  /// field indicating how this object can be accessed.
  static let Object = ApolloAPI.Object(
    typename: "Object",
    implementedInterfaces: [
      Interfaces.IObject.self,
      Interfaces.IOwner.self
    ]
  )
}
