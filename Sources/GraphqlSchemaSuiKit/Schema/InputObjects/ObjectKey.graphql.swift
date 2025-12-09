// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

/// Identifies a specific version of an object.
///
/// The `address` field must be specified, as well as at most one of `version`, `rootVersion`, or `atCheckpoint`. If none are provided, the object is fetched at the current checkpoint.
///
/// Specifying a `version` or a `rootVersion` disables nested queries for paginating owned objects or dynamic fields (these queries are only supported at checkpoint boundaries).
///
/// See `Query.object` for more details.
public struct ObjectKey: InputObject {
  @_spi(Unsafe) public private(set) var __data: InputDict

  @_spi(Unsafe) public init(_ data: InputDict) {
    __data = data
  }

  public init(
    address: SuiAddress,
    atCheckpoint: GraphQLNullable<UInt53> = nil,
    rootVersion: GraphQLNullable<UInt53> = nil,
    version: GraphQLNullable<UInt53> = nil
  ) {
    __data = InputDict([
      "address": address,
      "atCheckpoint": atCheckpoint,
      "rootVersion": rootVersion,
      "version": version
    ])
  }

  /// The object's ID.
  public var address: SuiAddress {
    get { __data["address"] }
    set { __data["address"] = newValue }
  }

  /// If specified, tries to fetch the latest version as of this checkpoint. Fails if the checkpoint is later than the RPC's latest checkpoint.
  public var atCheckpoint: GraphQLNullable<UInt53> {
    get { __data["atCheckpoint"] }
    set { __data["atCheckpoint"] = newValue }
  }

  /// If specified, tries to fetch the latest version of the object at or before this version. Nested dynamic field accesses will also be subject to this bound.
  ///
  /// This can be used to fetch a child or ancestor object bounded by its root object's version. For any wrapped or child (object-owned) object, its root object can be defined recursively as:
  ///
  /// - The root object of the object it is wrapped in, if it is wrapped.
  /// - The root object of its owner, if it is owned by another object.
  /// - The object itself, if it is not object-owned or wrapped.
  public var rootVersion: GraphQLNullable<UInt53> {
    get { __data["rootVersion"] }
    set { __data["rootVersion"] = newValue }
  }

  /// If specified, tries to fetch the object at this exact version.
  public var version: GraphQLNullable<UInt53> {
    get { __data["version"] }
    set { __data["version"] = newValue }
  }
}
