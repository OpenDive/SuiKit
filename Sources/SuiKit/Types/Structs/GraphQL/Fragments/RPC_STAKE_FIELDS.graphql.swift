// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_STAKE_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_STAKE_FIELDS on StakedSui { __typename principal activeEpoch { __typename epochId } requestEpoch { __typename epochId } asMoveObject { __typename contents { __typename json } asObject { __typename location } } estimatedReward activeEpoch { __typename referenceGasPrice } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.StakedSui }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("principal", SuiKit.BigIntApollo?.self),
    .field("activeEpoch", ActiveEpoch?.self),
    .field("requestEpoch", RequestEpoch?.self),
    .field("asMoveObject", AsMoveObject.self),
    .field("estimatedReward", SuiKit.BigIntApollo?.self),
  ] }

  /// The SUI that was initially staked.
  public var principal: SuiKit.BigIntApollo? { __data["principal"] }
  /// The epoch at which this stake became active
  public var activeEpoch: ActiveEpoch? { __data["activeEpoch"] }
  /// The epoch at which this object was requested to join a stake pool
  public var requestEpoch: RequestEpoch? { __data["requestEpoch"] }
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

  /// ActiveEpoch
  ///
  /// Parent Type: `Epoch`
  public struct ActiveEpoch: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Epoch }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("epochId", Int.self),
      .field("referenceGasPrice", SuiKit.BigIntApollo?.self),
    ] }

    /// The epoch's id as a sequence number that starts at 0 and it is incremented by one at every epoch change
    public var epochId: Int { __data["epochId"] }
    /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for
    public var referenceGasPrice: SuiKit.BigIntApollo? { __data["referenceGasPrice"] }
  }

  /// RequestEpoch
  ///
  /// Parent Type: `Epoch`
  public struct RequestEpoch: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { SuiKit.Objects.Epoch }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("epochId", Int.self),
    ] }

    /// The epoch's id as a sequence number that starts at 0 and it is incremented by one at every epoch change
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

    /// Displays the contents of the MoveObject in a JSON string and through graphql types.  Also
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
        .field("json", SuiKit.JSONApollo.self),
      ] }

      /// Representation of a Move value in JSON, where:
      ///
      /// - Addresses and UIDs are represented in canonical form, as JSON strings.
      /// - Bools are represented by JSON boolean literals.
      /// - u8, u16, and u32 are represented as JSON numbers.
      /// - u64, u128, and u256 are represented as JSON strings.
      /// - Vectors are represented by JSON arrays.
      /// - Structs are represented by JSON objects.
      /// - Empty optional values are represented by `null`.
      ///
      /// This form is offered as a less verbose convenience in cases where the layout of the type is
      /// known by the client.
      public var json: SuiKit.JSONApollo { __data["json"] }
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
        .field("location", SuiKit.SuiAddressApollo.self),
      ] }

      /// The address of the object, named as such to avoid conflict with the address type.
      public var location: SuiKit.SuiAddressApollo { __data["location"] }
    }
  }
}
