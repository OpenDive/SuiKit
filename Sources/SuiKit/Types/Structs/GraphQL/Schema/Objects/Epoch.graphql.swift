// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// Operation of the Sui network is temporally partitioned into non-overlapping epochs,
  /// and the network aims to keep epochs roughly the same duration as each other.
  /// During a particular epoch the following data is fixed:
  ///
  /// - the protocol version
  /// - the reference gas price
  /// - the set of participating validators
  static let Epoch = ApolloAPI.Object(
    typename: "Epoch",
    implementedInterfaces: []
  )
}
