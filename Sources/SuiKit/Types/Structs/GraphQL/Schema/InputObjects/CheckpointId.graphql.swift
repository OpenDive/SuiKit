// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Filter either by the digest, or the sequence number, or neither, to get the latest checkpoint.
public struct CheckpointId: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    digest: GraphQLNullable<String> = nil,
    sequenceNumber: GraphQLNullable<UInt53Apollo> = nil
  ) {
    __data = InputDict([
        "digest": digest != nil ? GraphQLNullable.some(digest) : GraphQLNullable.none,
        "sequenceNumber": sequenceNumber != nil ? GraphQLNullable.some(sequenceNumber) : GraphQLNullable.none
    ])
  }

    public init(digest: String? = nil, sequenceNumber: Int? = nil) {
        __data = InputDict([
            "digest": digest != nil ? GraphQLNullable.some(digest) : GraphQLNullable.none,
            "sequenceNumber": sequenceNumber != nil ? GraphQLNullable.some(sequenceNumber) : GraphQLNullable.none
        ])
    }

  public var digest: GraphQLNullable<String> {
    get { __data["digest"] }
    set { __data["digest"] = newValue }
  }

  public var sequenceNumber: GraphQLNullable<UInt53Apollo> {
    get { __data["sequenceNumber"] }
    set { __data["sequenceNumber"] = newValue }
  }
}
