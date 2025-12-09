// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// Details pertaining to consensus-managed objects that are referenced by but not changed by a transaction.
  static let UnchangedConsensusObject = Union(
    name: "UnchangedConsensusObject",
    possibleTypes: [
      Objects.ConsensusObjectRead.self,
      Objects.MutateConsensusStreamEnded.self,
      Objects.ReadConsensusStreamEnded.self,
      Objects.ConsensusObjectCancelled.self,
      Objects.PerEpochConfig.self
    ]
  )
}