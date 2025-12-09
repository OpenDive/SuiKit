// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// Dynamic fields are heterogenous fields that can be added or removed from an object at runtime. Their names are arbitrary Move values that have `copy`, `drop`, and `store`.
  ///
  /// There are two sub-types of dynamic fields:
  ///
  /// - Dynamic fields can store any value that has `store`. Objects stored in this kind of field will be considered wrapped (not accessible via its ID by external tools like explorers, wallets, etc. accessing storage).
  /// - Dynamic object fields can only store objects (values that have the `key` ability, and an `id: UID` as its first field) that have `store`, but they will still be directly accessible off-chain via their ID after being attached as a field.
  static let DynamicField = ApolloAPI.Object(
    typename: "DynamicField",
    implementedInterfaces: [
      Interfaces.IAddressable.self,
      Interfaces.IMoveObject.self,
      Interfaces.IObject.self
    ],
    keyFields: nil
  )
}