// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct EventFilter: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    sender: GraphQLNullable<SuiAddressApollo> = nil,
    transactionDigest: GraphQLNullable<String> = nil,
    emittingModule: GraphQLNullable<String> = nil,
    eventType: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "sender": sender,
      "transactionDigest": transactionDigest,
      "emittingModule": emittingModule,
      "eventType": eventType
    ])
  }

  public var sender: GraphQLNullable<SuiAddressApollo> {
    get { __data["sender"] }
    set { __data["sender"] = newValue }
  }

  public var transactionDigest: GraphQLNullable<String> {
    get { __data["transactionDigest"] }
    set { __data["transactionDigest"] = newValue }
  }

  /// Events emitted by a particular module. An event is emitted by a
  /// particular module if some function in the module is called by a
  /// PTB and emits an event.
  ///
  /// Modules can be filtered by their package, or package::module.
  public var emittingModule: GraphQLNullable<String> {
    get { __data["emittingModule"] }
    set { __data["emittingModule"] = newValue }
  }

  /// This field is used to specify the type of event emitted.
  ///
  /// Events can be filtered by their type's package, package::module,
  /// or their fully qualified type name.
  ///
  /// Generic types can be queried by either the generic type name, e.g.
  /// `0x2::coin::Coin`, or by the full type name, such as
  /// `0x2::coin::Coin<0x2::sui::SUI>`.
  public var eventType: GraphQLNullable<String> {
    get { __data["eventType"] }
    set { __data["eventType"] = newValue }
  }
}
