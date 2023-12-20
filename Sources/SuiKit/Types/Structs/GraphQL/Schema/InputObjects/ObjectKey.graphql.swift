// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ObjectKey: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    objectId: SuiAddressApollo,
    version: Int
  ) {
    __data = InputDict([
      "objectId": objectId,
      "version": version
    ])
  }

  public var objectId: SuiAddressApollo {
    get { __data["objectId"] }
    set { __data["objectId"] = newValue }
  }

  public var version: Int {
    get { __data["version"] }
    set { __data["version"] = newValue }
  }
}
