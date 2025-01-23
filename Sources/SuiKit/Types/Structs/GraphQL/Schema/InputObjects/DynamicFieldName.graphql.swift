// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct DynamicFieldNameApollo: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    type: String,
    bcs: Base64Apollo
  ) {
    __data = InputDict([
      "type": type,
      "bcs": bcs
    ])
  }

  /// The string type of the DynamicField's 'name' field.
  /// A string representation of a Move primitive like 'u64', or a struct type like '0x2::kiosk::Listing'
  public var type: String {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }

  /// The Base64 encoded bcs serialization of the DynamicField's 'name' field.
  public var bcs: Base64Apollo {
    get { __data["bcs"] }
    set { __data["bcs"] = newValue }
  }
}
