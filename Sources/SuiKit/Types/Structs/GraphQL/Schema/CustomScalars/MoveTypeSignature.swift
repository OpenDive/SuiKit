// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

/// The signature of a concrete Move Type (a type with all its type parameters instantiated with concrete types, that contains no references), corresponding to the following recursive type:
///
/// type MoveTypeSignature =
///     "address"
///   | "bool"
///   | "u8" | "u16" | ... | "u256"
///   | { vector: MoveTypeSignature }
///   | {
///       datatype: {
///         package: string,
///         module: string,
///         type: string,
///         typeParameters: [MoveTypeSignature],
///       }
///     }
public typealias MoveTypeSignatureApollo = String
