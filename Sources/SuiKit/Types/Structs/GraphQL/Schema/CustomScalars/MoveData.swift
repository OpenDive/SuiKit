// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

/// The contents of a Move Value, corresponding to the following recursive type:
///
/// type MoveDataApollo =
///     { Address: SuiAddressApolloApollo }
///   | { UID:     SuiAddressApolloApollo }
///   | { Bool:    bool }
///   | { Number:  BigIntApollo }
///   | { String:  string }
///   | { Vector:  [MoveDataApollo] }
///   | { Option:   MoveDataApollo? }
///   | { Struct:  [{ name: string, value: MoveDataApollo }] }
public typealias MoveDataApollo = String
