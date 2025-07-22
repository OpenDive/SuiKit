// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// System transaction that supersedes `ChangeEpochTransaction` as the new way to run transactions
  /// at the end of an epoch. Behaves similarly to `ChangeEpochTransaction` but can accommodate other
  /// optional transactions to run at the end of the epoch.
  static let EndOfEpochTransaction = ApolloAPI.Object(
    typename: "EndOfEpochTransaction",
    implementedInterfaces: []
  )
}
