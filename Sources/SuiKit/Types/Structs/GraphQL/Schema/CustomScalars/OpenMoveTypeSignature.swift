// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

/// The shape of an abstract Move Type (a type that can contain free type parameters, and can optionally be taken by reference), corresponding to the following recursive type:
///
/// type OpenMoveTypeSignatureApollo = {
///   ref: ("&" | "&mut")?,
///   body: OpenMoveTypeSignatureApolloBody,
/// }
///
/// type OpenMoveTypeSignatureApolloBody =
///     "address"
///   | "bool"
///   | "u8" | "u16" | ... | "u256"
///   | { vector: OpenMoveTypeSignatureApolloBody }
///   | {
///       datatype {
///         package: string,
///         module: string,
///         type: string,
///         typeParameters: [OpenMoveTypeSignatureApolloBody]
///       }
///     }
///   | { typeParameter: number }
public typealias OpenMoveTypeSignatureApollo = String
