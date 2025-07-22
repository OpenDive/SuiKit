// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// An argument to a programmable transaction command.
  static let TransactionArgument = Union(
    name: "TransactionArgument",
    possibleTypes: [
      Objects.GasCoin.self,
      Objects.Input.self,
      Objects.Result.self
    ]
  )
}
