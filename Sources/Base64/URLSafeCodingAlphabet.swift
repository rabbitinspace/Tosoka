import Foundation

public struct URLSafeCodingAlphabet {
    
    // MARK: - Private static properties
    
    /*
     "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
     "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
     "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d",
     "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
     "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
     "y", "z", "0", "1", "2", "3", "4", "5", "6", "7",
     "8", "9", "-", "_"
     */
    fileprivate static let codingTable: [UInt8] = [
        65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
        75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
        85, 86, 87, 88, 89, 90, 97, 98, 99, 100,
        101, 102,103,104,105,106,107,108,109,110,
        111,112,113,114,115,116,117,118,119,120,
        121,122,48, 49, 50, 51, 52, 53, 54, 55,
        56, 57, 45, 95,
    ]
}

// MARK: - CodingAlphabet

extension URLSafeCodingAlphabet: CodingAlphabet {
    public static func encode(value: UInt8) -> UInt8 {
        let value = Int(value)
        assert(value < URLSafeCodingAlphabet.codingTable.count)
        return URLSafeCodingAlphabet.codingTable[value]
    }
    
    public static func decode(value: UInt8) -> UInt8 {
        return value
        //        let value = Int(value)
        //        assert(value < URLSafeCodingAlphabet.codingTable.count)
        //        return
    }
}

