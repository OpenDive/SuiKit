// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct TransactionBlockFilter: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    function: GraphQLNullable<String> = nil,
    kind: GraphQLNullable<GraphQLEnum<TransactionBlockKindInput>> = nil,
    afterCheckpoint: GraphQLNullable<UInt53Apollo> = nil,
    atCheckpoint: GraphQLNullable<UInt53Apollo> = nil,
    beforeCheckpoint: GraphQLNullable<UInt53Apollo> = nil,
    affectedAddress: GraphQLNullable<SuiAddressApollo> = nil,
    sentAddress: GraphQLNullable<SuiAddressApollo> = nil,
    inputObject: GraphQLNullable<SuiAddressApollo> = nil,
    changedObject: GraphQLNullable<SuiAddressApollo> = nil,
    transactionIds: GraphQLNullable<[String]> = nil
  ) {
    __data = InputDict([
      "function": function,
      "kind": kind,
      "afterCheckpoint": afterCheckpoint,
      "atCheckpoint": atCheckpoint,
      "beforeCheckpoint": beforeCheckpoint,
      "affectedAddress": affectedAddress,
      "sentAddress": sentAddress,
      "inputObject": inputObject,
      "changedObject": changedObject,
      "transactionIds": transactionIds
    ])
  }

  /// Filter transactions by move function called. Calls can be filtered by the `package`,
  /// `package::module`, or the `package::module::name` of their function.
  public var function: GraphQLNullable<String> {
    get { __data["function"] }
    set { __data["function"] = newValue }
  }

  /// An input filter selecting for either system or programmable transactions.
  public var kind: GraphQLNullable<GraphQLEnum<TransactionBlockKindInput>> {
    get { __data["kind"] }
    set { __data["kind"] = newValue }
  }

  /// Limit to transactions that occured strictly after the given checkpoint.
  public var afterCheckpoint: GraphQLNullable<UInt53Apollo> {
    get { __data["afterCheckpoint"] }
    set { __data["afterCheckpoint"] = newValue }
  }

  /// Limit to transactions in the given checkpoint.
  public var atCheckpoint: GraphQLNullable<UInt53Apollo> {
    get { __data["atCheckpoint"] }
    set { __data["atCheckpoint"] = newValue }
  }

  /// Limit to transaction that occured strictly before the given checkpoint.
  public var beforeCheckpoint: GraphQLNullable<UInt53Apollo> {
    get { __data["beforeCheckpoint"] }
    set { __data["beforeCheckpoint"] = newValue }
  }

  /// Limit to transactions that interacted with the given address. The address could be a
  /// sender, sponsor, or recipient of the transaction.
  public var affectedAddress: GraphQLNullable<SuiAddressApollo> {
    get { __data["affectedAddress"] }
    set { __data["affectedAddress"] = newValue }
  }

  /// Limit to transactions that were sent by the given address.
  public var sentAddress: GraphQLNullable<SuiAddressApollo> {
    get { __data["sentAddress"] }
    set { __data["sentAddress"] = newValue }
  }

  /// Limit to transactions that accepted the given object as an input. NOTE: this input filter
  /// has been deprecated in favor of `affectedObject` which offers an easier to under behavior.
  ///
  /// This filter will be removed with 1.36.0 (2024-10-14), or at least one release after
  /// `affectedObject` is introduced, whichever is later.
  public var inputObject: GraphQLNullable<SuiAddressApollo> {
    get { __data["inputObject"] }
    set { __data["inputObject"] = newValue }
  }

  /// Limit to transactions that output a versioon of this object. NOTE: this input filter has
  /// been deprecated in favor of `affectedObject` which offers an easier to understand behavor.
  ///
  /// This filter will be removed with 1.36.0 (2024-10-14), or at least one release after
  /// `affectedObject` is introduced, whichever is later.
  public var changedObject: GraphQLNullable<SuiAddressApollo> {
    get { __data["changedObject"] }
    set { __data["changedObject"] = newValue }
  }

  /// Select transactions by their digest.
  public var transactionIds: GraphQLNullable<[String]> {
    get { __data["transactionIds"] }
    set { __data["transactionIds"] = newValue }
  }
}
