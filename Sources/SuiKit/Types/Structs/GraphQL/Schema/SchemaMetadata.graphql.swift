// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == SuiKit.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == SuiKit.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == SuiKit.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == SuiKit.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Address": return SuiKit.Objects.Address
    case "AddressOwner": return SuiKit.Objects.AddressOwner
    case "AuthenticatorStateCreateTransaction": return SuiKit.Objects.AuthenticatorStateCreateTransaction
    case "AuthenticatorStateExpireTransaction": return SuiKit.Objects.AuthenticatorStateExpireTransaction
    case "AuthenticatorStateUpdateTransaction": return SuiKit.Objects.AuthenticatorStateUpdateTransaction
    case "Balance": return SuiKit.Objects.Balance
    case "BalanceChange": return SuiKit.Objects.BalanceChange
    case "BalanceChangeConnection": return SuiKit.Objects.BalanceChangeConnection
    case "BalanceConnection": return SuiKit.Objects.BalanceConnection
    case "BridgeCommitteeInitTransaction": return SuiKit.Objects.BridgeCommitteeInitTransaction
    case "BridgeStateCreateTransaction": return SuiKit.Objects.BridgeStateCreateTransaction
    case "ChangeEpochTransaction": return SuiKit.Objects.ChangeEpochTransaction
    case "Checkpoint": return SuiKit.Objects.Checkpoint
    case "CheckpointConnection": return SuiKit.Objects.CheckpointConnection
    case "Coin": return SuiKit.Objects.Coin
    case "CoinConnection": return SuiKit.Objects.CoinConnection
    case "CoinDenyListStateCreateTransaction": return SuiKit.Objects.CoinDenyListStateCreateTransaction
    case "CoinMetadata": return SuiKit.Objects.CoinMetadata
    case "ConsensusCommitPrologueTransaction": return SuiKit.Objects.ConsensusCommitPrologueTransaction
    case "ConsensusV2": return SuiKit.Objects.ConsensusV2
    case "DisplayEntry": return SuiKit.Objects.DisplayEntry
    case "DryRunEffect": return SuiKit.Objects.DryRunEffect
    case "DryRunMutation": return SuiKit.Objects.DryRunMutation
    case "DryRunResult": return SuiKit.Objects.DryRunResult
    case "DryRunReturn": return SuiKit.Objects.DryRunReturn
    case "DynamicField": return SuiKit.Objects.DynamicField
    case "DynamicFieldConnection": return SuiKit.Objects.DynamicFieldConnection
    case "EndOfEpochTransaction": return SuiKit.Objects.EndOfEpochTransaction
    case "EndOfEpochTransactionKindConnection": return SuiKit.Objects.EndOfEpochTransactionKindConnection
    case "Epoch": return SuiKit.Objects.Epoch
    case "Event": return SuiKit.Objects.Event
    case "EventConnection": return SuiKit.Objects.EventConnection
    case "ExecutionResult": return SuiKit.Objects.ExecutionResult
    case "GasCoin": return SuiKit.Objects.GasCoin
    case "GasCostSummary": return SuiKit.Objects.GasCostSummary
    case "GenesisTransaction": return SuiKit.Objects.GenesisTransaction
    case "Immutable": return SuiKit.Objects.Immutable
    case "Input": return SuiKit.Objects.Input
    case "MoveDatatype": return SuiKit.Objects.MoveDatatype
    case "MoveEnum": return SuiKit.Objects.MoveEnum
    case "MoveEnumConnection": return SuiKit.Objects.MoveEnumConnection
    case "MoveEnumVariant": return SuiKit.Objects.MoveEnumVariant
    case "MoveField": return SuiKit.Objects.MoveField
    case "MoveFunction": return SuiKit.Objects.MoveFunction
    case "MoveFunctionConnection": return SuiKit.Objects.MoveFunctionConnection
    case "MoveFunctionTypeParameter": return SuiKit.Objects.MoveFunctionTypeParameter
    case "MoveModule": return SuiKit.Objects.MoveModule
    case "MoveModuleConnection": return SuiKit.Objects.MoveModuleConnection
    case "MoveObject": return SuiKit.Objects.MoveObject
    case "MoveObjectConnection": return SuiKit.Objects.MoveObjectConnection
    case "MovePackage": return SuiKit.Objects.MovePackage
    case "MoveStruct": return SuiKit.Objects.MoveStruct
    case "MoveStructConnection": return SuiKit.Objects.MoveStructConnection
    case "MoveStructTypeParameter": return SuiKit.Objects.MoveStructTypeParameter
    case "MoveType": return SuiKit.Objects.MoveType
    case "MoveValue": return SuiKit.Objects.MoveValue
    case "Mutation": return SuiKit.Objects.Mutation
    case "Object": return SuiKit.Objects.Object
    case "ObjectChange": return SuiKit.Objects.ObjectChange
    case "ObjectChangeConnection": return SuiKit.Objects.ObjectChangeConnection
    case "ObjectConnection": return SuiKit.Objects.ObjectConnection
    case "OpenMoveType": return SuiKit.Objects.OpenMoveType
    case "Owner": return SuiKit.Objects.Owner
    case "PageInfo": return SuiKit.Objects.PageInfo
    case "Parent": return SuiKit.Objects.Parent
    case "ProgrammableTransactionBlock": return SuiKit.Objects.ProgrammableTransactionBlock
    case "ProtocolConfigAttr": return SuiKit.Objects.ProtocolConfigAttr
    case "ProtocolConfigFeatureFlag": return SuiKit.Objects.ProtocolConfigFeatureFlag
    case "ProtocolConfigs": return SuiKit.Objects.ProtocolConfigs
    case "Query": return SuiKit.Objects.Query
    case "RandomnessStateCreateTransaction": return SuiKit.Objects.RandomnessStateCreateTransaction
    case "RandomnessStateUpdateTransaction": return SuiKit.Objects.RandomnessStateUpdateTransaction
    case "Result": return SuiKit.Objects.Result
    case "SafeMode": return SuiKit.Objects.SafeMode
    case "Shared": return SuiKit.Objects.Shared
    case "StakeSubsidy": return SuiKit.Objects.StakeSubsidy
    case "StakedSui": return SuiKit.Objects.StakedSui
    case "StakedSuiConnection": return SuiKit.Objects.StakedSuiConnection
    case "StorageFund": return SuiKit.Objects.StorageFund
    case "SuinsRegistration": return SuiKit.Objects.SuinsRegistration
    case "SuinsRegistrationConnection": return SuiKit.Objects.SuinsRegistrationConnection
    case "SystemParameters": return SuiKit.Objects.SystemParameters
    case "TransactionBlock": return SuiKit.Objects.TransactionBlock
    case "TransactionBlockConnection": return SuiKit.Objects.TransactionBlockConnection
    case "TransactionBlockEffects": return SuiKit.Objects.TransactionBlockEffects
    case "Validator": return SuiKit.Objects.Validator
    case "ValidatorConnection": return SuiKit.Objects.ValidatorConnection
    case "ValidatorCredentials": return SuiKit.Objects.ValidatorCredentials
    case "ValidatorSet": return SuiKit.Objects.ValidatorSet
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
