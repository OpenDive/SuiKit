// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// The object's owner type: Immutable, Shared, Parent, or Address.
  static let ObjectOwner = Union(
    name: "ObjectOwner",
    possibleTypes: [
      Objects.Immutable.self,
      Objects.Shared.self,
      Objects.Parent.self,
      Objects.AddressOwner.self,
      Objects.ConsensusV2.self
    ]
  )
}
