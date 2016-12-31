import Foundation

public protocol CodingAlphabet {
    static var padding: UInt8 { get }
    
    static func encode(value: UInt8) -> UInt8
    static func decode(value: UInt8) -> UInt8
}

extension CodingAlphabet {
    static public var padding: UInt8 {
        return 61
    }
}
