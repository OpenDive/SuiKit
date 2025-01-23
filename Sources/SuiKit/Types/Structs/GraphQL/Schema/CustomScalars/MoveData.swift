// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

/// The contents of a Move Value, corresponding to the following recursive type:
///
/// type MoveData =
///     { Address: SuiAddress }
///   | { UID:     SuiAddress }
///   | { ID:      SuiAddress }
///   | { Bool:    bool }
///   | { Number:  BigInt }
///   | { String:  string }
///   | { Vector:  [MoveData] }
///   | { Option:   MoveData? }
///   | { Struct:  [{ name: string , value: MoveData }] }
///   | { Variant: {
///       name: string,
///       fields: [{ name: string, value: MoveData }],
///   }
public typealias MoveDataApollo = String
