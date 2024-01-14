// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

/// The shape of a concrete Move Type (a type with all its type parameters instantiated with concrete types), corresponding to the following recursive type:
///
/// type MoveTypeLayoutApollo =
///     "address"
///   | "bool"
///   | "u8" | "u16" | ... | "u256"
///   | { vector: MoveTypeLayoutApollo }
///   | { struct: [{ name: string, layout: MoveTypeLayoutApollo }] }
public typealias MoveTypeLayoutApollo = String
