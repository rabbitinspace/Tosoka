import Foundation

public protocol CodingAlphabet {
    var padding: UInt8 { get }

    init()

    func encode(value: UInt8) -> UInt8
    func decode(value: UInt8) -> UInt8
}

extension CodingAlphabet {
    public var padding: UInt8 {
        return 61
    }
}
