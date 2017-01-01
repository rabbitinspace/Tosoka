import Foundation

/**
 Full table declaration can be found here: https://www.ietf.org/rfc/rfc4648.txt 
 on page 7
 
 Here is it in less readable format:
 
 "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
 "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
 "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d",
 "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
 "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
 "y", "z", "0", "1", "2", "3", "4", "5", "6", "7",
 "8", "9", "-", "_"
 */

/// Base64 encoding/decoding table that is URL safe
public struct URLSafeCodingAlphabet {

    // MARK: - Private properties

    /// Encoding table
    fileprivate let encodingTable: [UInt8] = [
        65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
        75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
        85, 86, 87, 88, 89, 90, 97, 98, 99, 100,
        101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
        111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
        121, 122, 48, 49, 50, 51, 52, 53, 54, 55,
        56, 57, 45, 95,
    ]

    /// Decoding table
    fileprivate let decodingTable: [UInt8: UInt8] = [
        65: 0, 66: 1, 67: 2, 68: 3, 69: 4,
        70: 5, 71: 6, 72: 7, 73: 8, 74: 9,
        75: 10, 76: 11, 77: 12, 78: 13, 79: 14,
        80: 15, 81: 16, 82: 17, 83: 18, 84: 19,
        85: 20, 86: 21, 87: 22, 88: 23, 89: 24,
        90: 25, 97: 26, 98: 27, 99: 28, 100: 29,
        101: 30, 102: 31, 103: 32, 104: 33, 105: 34,
        106: 35, 107: 36, 108: 37, 109: 38, 110: 39,
        111: 40, 112: 41, 113: 42, 114: 43, 115: 44,
        116: 45, 117: 46, 118: 47, 119: 48, 120: 49,
        121: 50, 122: 51, 48: 52, 49: 53, 50: 54,
        51: 55, 52: 56, 53: 57, 54: 58, 55: 59,
        56: 60, 57: 61, 45: 62, 95: 63,
    ]

    // MARK: - Init & deinit

    public init() { }
}

// MARK: - CodingAlphabet

extension URLSafeCodingAlphabet: CodingAlphabet {
    public func encode(byte: UInt8) -> UInt8 {
        let byte = Int(byte)
        assert(byte < encodingTable.count)
        return encodingTable[byte]
    }

    public func decode(byte: UInt8) -> UInt8? {
        return decodingTable[byte]
    }
}

