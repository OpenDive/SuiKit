// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

/// Filter on who owns an object.
public enum OwnerKind: String, EnumType {
  /// Object is owned by an address.
  case address = "ADDRESS"
  /// Object is a child of another object (e.g. a dynamic field or dynamic object field).
  case object = "OBJECT"
  /// Object is shared among multiple owners.
  case shared = "SHARED"
  /// Object is frozen.
  case immutable = "IMMUTABLE"
}
