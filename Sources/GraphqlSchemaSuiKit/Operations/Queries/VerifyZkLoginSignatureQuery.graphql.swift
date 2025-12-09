// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct VerifyZkLoginSignatureQuery: GraphQLQuery {
  public static let operationName: String = "verifyZkLoginSignature"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query verifyZkLoginSignature($bytes: Base64!, $signature: Base64!, $intentScope: ZkLoginIntentScope!, $author: SuiAddress!) { verifyZkLoginSignature( bytes: $bytes signature: $signature intentScope: $intentScope author: $author ) { __typename success error } }"#
    ))

  public var bytes: Base64
  public var signature: Base64
  public var intentScope: GraphQLEnum<ZkLoginIntentScope>
  public var author: SuiAddress

  public init(
    bytes: Base64,
    signature: Base64,
    intentScope: GraphQLEnum<ZkLoginIntentScope>,
    author: SuiAddress
  ) {
    self.bytes = bytes
    self.signature = signature
    self.intentScope = intentScope
    self.author = author
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "bytes": bytes,
    "signature": signature,
    "intentScope": intentScope,
    "author": author
  ] }

  public struct Data: GraphqlSchemaSuiKit.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("verifyZkLoginSignature", VerifyZkLoginSignature.self, arguments: [
        "bytes": .variable("bytes"),
        "signature": .variable("signature"),
        "intentScope": .variable("intentScope"),
        "author": .variable("author")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      VerifyZkLoginSignatureQuery.Data.self
    ] }

    /// Verify a zkLogin signature os from the given `author`.
    ///
    /// Returns a `ZkLoginVerifyResult` where `success` is `true` and `error` is empty if the signature is valid. If the signature is invalid, `success` is `false` and `error` contains the relevant error message.
    ///
    /// - `bytes` are either the bytes of a serialized personal message, or `TransactionData`, Base64-encoded.
    /// - `signature` is a serialized zkLogin signature, also Base64-encoded.
    /// - `intentScope` indicates whether `bytes` are to be parsed as a personal message or `TransactionData`.
    /// - `author` is the signer's address.
    public var verifyZkLoginSignature: VerifyZkLoginSignature { __data["verifyZkLoginSignature"] }

    /// VerifyZkLoginSignature
    ///
    /// Parent Type: `ZkLoginVerifyResult`
    public struct VerifyZkLoginSignature: GraphqlSchemaSuiKit.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GraphqlSchemaSuiKit.Objects.ZkLoginVerifyResult }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("success", Bool?.self),
        .field("error", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        VerifyZkLoginSignatureQuery.Data.VerifyZkLoginSignature.self
      ] }

      /// The boolean result of the verification. If true, errors should be empty.
      public var success: Bool? { __data["success"] }
      /// The error field capture reasons why the signature could not be verified, assuming the inputs are valid and there are no internal errors.
      public var error: String? { __data["error"] }
    }
  }
}
