// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Constrains the set of objects returned. All filters are optional, and the resulting set of
/// objects are ones whose
///
/// - Type matches the `type` filter,
/// - AND, whose owner matches the `owner` filter,
/// - AND, whose ID is in `objectIds` OR whose ID and version is in `objectKeys`.
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

    public init(filter: SuiObjectDataFilter) throws {
        __data = InputDict([:])
        switch filter {
        case .structType(let structType):
            __data["type"] = structType
        case .addressOwner(let addressOwner):
            __data["owner"] = addressOwner
        case .objectOwner(let objectOwner):
            __data["owner"] = objectOwner
        case .objectId(let objectId):
            __data["objectIds"] = [objectId]
        case .objectIds(let objectIds):
            __data["objectIds"] = objectIds
        default:
            throw SuiError.notImplemented
        }
    }

  /// Filter objects by their type's `package`, `package::module`, or their fully qualified type
  /// name.
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

  /// Filter for live objects by their ID and version. NOTE:  this input filter has been
  /// deprecated in favor of `multiGetObjects` query as it does not make sense to query for live
  /// objects by their versions. This filter will be removed with v1.42.0 release.
  public var objectKeys: GraphQLNullable<[ObjectKey]> {
    get { __data["objectKeys"] }
    set { __data["objectKeys"] = newValue }
  }
}
