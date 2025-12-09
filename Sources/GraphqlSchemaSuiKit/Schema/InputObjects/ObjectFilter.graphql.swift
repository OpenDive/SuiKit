// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

/// A filter over the live object set, the filter can be one of:
///
/// - A filter on type (all live objects whose type matches that filter).
/// - Fetching all objects owned by an address or object, optionally filtered by type.
/// - Fetching all shared or immutable objects, filtered by type.
public struct ObjectFilter: InputObject {
  @_spi(Unsafe) public private(set) var __data: InputDict

  @_spi(Unsafe) public init(_ data: InputDict) {
    __data = data
  }

  public init(
    owner: GraphQLNullable<SuiAddress> = nil,
    ownerKind: GraphQLNullable<GraphQLEnum<OwnerKind>> = nil,
    type: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "owner": owner,
      "ownerKind": ownerKind,
      "type": type
    ])
  }

  /// Specifies the address of the owning address or object.
  ///
  /// This field is required if `ownerKind` is "ADDRESS" or "OBJECT". If provided without `ownerKind`, `ownerKind` defaults to "ADDRESS".
  public var owner: GraphQLNullable<SuiAddress> {
    get { __data["owner"] }
    set { __data["owner"] = newValue }
  }

  /// Filter on whether the object is address-owned, object-owned, shared, or immutable.
  ///
  /// - If this field is set to "ADDRESS" or "OBJECT", then an owner filter must also be provided.
  /// - If this field is set to "SHARED" or "IMMUTABLE", then a type filter must also be provided.
  public var ownerKind: GraphQLNullable<GraphQLEnum<OwnerKind>> {
    get { __data["ownerKind"] }
    set { __data["ownerKind"] = newValue }
  }

  /// Filter on the object's type.
  ///
  /// The filter can be one of:
  ///
  /// - A package address: `0x2`,
  /// - A module: `0x2::coin`,
  /// - A fully-qualified name: `0x2::coin::Coin`,
  /// - A type instantiation: `0x2::coin::Coin<0x2::sui::SUI>`.
  public var type: GraphQLNullable<String> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }
}
