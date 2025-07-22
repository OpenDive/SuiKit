// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// An Owner is an entity that can own an object. Each Owner is identified by a SuiAddress which
  /// represents either an Address (corresponding to a public key of an account) or an Object, but
  /// never both (it is not known up-front whether a given Owner is an Address or an Object).
  static let Owner = ApolloAPI.Object(
    typename: "Owner",
    implementedInterfaces: [Interfaces.IOwner.self]
  )
}
