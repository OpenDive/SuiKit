// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Abilities are keywords in Sui Move that define how types behave at the compiler level.
public enum MoveAbility: String, EnumType {
  /// Enables values to be copied.
  case copy = "COPY"
  /// Enables values to be popped/dropped.
  case drop = "DROP"
  /// Enables values to be held directly in global storage.
  case key = "KEY"
  /// Enables values to be held inside a struct in global storage.
  case store = "STORE"
}
