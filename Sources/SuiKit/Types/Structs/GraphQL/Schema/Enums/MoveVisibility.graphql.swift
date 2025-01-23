// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// The visibility modifier describes which modules can access this module member.
/// By default, a module member can be called only within the same module.
public enum MoveVisibility: String, EnumType {
  /// A public member can be accessed by any module.
  case `public` = "PUBLIC"
  /// A private member can be accessed in the module it is defined in.
  case `private` = "PRIVATE"
  /// A friend member can be accessed in the module it is defined in and any other module in
  /// its package that is explicitly specified in its friend list.
  case friend = "FRIEND"
}
