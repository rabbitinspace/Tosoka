import Foundation

/// Describes a base64 byte converting table
public protocol CodingAlphabet {
    /// Padding byte
    var padding: UInt8 { get }

    /// Creates an instance with default parameters
    init()

    /// Encodes given `byte` to base64 representation
    ///
    /// - Parameter byte: byte to be encoded
    /// - Returns: base64 encoded byte
    func encode(byte: UInt8) -> UInt8
    
    /// Decodes base64 encoded `byte` to initial value
    ///
    /// - Parameter byte: base64 encoded byte
    /// - Returns: decoded byte
    func decode(byte: UInt8) -> UInt8?
}

extension CodingAlphabet {
    /// Returns default padding that is `=`
    public var padding: UInt8 {
        return 61
    }
}
