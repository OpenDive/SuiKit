// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CheckpointId: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
        __data = data
    }

    public init(
        digest: String
    ) {
        __data = InputDict([
            "digest": GraphQLNullable<String>.some(digest),
            "sequenceNumber": GraphQLNullable<Int>.none
        ])
    }

    public init(
        sequenceNumber: Int
    ) {
        __data = InputDict([
            "digest": GraphQLNullable<String>.none,
            "sequenceNumber": GraphQLNullable<Int>.some(sequenceNumber)
        ])
    }

    public init(
        digest: GraphQLNullable<String> = nil,
        sequenceNumber: GraphQLNullable<Int> = nil
    ) {
        __data = InputDict([
            "digest": digest,
            "sequenceNumber": sequenceNumber
        ])
    }

    public var digest: GraphQLNullable<String> {
        get { __data["digest"] }
        set { __data["digest"] = newValue }
    }

    public var sequenceNumber: GraphQLNullable<Int> {
        get { __data["sequenceNumber"] }
        set { __data["sequenceNumber"] = newValue }
    }
}
