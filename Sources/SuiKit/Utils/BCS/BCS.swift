//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/19/23.
//

import Foundation
import Base58Swift
import AnyCodable

//public enum TypeValue {
//    case interface(TypeInterface)
//    case string(String)
//
//    var type: String {
//        switch self {
//        case .interface:
//            return "interface"
//        case .string:
//            return "string"
//        }
//    }
//
//    var interface: TypeInterface? {
//        switch self {
//        case .interface(let typeInterface):
//            return typeInterface
//        case .string:
//            return nil
//        }
//    }
//
//    var string: String? {
//        switch self {
//        case .interface:
//            return nil
//        case .string(let string):
//            return string
//        }
//    }
//}
//
//public typealias EncodeCB = (_ writer: Serializer, _ data: AnyCodable, _ typeParams: [TypeName], _ typeMap: [String: TypeName]) throws -> Serializer
//public typealias DecodeCB = (_ reader: Deserializer, _ typeParams: [TypeName], _ typeMap: [String: TypeName]) -> AnyCodable
//public typealias ValidateCB = (AnyCodable) -> Bool
//
//public struct BCS {
//    public static let U8 = "u8"
//    public static let U16 = "u16"
//    public static let U32 = "u32"
//    public static let U64 = "u64"
//    public static let U128 = "u128"
//    public static let U256 = "u256"
//    public static let BOOL = "bool"
//    public static let vector = "vector"
//    public static let ADDRESS = "address"
//    public static let STRING = "string"
//    public static let HEX = "hex-string"
//    public static let BASE58 = "base58-string"
//    public static let BASE64 = "base64-string"
//
//    public let schema: BcsConfig
//
//    public var types: [String: TypeValue] = [:]
//    public var counter: UInt = 0
//
//    public init(schema: BCS) {
//        self.schema = schema.schema
//        self.types = schema.types
//    }
//
//    public init(schema: BcsConfig) {
//        self.schema = schema
//    }
//
//    public static func object<T>(_ deserializer: Deserializer) throws -> T? {
//        let data = try Deserializer.toBytes(deserializer)
//    }
//
//    private func de<T>(type: TypeName, data: Any, encoding: Encoding?) throws -> T? {
//        var dataValue: Data? = nil
//        if let dataStr = data as? String {
//            guard let encoding else {
//                throw SuiError.notImplemented
//            }
//            dataValue = try self.decodeStr(data: dataStr, encoding: encoding)
//        } else {
//            dataValue = data as? Data
//        }
//
//        if type.value(data: type) == "string", type.type == "multiple" {
//            var typeNameResult = try parseTypeName(name: type)
////            return
//        }
//    }
//
////    private func getTypeInterface(type: String) -> T
//
//    private func parseTypeName(name: TypeName) throws -> TypeNameResult {
//        switch name {
//        case let .single(name):
//            let (left, right) = schema.genericSeparators ?? ("<", ">")
//            guard let lBound = name.firstIndex(of: Character(left)),
//                  let rBound = name.lastIndex(of: Character(right)) else {
//                if name.contains(left) != name.contains(right) {
//                    throw NSError(domain: "Unclosed generic in name '\(name)'", code: 1, userInfo: nil)
//                } else {
//                    return TypeNameResult(name: name, params: [])
//                }
//            }
//
//            let typeName = String(name[..<lBound])
//            let params = name[name.index(after: lBound)...name.index(before: rBound)]
//                .split(separator: ",")
//                .map { TypeName.single(String($0.trimmingCharacters(in: .whitespaces))) }
//
//            return TypeNameResult(name: typeName, params: params)
//        case let .multiple(typeName, params):
//            return TypeNameResult(name: typeName, params: params)
//        }
//    }
//
//    private func decodeStr(data: String, encoding: Encoding) throws -> Data? {
//        switch encoding {
//        case .base58:
//            guard let decoded = Base58.base58Decode(data) else { throw SuiError.notImplemented }
//            return Data(decoded)
//        case .base64:
//            return Data(B64.fromB64(sBase64: data))
//        case .hex:
//            return Data(try Hex.fromHex(hexStr: data))
//        }
//    }
//
//    private mutating func tempKey() -> String {
//        return "bcs-struct-\(self.counter+=1)"
//    }
//
//    private func hasType(type: String) -> Bool {
//        return self.types[type] != nil
//    }
//
//    public mutating func registerType(typeName: TypeName, encodeCb: @escaping EncodeCB, decodeCb: @escaping DecodeCB, validateCb: @escaping ValidateCB = { _ in true }) throws -> BCS {
//        let result = try self.parseTypeName(name: typeName)
//        struct TypeValueInterfaceObject: TypeInterface {
//            let parseTypeName: TypeNameResult
//            let encodeCb: EncodeCB
//            let decodeCb: DecodeCB
//            let validateCb: ValidateCB
//
//            public init(
//                parseTypeName: TypeNameResult,
//                encodeCb: @escaping EncodeCB,
//                decodeCb: @escaping DecodeCB,
//                validateCb: @escaping ValidateCB
//            ) {
//                self.parseTypeName = parseTypeName
//                self.encodeCb = encodeCb
//                self.decodeCb = decodeCb
//                self.validateCb = validateCb
//            }
//
//            func encode(self: BCS, data: AnyCodable, options: BcsWriterOptions?, typeParams: [TypeName]) throws -> Serializer {
//                let generics = parseTypeName.params.map { $0.value(data: $0) }
//                var typeMap: [String: TypeName] = [:]
//
//                for (index, value) in generics.enumerated() {
//                    typeMap[value] = typeParams[index]
//                }
//
//                if let options {
//                    return try _encodeRaw(writer: Serializer(options: options), data: data, typeParams: typeParams, TypeMap: typeMap)
//                } else {
//                    throw SuiError.notImplemented
//                }
//            }
//
//            func decode(self: BCS, data: Data, typeParams: [TypeName]) throws -> AnyCodable {
//                let generics = parseTypeName.params.map { $0.value(data: $0) }
//                var typeMap: [String: TypeName] = [:]
//
//                for (index, value) in generics.enumerated() {
//                    typeMap[value] = typeParams[index]
//                }
//
//                return _decodeRaw(reader: Deserializer(data: data), typeParams: typeParams, typeMap: typeMap)
//            }
//
//            func _encodeRaw(writer: Serializer, data: AnyCodable, typeParams: [TypeName], TypeMap: [String : TypeName]) throws -> Serializer {
//                if validateCb(data) {
//                    return try encodeCb(writer, data, typeParams, TypeMap)
//                } else {
//                    throw SuiError.notImplemented
//                }
//            }
//
//            func _decodeRaw(reader: Deserializer, typeParams: [TypeName], typeMap: [String : TypeName]) -> AnyCodable {
//                return decodeCb(reader, typeParams, typeMap)
//            }
//        }
//        self.types[result.name] = TypeValue.interface(TypeValueInterfaceObject(parseTypeName: result, encodeCb: encodeCb, decodeCb: decodeCb, validateCb: validateCb))
//        return self
//    }
//
//    public mutating func registerAddressType(name: String, length: UInt, encoding: Encoding = .hex) throws -> BCS {
//        func encodeB64(writer: Serializer, data: AnyCodable, typeName: [TypeName], typeMap: [String: TypeName]) throws -> Serializer {
//            guard let dataString = data.value as? String else { throw SuiError.notImplemented }
//            let dataB64 = B64.fromB64(sBase64: dataString)
//            try dataB64.forEach { byte in
//                do {
//                    try Serializer.u8(writer, byte)
//                } catch {
//                    throw SuiError.notImplemented
//                }
//            }
//            return writer
//        }
//
//        func decodeB64(reader: Deserializer, typeParams: [TypeName], typeMap: [String: TypeName]) -> AnyCodable {
//            return AnyCodable(B64.toB64([UInt8](reader.output())))
//        }
//
//        func encodeHex(writer: Serializer, data: AnyCodable, typeName: [TypeName], typeMap: [String: TypeName]) throws -> Serializer {
//            guard let dataString = data.value as? String else { throw SuiError.notImplemented }
//            let dataHex = try Hex.fromHex(hexStr: dataString)
//            try dataHex.forEach { byte in
//                do {
//                    try Serializer.u8(writer, byte)
//                } catch {
//                    throw SuiError.notImplemented
//                }
//            }
//            return writer
//        }
//
//        func decodeHex(reader: Deserializer, typeParams: [TypeName], typeMap: [String: TypeName]) -> AnyCodable {
//            return AnyCodable(Hex.toHex(bytes: [UInt8](reader.output())))
//        }
//
//        switch encoding {
//        case .base64:
//            return try registerType(typeName: TypeName.single(name), encodeCb: encodeB64, decodeCb: decodeB64)
//        case .hex:
//            return try registerType(typeName: TypeName.single(name), encodeCb: encodeHex, decodeCb: decodeHex)
//        default:
//            throw SuiError.notImplemented
//        }
//    }
//
//    public func registerVectorType(typeName: String) throws -> BCS {
//        let result = try self.parseTypeName(name: TypeName.single(typeName))
//        if result.params.count > 1 {
//            throw SuiError.notImplemented
//        }
//
//        func encodeVector(writer: Serializer, data: AnyCodable, typeName: [TypeName], typeMap: [String: TypeName]) throws -> Serializer {
//            guard let dataVec = data.value as? [AnyCodable] else { throw SuiError.notImplemented }
//            try writer.vec(dataVec) { ser, el, idx, count in
//                guard !typeName.isEmpty else { throw SuiError.notImplemented }
//                let elementType: TypeName = typeName[0]
//                let elementResult = try self.parseTypeName(name: elementType)
//
//                if self.hasType(type: elementResult.name) {
//                    return self.getTypeInterface(type: elementResult.name)._encodeRaw(writer: writer, data: el, typeParams: typeName, TypeMap: typeMap)
//                }
//            }
//        }
//    }
//
//    public func getTypeInterface(type: String) throws -> TypeInterface {
//        var typeInterface = self.types[type]
//
//        if let typeInterface {
//            if typeInterface.type == "string" {
//                var chain: [String] = []
//                var typeInterfaceChanged = typeInterface
//                while typeInterfaceChanged.type == "string" {
//                    if typeInterfaceChanged.string != nil {
//                        if chain.contains(typeInterfaceChanged.string!) {
//                            throw SuiError.notImplemented
//                        }
//                        chain.append(typeInterfaceChanged.string!)
//                        if self.types[typeInterfaceChanged.string!] != nil {
//                            typeInterfaceChanged = self.types[typeInterfaceChanged.string!]!
//                        } else {
//                            throw SuiError.notImplemented
//                        }
//                    }
//                }
//            }
//
//            return typeInterface.interface!
//        } else {
//            throw SuiError.notImplemented
//        }
//    }
//}
//
//public protocol TypeInterface {
//    func encode(self: BCS, data: AnyCodable, options: BcsWriterOptions?, typeParams: [TypeName]) throws -> Serializer
//    func decode(self: BCS, data: Data, typeParams: [TypeName]) throws -> AnyCodable
//
//    func _encodeRaw(writer: Serializer, data: AnyCodable, typeParams: [TypeName], TypeMap: [String: TypeName]) throws -> Serializer
//    func _decodeRaw(reader: Deserializer, typeParams: [TypeName], typeMap: [String: TypeName]) -> AnyCodable
//}
