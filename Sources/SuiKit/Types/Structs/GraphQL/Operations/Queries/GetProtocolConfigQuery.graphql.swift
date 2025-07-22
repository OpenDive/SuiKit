// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetProtocolConfigQuery: GraphQLQuery {
  public static let operationName: String = "getProtocolConfig"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getProtocolConfig($protocolVersion: UInt53) { protocolConfig(protocolVersion: $protocolVersion) { __typename protocolVersion configs { __typename key value } featureFlags { __typename key value } } }"#
    ))

  public var protocolVersion: GraphQLNullable<UInt53Apollo>

  public init(protocolVersion: GraphQLNullable<UInt53Apollo>) {
    self.protocolVersion = protocolVersion
  }

  public var __variables: Variables? { ["protocolVersion": protocolVersion] }

  public struct Data: SuiKit.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("protocolConfig", ProtocolConfig.self, arguments: ["protocolVersion": .variable("protocolVersion")])
    ] }

    /// Fetch the protocol config by protocol version (defaults to the latest protocol
    /// version known to the GraphQL service).
    public var protocolConfig: ProtocolConfig { __data["protocolConfig"] }

    /// ProtocolConfig
    ///
    /// Parent Type: `ProtocolConfigs`
    public struct ProtocolConfig: SuiKit.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ProtocolConfigs }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("protocolVersion", SuiKit.UInt53Apollo.self),
        .field("configs", [Config].self),
        .field("featureFlags", [FeatureFlag].self)
      ] }

      /// The protocol is not required to change on every epoch boundary, so the protocol version
      /// tracks which change to the protocol these configs are from.
      public var protocolVersion: SuiKit.UInt53Apollo { __data["protocolVersion"] }
      /// List all available configurations and their values.  These configurations can take any value
      /// (but they will all be represented in string form), and do not include feature flags.
      public var configs: [Config] { __data["configs"] }
      /// List all available feature flags and their values.  Feature flags are a form of boolean
      /// configuration that are usually used to gate features while they are in development.  Once a
      /// flag has been enabled, it is rare for it to be disabled.
      public var featureFlags: [FeatureFlag] { __data["featureFlags"] }

      /// ProtocolConfig.Config
      ///
      /// Parent Type: `ProtocolConfigAttr`
      public struct Config: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ProtocolConfigAttr }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("key", String.self),
          .field("value", String?.self)
        ] }

        public var key: String { __data["key"] }
        public var value: String? { __data["value"] }
      }

      /// ProtocolConfig.FeatureFlag
      ///
      /// Parent Type: `ProtocolConfigFeatureFlag`
      public struct FeatureFlag: SuiKit.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { SuiKit.Objects.ProtocolConfigFeatureFlag }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("key", String.self),
          .field("value", Bool.self)
        ] }

        public var key: String { __data["key"] }
        public var value: Bool { __data["value"] }
      }
    }
  }
}
