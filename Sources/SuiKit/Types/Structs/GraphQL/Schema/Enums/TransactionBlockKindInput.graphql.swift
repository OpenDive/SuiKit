// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// An input filter selecting for either system or programmable transactions.
public enum TransactionBlockKindInput: String, EnumType {
  /// A system transaction can be one of several types of transactions.
  /// See [unions/transaction-block-kind] for more details.
  case systemTx = "SYSTEM_TX"
  /// A user submitted transaction block.
  case programmableTx = "PROGRAMMABLE_TX"
}
