// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GraphqlSchemaSuiKit.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GraphqlSchemaSuiKit.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GraphqlSchemaSuiKit.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GraphqlSchemaSuiKit.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  @_spi(Execution) public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Address": return GraphqlSchemaSuiKit.Objects.Address
    case "AddressOwner": return GraphqlSchemaSuiKit.Objects.AddressOwner
    case "Balance": return GraphqlSchemaSuiKit.Objects.Balance
    case "BalanceChange": return GraphqlSchemaSuiKit.Objects.BalanceChange
    case "BalanceChangeConnection": return GraphqlSchemaSuiKit.Objects.BalanceChangeConnection
    case "BalanceConnection": return GraphqlSchemaSuiKit.Objects.BalanceConnection
    case "CoinMetadata": return GraphqlSchemaSuiKit.Objects.CoinMetadata
    case "ConsensusAddressOwner": return GraphqlSchemaSuiKit.Objects.ConsensusAddressOwner
    case "ConsensusObjectCancelled": return GraphqlSchemaSuiKit.Objects.ConsensusObjectCancelled
    case "ConsensusObjectRead": return GraphqlSchemaSuiKit.Objects.ConsensusObjectRead
    case "DynamicField": return GraphqlSchemaSuiKit.Objects.DynamicField
    case "DynamicFieldConnection": return GraphqlSchemaSuiKit.Objects.DynamicFieldConnection
    case "Epoch": return GraphqlSchemaSuiKit.Objects.Epoch
    case "ExecutionResult": return GraphqlSchemaSuiKit.Objects.ExecutionResult
    case "Immutable": return GraphqlSchemaSuiKit.Objects.Immutable
    case "MoveFunction": return GraphqlSchemaSuiKit.Objects.MoveFunction
    case "MoveFunctionTypeParameter": return GraphqlSchemaSuiKit.Objects.MoveFunctionTypeParameter
    case "MoveModule": return GraphqlSchemaSuiKit.Objects.MoveModule
    case "MoveObject": return GraphqlSchemaSuiKit.Objects.MoveObject
    case "MoveObjectConnection": return GraphqlSchemaSuiKit.Objects.MoveObjectConnection
    case "MovePackage": return GraphqlSchemaSuiKit.Objects.MovePackage
    case "MoveType": return GraphqlSchemaSuiKit.Objects.MoveType
    case "MoveValue": return GraphqlSchemaSuiKit.Objects.MoveValue
    case "MutateConsensusStreamEnded": return GraphqlSchemaSuiKit.Objects.MutateConsensusStreamEnded
    case "Mutation": return GraphqlSchemaSuiKit.Objects.Mutation
    case "Object": return GraphqlSchemaSuiKit.Objects.Object
    case "ObjectChange": return GraphqlSchemaSuiKit.Objects.ObjectChange
    case "ObjectChangeConnection": return GraphqlSchemaSuiKit.Objects.ObjectChangeConnection
    case "ObjectOwner": return GraphqlSchemaSuiKit.Objects.ObjectOwner
    case "OpenMoveType": return GraphqlSchemaSuiKit.Objects.OpenMoveType
    case "PageInfo": return GraphqlSchemaSuiKit.Objects.PageInfo
    case "PerEpochConfig": return GraphqlSchemaSuiKit.Objects.PerEpochConfig
    case "Query": return GraphqlSchemaSuiKit.Objects.Query
    case "ReadConsensusStreamEnded": return GraphqlSchemaSuiKit.Objects.ReadConsensusStreamEnded
    case "Shared": return GraphqlSchemaSuiKit.Objects.Shared
    case "SimulationResult": return GraphqlSchemaSuiKit.Objects.SimulationResult
    case "Transaction": return GraphqlSchemaSuiKit.Objects.Transaction
    case "TransactionEffects": return GraphqlSchemaSuiKit.Objects.TransactionEffects
    case "UnchangedConsensusObjectConnection": return GraphqlSchemaSuiKit.Objects.UnchangedConsensusObjectConnection
    case "UserSignature": return GraphqlSchemaSuiKit.Objects.UserSignature
    case "Validator": return GraphqlSchemaSuiKit.Objects.Validator
    case "ZkLoginVerifyResult": return GraphqlSchemaSuiKit.Objects.ZkLoginVerifyResult
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
