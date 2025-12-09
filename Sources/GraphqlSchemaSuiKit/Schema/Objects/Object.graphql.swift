// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// An Object on Sui is either a typed value (a Move Object) or a Package (modules containing functions and types).
  ///
  /// Every object on Sui is identified by a unique address, and has a version number that increases with every modification. Objects also hold metadata detailing their current owner (who can sign for access to the object and whether that access can modify and/or delete the object), and the digest of the last transaction that modified the object.
  static let Object = ApolloAPI.Object(
    typename: "Object",
    implementedInterfaces: [
      Interfaces.IAddressable.self,
      Interfaces.IObject.self
    ],
    keyFields: nil
  )
}