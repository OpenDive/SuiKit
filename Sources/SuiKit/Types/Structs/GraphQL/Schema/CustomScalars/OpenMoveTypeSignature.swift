// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

/// The shape of an abstract Move Type (a type that can contain free type parameters, and can optionally be taken by reference), corresponding to the following recursive type:
///
/// type OpenMoveTypeSignature = {
///   ref: ("&" | "&mut")?,
///   body: OpenMoveTypeSignatureBody,
/// }
///
/// type OpenMoveTypeSignatureBody =
///     "address"
///   | "bool"
///   | "u8" | "u16" | ... | "u256"
///   | { vector: OpenMoveTypeSignatureBody }
///   | {
///       datatype {
///         package: string,
///         module: string,
///         type: string,
///         typeParameters: [OpenMoveTypeSignatureBody]
///       }
///     }
///   | { typeParameter: number }
public typealias OpenMoveTypeSignatureApollo = String
