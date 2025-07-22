// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// Dynamic fields are heterogeneous fields that can be added or removed at runtime,
  /// and can have arbitrary user-assigned names. There are two sub-types of dynamic
  /// fields:
  ///
  /// 1) Dynamic Fields can store any value that has the `store` ability, however an object
  /// stored in this kind of field will be considered wrapped and will not be accessible
  /// directly via its ID by external tools (explorers, wallets, etc) accessing storage.
  /// 2) Dynamic Object Fields values must be Sui objects (have the `key` and `store`
  /// abilities, and id: UID as the first field), but will still be directly accessible off-chain
  /// via their object ID after being attached.
  static let DynamicField = ApolloAPI.Object(
    typename: "DynamicField",
    implementedInterfaces: []
  )
}
