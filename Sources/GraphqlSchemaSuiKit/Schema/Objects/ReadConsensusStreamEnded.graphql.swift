// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// A transaction that wanted to read a consensus-managed object but couldn't because it became not-consensus-managed before the transaction executed (for example, it was deleted, turned into an owned object, or wrapped).
  static let ReadConsensusStreamEnded = ApolloAPI.Object(
    typename: "ReadConsensusStreamEnded",
    implementedInterfaces: [],
    keyFields: nil
  )
}