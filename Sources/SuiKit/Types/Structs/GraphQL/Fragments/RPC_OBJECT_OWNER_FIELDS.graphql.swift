// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RPC_OBJECT_OWNER_FIELDS: SuiKit.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RPC_OBJECT_OWNER_FIELDS on ObjectOwner { __typename ... on AddressOwner { owner { __typename asObject { __typename address } asAddress { __typename address } } } ... on Parent { parent { __typename address } } ... on Shared { initialSharedVersion } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { SuiKit.Unions.ObjectOwner }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .inlineFragment(AsAddressOwner.self),
    .inlineFragment(AsParent.self),
    .inlineFragment(AsShared.self)
  ] }

  public var asAddressOwner: AsAddressOwner? { _asInlineFragment() }
  public var asParent: AsParent? { _asInlineFragment() }
  public var asShared: AsShared? { _asInlineFragment() }

  /// AsAddressOwner
  ///
  /// Parent Type: `AddressOwner`
  public struct AsAddressOwner: SuiKit.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.AddressOwner }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("owner", Owner?.self)
    ] }

    public var owner: Owner? { __data["owner"] }

    /// AsAddressOwner.Owner
    ///
    /// Parent Type: `Owner`
    public struct Owner: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Owner }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("asObject", AsObject?.self),
        .field("asAddress", AsAddress?.self)
      ] }

      public var asObject: AsObject? { __data["asObject"] }
      public var asAddress: AsAddress? { __data["asAddress"] }

      /// AsAddressOwner.Owner.AsObject
      ///
      /// Parent Type: `Object`
      public struct AsObject: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Object }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("address", SuiKit.SuiAddressApollo.self)
        ] }

        public var address: SuiKit.SuiAddressApollo { __data["address"] }
      }

      /// AsAddressOwner.Owner.AsAddress
      ///
      /// Parent Type: `Address`
      public struct AsAddress: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Address }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("address", SuiKit.SuiAddressApollo.self)
        ] }

        public var address: SuiKit.SuiAddressApollo { __data["address"] }
      }
    }
  }

  /// AsParent
  ///
  /// Parent Type: `Parent`
  public struct AsParent: SuiKit.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Parent }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("parent", Parent?.self)
    ] }

    public var parent: Parent? { __data["parent"] }

    /// AsParent.Parent
    ///
    /// Parent Type: `Owner`
    public struct Parent: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Owner }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("address", SuiKit.SuiAddressApollo.self)
      ] }

      public var address: SuiKit.SuiAddressApollo { __data["address"] }
    }
  }

  /// AsShared
  ///
  /// Parent Type: `Shared`
  public struct AsShared: SuiKit.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Shared }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("initialSharedVersion", SuiKit.UInt53Apollo.self)
    ] }

    public var initialSharedVersion: SuiKit.UInt53Apollo { __data["initialSharedVersion"] }
  }
}
