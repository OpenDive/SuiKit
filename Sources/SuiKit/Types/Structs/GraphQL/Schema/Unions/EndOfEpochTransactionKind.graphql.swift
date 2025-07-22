// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  static let EndOfEpochTransactionKind = Union(
    name: "EndOfEpochTransactionKind",
    possibleTypes: [
      Objects.ChangeEpochTransaction.self,
      Objects.AuthenticatorStateCreateTransaction.self,
      Objects.AuthenticatorStateExpireTransaction.self,
      Objects.RandomnessStateCreateTransaction.self,
      Objects.CoinDenyListStateCreateTransaction.self,
      Objects.BridgeStateCreateTransaction.self,
      Objects.BridgeCommitteeInitTransaction.self
    ]
  )
}
