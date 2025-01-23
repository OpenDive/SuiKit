// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// The stake's possible status: active, pending, or unstaked.
public enum StakeStatusApollo: String, EnumType {
  /// The stake object is active in a staking pool and it is generating rewards.
  case active = "ACTIVE"
  /// The stake awaits to join a staking pool in the next epoch.
  case pending = "PENDING"
  /// The stake is no longer active in any staking pool.
  case unstaked = "UNSTAKED"
}
