// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// The object's owner kind.
  static let Owner = Union(
    name: "Owner",
    possibleTypes: [
      Objects.AddressOwner.self,
      Objects.ObjectOwner.self,
      Objects.Shared.self,
      Objects.Immutable.self,
      Objects.ConsensusAddressOwner.self
    ]
  )
}