// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ObjectFilter: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    type: GraphQLNullable<String> = nil,
    owner: GraphQLNullable<SuiAddressApollo> = nil,
    objectIds: GraphQLNullable<[SuiAddressApollo]> = nil,
    objectKeys: GraphQLNullable<[ObjectKey]> = nil
  ) {
    __data = InputDict([
      "type": type,
      "owner": owner,
      "objectIds": objectIds,
      "objectKeys": objectKeys
    ])
  }

  /// This field is used to specify the type of objects that should be included in the query
  /// results.
  ///
  /// Objects can be filtered by their type's package, package::module, or their fully qualified
  /// type name.
  ///
  /// Generic types can be queried by either the generic type name, e.g. `0x2::coin::Coin`, or by
  /// the full type name, such as `0x2::coin::Coin<0x2::sui::SUI>`.
  public var type: GraphQLNullable<String> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }

  /// Filter for live objects by their current owners.
  public var owner: GraphQLNullable<SuiAddressApollo> {
    get { __data["owner"] }
    set { __data["owner"] = newValue }
  }

  /// Filter for live objects by their IDs.
  public var objectIds: GraphQLNullable<[SuiAddressApollo]> {
    get { __data["objectIds"] }
    set { __data["objectIds"] = newValue }
  }

  /// Filter for live or potentially historical objects by their ID and version.
  public var objectKeys: GraphQLNullable<[ObjectKey]> {
    get { __data["objectKeys"] }
    set { __data["objectKeys"] = newValue }
  }
}
