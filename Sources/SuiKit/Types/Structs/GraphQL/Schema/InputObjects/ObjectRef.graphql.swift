// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ObjectRef: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    address: SuiAddressApollo,
    version: UInt53Apollo,
    digest: String
  ) {
    __data = InputDict([
      "address": address,
      "version": version,
      "digest": digest
    ])
  }

  /// ID of the object.
  public var address: SuiAddressApollo {
    get { __data["address"] }
    set { __data["address"] = newValue }
  }

  /// Version or sequence number of the object.
  public var version: UInt53Apollo {
    get { __data["version"] }
    set { __data["version"] = newValue }
  }

  /// Digest of the object.
  public var digest: String {
    get { __data["digest"] }
    set { __data["digest"] = newValue }
  }
}
