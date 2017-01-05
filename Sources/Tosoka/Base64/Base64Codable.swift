import Foundation

/// A generic base64 encoding/decoding
public protocol Base64Coding {
    
    /// Encodes `data` to base64 representation
    ///
    /// - Parameter data: data to be encoded
    /// - Returns: base64 encoded data
    func encode(_ data: Data) -> Data
    
    /// Decodes base64 encoded `data`
    ///
    /// - Parameter data: base64 encoded data
    /// - Returns: decoded data
    /// - Throws: `Base64Error` or implementing type errors
    func decode(_ data: Data) throws -> Data
}
