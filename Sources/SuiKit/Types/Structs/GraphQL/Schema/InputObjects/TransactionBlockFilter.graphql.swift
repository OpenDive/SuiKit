// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct TransactionBlockFilter: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    package: GraphQLNullable<SuiAddressApollo> = nil,
    module: GraphQLNullable<String> = nil,
    function: GraphQLNullable<String> = nil,
    kind: GraphQLNullable<GraphQLEnum<TransactionBlockKindInput>> = nil,
    afterCheckpoint: GraphQLNullable<Int> = nil,
    atCheckpoint: GraphQLNullable<Int> = nil,
    beforeCheckpoint: GraphQLNullable<Int> = nil,
    signAddress: GraphQLNullable<SuiAddressApollo> = nil,
    sentAddress: GraphQLNullable<SuiAddressApollo> = nil,
    recvAddress: GraphQLNullable<SuiAddressApollo> = nil,
    paidAddress: GraphQLNullable<SuiAddressApollo> = nil,
    inputObject: GraphQLNullable<SuiAddressApollo> = nil,
    changedObject: GraphQLNullable<SuiAddressApollo> = nil,
    transactionIds: GraphQLNullable<[String]> = nil
  ) {
    __data = InputDict([
      "package": package,
      "module": module,
      "function": function,
      "kind": kind,
      "afterCheckpoint": afterCheckpoint,
      "atCheckpoint": atCheckpoint,
      "beforeCheckpoint": beforeCheckpoint,
      "signAddress": signAddress,
      "sentAddress": sentAddress,
      "recvAddress": recvAddress,
      "paidAddress": paidAddress,
      "inputObject": inputObject,
      "changedObject": changedObject,
      "transactionIds": transactionIds
    ])
  }

  public var package: GraphQLNullable<SuiAddressApollo> {
    get { __data["package"] }
    set { __data["package"] = newValue }
  }

  public var module: GraphQLNullable<String> {
    get { __data["module"] }
    set { __data["module"] = newValue }
  }

  public var function: GraphQLNullable<String> {
    get { __data["function"] }
    set { __data["function"] = newValue }
  }

  public var kind: GraphQLNullable<GraphQLEnum<TransactionBlockKindInput>> {
    get { __data["kind"] }
    set { __data["kind"] = newValue }
  }

  public var afterCheckpoint: GraphQLNullable<Int> {
    get { __data["afterCheckpoint"] }
    set { __data["afterCheckpoint"] = newValue }
  }

  public var atCheckpoint: GraphQLNullable<Int> {
    get { __data["atCheckpoint"] }
    set { __data["atCheckpoint"] = newValue }
  }

  public var beforeCheckpoint: GraphQLNullable<Int> {
    get { __data["beforeCheckpoint"] }
    set { __data["beforeCheckpoint"] = newValue }
  }

  public var signAddress: GraphQLNullable<SuiAddressApollo> {
    get { __data["signAddress"] }
    set { __data["signAddress"] = newValue }
  }

  public var sentAddress: GraphQLNullable<SuiAddressApollo> {
    get { __data["sentAddress"] }
    set { __data["sentAddress"] = newValue }
  }

  public var recvAddress: GraphQLNullable<SuiAddressApollo> {
    get { __data["recvAddress"] }
    set { __data["recvAddress"] = newValue }
  }

  public var paidAddress: GraphQLNullable<SuiAddressApollo> {
    get { __data["paidAddress"] }
    set { __data["paidAddress"] = newValue }
  }

  public var inputObject: GraphQLNullable<SuiAddressApollo> {
    get { __data["inputObject"] }
    set { __data["inputObject"] = newValue }
  }

  public var changedObject: GraphQLNullable<SuiAddressApollo> {
    get { __data["changedObject"] }
    set { __data["changedObject"] = newValue }
  }

  public var transactionIds: GraphQLNullable<[String]> {
    get { __data["transactionIds"] }
    set { __data["transactionIds"] = newValue }
  }
}
