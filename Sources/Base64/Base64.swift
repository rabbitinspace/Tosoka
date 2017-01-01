import Foundation

/// A base64 encoder/decoder
///
/// This implementation conforms to rfc4648
public struct Base64<Alphabet: CodingAlphabet>: Base64Codable {

    // MARK: - Private properties

    /// Base64 encoding/decoding table
    private let coder: Alphabet
    
    /// Says that a padding bytes should be added to the end of encoded data
    private let isPaddingEnabled: Bool

    // MARK: - Init & deinit

    /// Designated initializer
    ///
    /// - Parameters:
    ///   - coder: base64 encoding/decoding table
    ///   - isPaddingEnabled: Says that a padding bytes should be added to the end of encoded data
    public init(coder: Alphabet.Type, isPaddingEnabled: Bool = true) {
        self.coder = coder.init()
        self.isPaddingEnabled = isPaddingEnabled
    }

    // MARK: - Encoding

    public func encode(_ data: Data) -> Data {
        let finalQuantumLength = data.count % 3
        let encodedLength = (data.count / 3) * 4 + (finalQuantumLength > 0 ? 4 : 0)
        var encoded = Data(capacity: encodedLength)
        var offset = 0

        while offset + 2 < data.count {
            let firstByte = data[offset] >> 2
            let secondByte = ((data[offset] & 0b11) << 4) | ((data[offset + 1] & 0b11110000) >> 4)
            let thirdByte = ((data[offset + 1] & 0b00001111) << 2) | ((data[offset + 2] & 0b11000000) >> 6)
            let fourthByte = data[offset + 2] & 0b00111111

            encoded.append(coder.encode(byte: firstByte))
            encoded.append(coder.encode(byte: secondByte))
            encoded.append(coder.encode(byte: thirdByte))
            encoded.append(coder.encode(byte: fourthByte))

            offset += 3
        }

        // This prevents us from adding unnecessary checks in while loop but adds some code duplication
        // Review it later
        switch finalQuantumLength {
        case 1:
            // Final quantum is 8 bits long
            let firstGroup = data[offset] >> 2
            let secondGroup = (data[offset] & 0b11) << 4
            encoded.append(coder.encode(byte: firstGroup))
            encoded.append(coder.encode(byte: secondGroup))

        case 2:
            // Final quantum is 16 bits long
            let firstGroup = data[offset] >> 2
            let secondGroup = ((data[offset] & 0b11)) << 4 | ((data[offset + 1] & 0b11110000) >> 4)
            let thirdGroup = (data[offset + 1] & 0b00001111) << 2
            encoded.append(coder.encode(byte: firstGroup))
            encoded.append(coder.encode(byte: secondGroup))
            encoded.append(coder.encode(byte: thirdGroup))

        default:
            assert(data.count == offset)
        }
        
        if finalQuantumLength != 0 && isPaddingEnabled {
            for _ in 0 ..< (3 - finalQuantumLength) {
                encoded.append(coder.padding)
            }
        }

        return encoded
    }

    // MARK: - Decoding

    public func decode(_ data: Data) throws -> Data {
        var paddingCount = 0
        for byte in data.reversed() { // data.reversed() is O(1)
            guard byte == coder.padding else {
                break
            }
            
            paddingCount += 1
        }

        if (paddingCount > 0 && data.count % 4 != 0) || paddingCount > 2  {
            throw Base64Error.badData
        }

        let hasIncompleteQuantum = paddingCount > 0 || data.count % 4 != 0
        let quantumsLengthExcludingIncomplete = data.count - paddingCount - (data.count - paddingCount) % 4
        let incompleteQuantumLength = data.count - quantumsLengthExcludingIncomplete - paddingCount
        
        assert([0, 2, 3].contains(incompleteQuantumLength))

        let decodedDataLength = quantumsLengthExcludingIncomplete / 4 * 3 + max(incompleteQuantumLength - 1, 0)
        let dataLengthWithoutPadding = data.count - paddingCount
        var decoded = Data(capacity: decodedDataLength) 
        var offset = 0

        while offset + 3 < dataLengthWithoutPadding {
            let firstPart: UInt8 = try coder.decode(byte: data[offset])
            let secondPart: UInt8 = try coder.decode(byte: data[offset + 1])
            let thirdPart: UInt8 = try coder.decode(byte: data[offset + 2])
            let fourthPart: UInt8 = try coder.decode(byte: data[offset + 3])
            
            let firstByte = (firstPart << 2) | (secondPart >> 4)
            let secondByte = (secondPart << 4) | (thirdPart >> 2)
            let thirdByte = (thirdPart << 6) | fourthPart

            decoded.append(firstByte)
            decoded.append(secondByte)
            decoded.append(thirdByte)

            offset += 4
        }

        guard hasIncompleteQuantum else {
            return decoded
        }

        // This prevents us from adding unnecessary checks in while loop but adds some code duplication
        // Review it later
        switch incompleteQuantumLength {
        case 2:
            let firstPart: UInt8 = try coder.decode(byte: data[offset])
            let secondPart: UInt8 = try coder.decode(byte: data[offset + 1])
            
            let byte = (firstPart << 2) | (secondPart >> 4)
            decoded.append(byte)

        case 3:
            let firstPart: UInt8 = try coder.decode(byte: data[offset])
            let secondPart: UInt8 = try coder.decode(byte: data[offset + 1])
            let thirdPart: UInt8 = try coder.decode(byte: data[offset + 2])
            
            let firstByte = (firstPart << 2) | (secondPart >> 4)
            let secondByte = (secondPart << 4) | (thirdPart >> 2)
            decoded.append(firstByte)
            decoded.append(secondByte)

        default:
            assert(data.count == offset)
        }

        return decoded
    }
}

// MARK: - Private extensions

private extension CodingAlphabet {
    func decode(byte: UInt8) throws -> UInt8 {
        guard let decodedByte = decode(byte: byte) else {
            throw Base64Error.badData
        }
        
        return decodedByte
    }
}
