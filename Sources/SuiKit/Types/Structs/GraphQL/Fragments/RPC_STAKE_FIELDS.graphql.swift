// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_STAKE_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_STAKE_FIELDS on StakedSui { __typename principal activatedEpoch { __typename epochId referenceGasPrice } requestedEpoch { __typename epochId } asMoveObject { __typename contents { __typename JSONApollo } asObject { __typename address } } estimatedReward }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.StakedSui }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("principal", SuiKit.BigIntApollo?.self),
    .field("activatedEpoch", ActivatedEpoch?.self),
    .field("requestedEpoch", RequestedEpoch?.self),
    .field("asMoveObject", AsMoveObject.self),
    .field("estimatedReward", SuiKit.BigIntApollo?.self),
  ] }

  /// The SUI that was initially staked.
  public var principal: SuiKit.BigIntApollo? { __data["principal"] }
  /// The epoch at which this stake became active
  public var activatedEpoch: ActivatedEpoch? { __data["activatedEpoch"] }
  /// The epoch at which this object was requested to join a stake pool
  public var requestedEpoch: RequestedEpoch? { __data["requestedEpoch"] }
  /// The corresponding `0x3::staking_pool::StakedSui` Move object.
  public var asMoveObject: AsMoveObject { __data["asMoveObject"] }
  /// The estimated reward for this stake object, calculated as:
  ///
  /// principal * (initial_stake_rate / current_stake_rate - 1.0)
  ///
  /// Or 0, if this value is negative, where:
  ///
  /// - `initial_stake_rate` is the stake rate at the epoch this stake was activated at.
  /// - `current_stake_rate` is the stake rate in the current epoch.
  ///
  /// This value is only available if the stake is active.
  public var estimatedReward: SuiKit.BigIntApollo? { __data["estimatedReward"] }

  /// ActivatedEpoch
  ///
  /// Parent Type: `Epoch`
  public struct ActivatedEpoch: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Epoch }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("epochId", Int.self),
      .field("referenceGasPrice", SuiKit.BigIntApollo?.self),
    ] }

    /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change
    public var epochId: Int { __data["epochId"] }
    /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for
    public var referenceGasPrice: SuiKit.BigIntApollo? { __data["referenceGasPrice"] }
  }

  /// RequestedEpoch
  ///
  /// Parent Type: `Epoch`
  public struct RequestedEpoch: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Epoch }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("epochId", Int.self),
    ] }

    /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change
    public var epochId: Int { __data["epochId"] }
  }

  /// AsMoveObject
  ///
  /// Parent Type: `MoveObject`
  public struct AsMoveObject: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveObject }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("contents", Contents?.self),
      .field("asObject", AsObject.self),
    ] }

    /// Displays the contents of the MoveObject in a JSONApollo string and through graphql types.  Also
    /// provides the flat representation of the type signature, and the bcs of the corresponding
    /// data
    public var contents: Contents? { __data["contents"] }
    /// Attempts to convert the Move object into an Object
    /// This provides additional information such as version and digest on the top-level
    public var asObject: AsObject { __data["asObject"] }

    /// AsMoveObject.Contents
    ///
    /// Parent Type: `MoveValue`
    public struct Contents: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.MoveValue }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("JSONApollo", SuiKit.JSONApollo.self),
      ] }

      /// Representation of a Move value in JSONApollo, where:
      ///
      /// - Addresses, IDs, and UIDs are represented in canonical form, as JSONApollo strings.
      /// - Bools are represented by JSONApollo boolean literals.
      /// - u8, u16, and u32 are represented as JSONApollo numbers.
      /// - u64, u128, and u256 are represented as JSONApollo strings.
      /// - Vectors are represented by JSONApollo arrays.
      /// - Structs are represented by JSONApollo objects.
      /// - Empty optional values are represented by `null`.
      ///
      /// This form is offered as a less verbose convenience in cases where the layout of the type is
      /// known by the client.
      public var JSONApollo: SuiKit.JSONApollo { __data["JSONApollo"] }
    }

    /// AsMoveObject.AsObject
    ///
    /// Parent Type: `Object`
    public struct AsObject: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Object }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("address", SuiKit.SuiAddressApollo.self),
      ] }

      /// The address of the object, named as such to avoid conflict with the address type.
      public var address: SuiKit.SuiAddressApollo { __data["address"] }
    }
  }
}
