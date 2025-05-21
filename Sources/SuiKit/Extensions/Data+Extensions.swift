import Foundation
import CommonCrypto

extension Data {
    /// Converts data to a hexadecimal string representation
    /// - Parameter uppercase: Whether the hex string should use uppercase characters
    /// - Returns: A hexadecimal string representation of the data
    public func hexString(uppercase: Bool = false) -> String {
        let format = uppercase ? "%02X" : "%02x"
        return self.map { String(format: format, $0) }.joined()
    }
    
    /// Alias for backward compatibility
    public func hexEncodedString(uppercase: Bool = false) -> String {
        return hexString(uppercase: uppercase)
    }
    
    /// Computes the SHA-256 hash of the data
    /// - Returns: The SHA-256 hash as Data
    public func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
    
    /// Sets bytes at the specified offset
    /// - Parameters:
    ///   - bytes: The bytes to set
    ///   - offset: The offset at which to set the bytes
    /// - Throws: Error if the operation would exceed the data's bounds
    public mutating func set(_ bytes: [UInt8], offset: Int = 0) throws {
        guard offset >= 0 && offset + bytes.count <= self.count else {
            throw SuiError.customError(message: "Offset out of bounds")
        }
        
        self.withUnsafeMutableBytes { ptr in
            guard let baseAddress = ptr.baseAddress else { return }
            let offsetPtr = baseAddress.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
            bytes.withUnsafeBufferPointer { bufferPtr in
                guard let source = bufferPtr.baseAddress else { return }
                memcpy(offsetPtr, source, bytes.count)
            }
        }
    }
    
    /// Convenience initializer with hexadecimal string
    /// - Parameter hexString: The hexadecimal string (with or without 0x prefix)
    public init?(hexString: String) {
        var hex = hexString
        if hex.hasPrefix("0x") {
            hex = String(hex.dropFirst(2))
        }
        
        // Check for valid hex string (even length, valid characters)
        if hex.count % 2 != 0 || hex.contains(where: { !$0.isHexDigit }) {
            return nil
        }
        
        self.init(capacity: hex.count / 2)
        
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let byte = UInt8(hex[index..<nextIndex], radix: 16) {
                self.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
    }
    
    /// Converts hexadecimal string representation of some bytes into actual bytes.
    /// - Parameter hex: bytes represented as string.
    /// - Returns: optional raw bytes.
    public static func fromHex(_ hex: String) -> Data? {
        let hex = hex.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !hex.isEmpty else { return nil }
        guard hex != "0x" else { return Data() }
        
        var hexString = hex
        if hex.hasPrefix("0x") {
            hexString = String(hex.dropFirst(2))
        }
        
        // Check for valid hex string
        guard hexString.count % 2 == 0 && hexString.allSatisfy({ $0.isHexDigit }) else {
            return nil
        }
        
        var data = Data(capacity: hexString.count / 2)
        var index = hexString.startIndex
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
                return nil
            }
            data.append(byte)
            index = nextIndex
        }
        
        return data
    }
    
    /// Sets the length of the data to the given length, padding with zeros on the left
    func setLengthLeft(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(self.count)
        if existingLength == toBytes {
            return Data(self)
        } else if existingLength > toBytes {
            return nil
        }
        var data: Data
        if isNegative {
            data = Data(repeating: UInt8(255), count: Int(toBytes - existingLength))
        } else {
            data = Data(repeating: UInt8(0), count: Int(toBytes - existingLength))
        }
        data.append(self)
        return data
    }

    /// Sets the length of the data to the given length, padding with zeros on the right
    func setLengthRight(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(self.count)
        if existingLength == toBytes {
            return Data(self)
        } else if existingLength > toBytes {
            return nil
        }
        var data: Data = Data()
        data.append(self)
        if isNegative {
            data.append(Data(repeating: UInt8(255), count: Int(toBytes - existingLength)))
        } else {
            data.append(Data(repeating: UInt8(0), count: Int(toBytes - existingLength)))
        }
        return data
    }
    
    /// Two octet checksum as defined in RFC-4880. Sum of all octets, mod 65536
    public func checksum() -> UInt16 {
        let s = withUnsafeBytes { buf in
            buf.lazy.map(UInt32.init).reduce(UInt32(0), +)
        }
        return UInt16(s % 65535)
    }
    
    /// Base64 URL safe encoding
    public func base64urlEncodedString() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
    
    /// Create from base64 string
    public static func fromBase64(_ encoded: String) -> Data? {
        return Data(base64Encoded: encoded)
    }
}

#if canImport(CommonCrypto)
// CommonCrypto is already imported above
#else
// Placeholder for platforms where CommonCrypto is not available
public func CC_SHA256(_ data: UnsafeRawPointer?, _ len: CC_LONG, _ md: UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>? {
    fatalError("CommonCrypto not available")
}
public let CC_SHA256_DIGEST_LENGTH: Int = 32
public typealias CC_LONG = UInt32
#endif 
