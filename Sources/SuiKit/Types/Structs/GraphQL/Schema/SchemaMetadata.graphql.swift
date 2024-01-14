// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == SuiKit.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == SuiKit.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == SuiKit.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == SuiKit.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return SuiKit.Objects.Query
    case "TransactionBlockConnection": return SuiKit.Objects.TransactionBlockConnection
    case "PageInfo": return SuiKit.Objects.PageInfo
    case "TransactionBlock": return SuiKit.Objects.TransactionBlock
    case "Address": return SuiKit.Objects.Address
    case "Object": return SuiKit.Objects.Object
    case "Owner": return SuiKit.Objects.Owner
    case "EventConnection": return SuiKit.Objects.EventConnection
    case "Event": return SuiKit.Objects.Event
    case "MoveModule": return SuiKit.Objects.MoveModule
    case "MovePackage": return SuiKit.Objects.MovePackage
    case "MoveType": return SuiKit.Objects.MoveType
    case "TransactionBlockEffects": return SuiKit.Objects.TransactionBlockEffects
    case "Checkpoint": return SuiKit.Objects.Checkpoint
    case "BalanceChange": return SuiKit.Objects.BalanceChange
    case "GasEffects": return SuiKit.Objects.GasEffects
    case "GasCostSummary": return SuiKit.Objects.GasCostSummary
    case "Epoch": return SuiKit.Objects.Epoch
    case "ObjectChange": return SuiKit.Objects.ObjectChange
    case "MoveObject": return SuiKit.Objects.MoveObject
    case "MoveValue": return SuiKit.Objects.MoveValue
    case "CoinConnection": return SuiKit.Objects.CoinConnection
    case "Coin": return SuiKit.Objects.Coin
    case "ValidatorSet": return SuiKit.Objects.ValidatorSet
    case "Validator": return SuiKit.Objects.Validator
    case "ValidatorCredentials": return SuiKit.Objects.ValidatorCredentials
    case "CheckpointConnection": return SuiKit.Objects.CheckpointConnection
    case "SuinsRegistrationConnection": return SuiKit.Objects.SuinsRegistrationConnection
    case "SuinsRegistration": return SuiKit.Objects.SuinsRegistration
    case "MoveStruct": return SuiKit.Objects.MoveStruct
    case "MoveField": return SuiKit.Objects.MoveField
    case "OpenMoveType": return SuiKit.Objects.OpenMoveType
    case "MoveStructTypeParameter": return SuiKit.Objects.MoveStructTypeParameter
    case "DynamicFieldConnection": return SuiKit.Objects.DynamicFieldConnection
    case "DynamicField": return SuiKit.Objects.DynamicField
    case "DisplayEntry": return SuiKit.Objects.DisplayEntry
    case "MoveFunction": return SuiKit.Objects.MoveFunction
    case "MoveFunctionTypeParameter": return SuiKit.Objects.MoveFunctionTypeParameter
    case "CoinMetadata": return SuiKit.Objects.CoinMetadata
    case "ObjectConnection": return SuiKit.Objects.ObjectConnection
    case "MoveModuleConnection": return SuiKit.Objects.MoveModuleConnection
    case "MoveStructConnection": return SuiKit.Objects.MoveStructConnection
    case "MoveFunctionConnection": return SuiKit.Objects.MoveFunctionConnection
    case "ProtocolConfigs": return SuiKit.Objects.ProtocolConfigs
    case "ProtocolConfigAttr": return SuiKit.Objects.ProtocolConfigAttr
    case "ProtocolConfigFeatureFlag": return SuiKit.Objects.ProtocolConfigFeatureFlag
    case "SafeMode": return SuiKit.Objects.SafeMode
    case "StakeSubsidy": return SuiKit.Objects.StakeSubsidy
    case "StorageFund": return SuiKit.Objects.StorageFund
    case "SystemParameters": return SuiKit.Objects.SystemParameters
    case "Balance": return SuiKit.Objects.Balance
    case "BalanceConnection": return SuiKit.Objects.BalanceConnection
    case "StakedSuiConnection": return SuiKit.Objects.StakedSuiConnection
    case "StakedSui": return SuiKit.Objects.StakedSui
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
