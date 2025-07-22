// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// A system transaction that updates epoch information on-chain (increments the current epoch).
  /// Executed by the system once per epoch, without using gas. Epoch change transactions cannot be
  /// submitted by users, because validators will refuse to sign them.
  ///
  /// This transaction kind is deprecated in favour of `EndOfEpochTransaction`.
  static let ChangeEpochTransaction = ApolloAPI.Object(
    typename: "ChangeEpochTransaction",
    implementedInterfaces: []
  )
}
