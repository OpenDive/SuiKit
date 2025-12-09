// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Interfaces {
  /// Interface implemented by GraphQL types representing entities that are identified by an address.
  ///
  /// An address uniquely represents either the public key of an account, or an object's ID, but never both. It is not possible to determine which type an address represents up-front. If an object is wrapped, its contents will not be accessible via its address, but it will still be possible to access other objects it owns.
  static let IAddressable = ApolloAPI.Interface(
    name: "IAddressable",
    keyFields: nil,
    implementingObjects: [
      "Address",
      "CoinMetadata",
      "DynamicField",
      "MoveObject",
      "MovePackage",
      "Object",
      "Validator"
    ]
  )
}