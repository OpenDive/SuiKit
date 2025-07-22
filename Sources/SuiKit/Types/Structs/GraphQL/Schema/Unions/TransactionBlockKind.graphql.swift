// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// The kind of transaction block, either a programmable transaction or a system transaction.
  static let TransactionBlockKind = Union(
    name: "TransactionBlockKind",
    possibleTypes: [
      Objects.ConsensusCommitPrologueTransaction.self,
      Objects.GenesisTransaction.self,
      Objects.ChangeEpochTransaction.self,
      Objects.ProgrammableTransactionBlock.self,
      Objects.AuthenticatorStateUpdateTransaction.self,
      Objects.RandomnessStateUpdateTransaction.self,
      Objects.EndOfEpochTransaction.self
    ]
  )
}
