// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// Activity on Sui is partitioned in time, into epochs.
  ///
  /// Epoch changes are opportunities for the network to reconfigure itself (perform protocol or system package upgrades, or change the committee) and distribute staking rewards. The network aims to keep epochs roughly the same duration as each other.
  ///
  /// During a particular epoch the following data is fixed:
  ///
  /// - protocol version,
  /// - reference gas price,
  /// - system package versions,
  /// - validators in the committee.
  static let Epoch = ApolloAPI.Object(
    typename: "Epoch",
    implementedInterfaces: [],
    keyFields: nil
  )
}