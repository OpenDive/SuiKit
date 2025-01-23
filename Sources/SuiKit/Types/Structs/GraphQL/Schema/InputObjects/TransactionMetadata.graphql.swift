// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// The optional extra data a user can provide to a transaction dry run.
/// `sender` defaults to `0x0`. If gasObjects` is not present, or is an empty list,
/// it is substituted with a mock Coin object, `gasPrice` defaults to the reference
/// gas price, `gasBudget` defaults to the max gas budget and `gasSponsor` defaults
/// to the sender.
public struct TransactionMetadata: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    sender: GraphQLNullable<SuiAddressApollo> = nil,
    gasPrice: GraphQLNullable<UInt53Apollo> = nil,
    gasObjects: GraphQLNullable<[ObjectRef]> = nil,
    gasBudget: GraphQLNullable<UInt53Apollo> = nil,
    gasSponsor: GraphQLNullable<SuiAddressApollo> = nil
  ) {
    __data = InputDict([
      "sender": sender,
      "gasPrice": gasPrice,
      "gasObjects": gasObjects,
      "gasBudget": gasBudget,
      "gasSponsor": gasSponsor
    ])
  }

  public var sender: GraphQLNullable<SuiAddressApollo> {
    get { __data["sender"] }
    set { __data["sender"] = newValue }
  }

  public var gasPrice: GraphQLNullable<UInt53Apollo> {
    get { __data["gasPrice"] }
    set { __data["gasPrice"] = newValue }
  }

  public var gasObjects: GraphQLNullable<[ObjectRef]> {
    get { __data["gasObjects"] }
    set { __data["gasObjects"] = newValue }
  }

  public var gasBudget: GraphQLNullable<UInt53Apollo> {
    get { __data["gasBudget"] }
    set { __data["gasBudget"] = newValue }
  }

  public var gasSponsor: GraphQLNullable<SuiAddressApollo> {
    get { __data["gasSponsor"] }
    set { __data["gasSponsor"] = newValue }
  }
}
