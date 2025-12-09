// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

/// An enum that specifies the intent scope to be used to parse the bytes for signature verification.
public enum ZkLoginIntentScope: String, EnumType {
  /// Indicates that the bytes are to be parsed as transaction data bytes.
  case transactionData = "TRANSACTION_DATA"
  /// Indicates that the bytes are to be parsed as a personal message.
  case personalMessage = "PERSONAL_MESSAGE"
}
