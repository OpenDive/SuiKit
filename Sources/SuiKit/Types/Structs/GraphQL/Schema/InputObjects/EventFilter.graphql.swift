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
    emittingPackage: GraphQLNullable<SuiAddressApollo> = nil,
    emittingModule: GraphQLNullable<String> = nil,
    eventPackage: GraphQLNullable<SuiAddressApollo> = nil,
    eventModule: GraphQLNullable<String> = nil,
    eventType: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "sender": sender,
      "transactionDigest": transactionDigest,
      "emittingPackage": emittingPackage,
      "emittingModule": emittingModule,
      "eventPackage": eventPackage,
      "eventModule": eventModule,
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

  public var emittingPackage: GraphQLNullable<SuiAddressApollo> {
    get { __data["emittingPackage"] }
    set { __data["emittingPackage"] = newValue }
  }

  public var emittingModule: GraphQLNullable<String> {
    get { __data["emittingModule"] }
    set { __data["emittingModule"] = newValue }
  }

  public var eventPackage: GraphQLNullable<SuiAddressApollo> {
    get { __data["eventPackage"] }
    set { __data["eventPackage"] = newValue }
  }

  public var eventModule: GraphQLNullable<String> {
    get { __data["eventModule"] }
    set { __data["eventModule"] = newValue }
  }

  public var eventType: GraphQLNullable<String> {
    get { __data["eventType"] }
    set { __data["eventType"] = newValue }
  }
}
