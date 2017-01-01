import Foundation

public struct Base64<Alphabet: CodingAlphabet> {

    // MARK: - Private properties

    private let coder: Alphabet

    // MARK: - Init & deinit

    public init(coder: Alphabet.Type) {
        self.coder = coder.init()
    }

    // MARK: - Encoding

    public func encode(_ data: Data, withPadding isPaddingEnabled: Bool = false) -> Data {
        let finalQuantumLength = data.count % 3
        let encodedLength = (data.count / 3) * 4 + (finalQuantumLength > 0 ? 4 : 0)
        var encoded = Data(capacity: encodedLength)
        var offset = 0

        print(data.count)

        while offset + 2 < data.count {
            let firstByte = data[offset] >> 2
            let secondByte = ((data[offset] & 0b11) << 4) | ((data[offset + 1] & 0b11110000) >> 4)
            let thirdByte = ((data[offset + 1] & 0b00001111) << 2) | ((data[offset + 2] & 0b11000000) >> 6)
            let fourthByte = data[offset + 2] & 0b00111111

            encoded.append(coder.encode(value: firstByte))
            encoded.append(coder.encode(value: secondByte))
            encoded.append(coder.encode(value: thirdByte))
            encoded.append(coder.encode(value: fourthByte))

            offset += 3
        }

        // This prevents us from adding unnecessary checks in while loop but adds some code duplication
        // Review it later
        switch finalQuantumLength {
        case 1:
            // Final quantum is 8 bits long
            let firstGroup = data[offset] >> 2
            let secondGroup = (data[offset] & 0b11) << 4
            encoded.append(coder.encode(value: firstGroup))
            encoded.append(coder.encode(value: secondGroup))

        case 2:
            // Final quantum is 16 bits long
            let firstGroup = data[offset] >> 2
            let secondGroup = ((data[offset] & 0b11)) << 4 | ((data[offset + 1] & 0b11110000) >> 4)
            let thirdGroup = (data[offset + 1] & 0b00001111) << 2
            encoded.append(coder.encode(value: firstGroup))
            encoded.append(coder.encode(value: secondGroup))
            encoded.append(coder.encode(value: thirdGroup))

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
        guard data.count > 0 else {
            return data
        }

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
        var decoded = Data(capacity: decodedDataLength) // TODO: Check
        var offset = 0

        while offset + 3 < dataLengthWithoutPadding {
            let firstPart: UInt8 = try coder.decode(value: data[offset])
            let secondPart: UInt8 = try coder.decode(value: data[offset + 1])
            let thirdPart: UInt8 = try coder.decode(value: data[offset + 2])
            let fourthPart: UInt8 = try coder.decode(value: data[offset + 3])
            
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
            let firstPart: UInt8 = try coder.decode(value: data[offset])
            let secondPart: UInt8 = try coder.decode(value: data[offset + 1])
            
            let byte = (firstPart << 2) | (secondPart >> 4)
            decoded.append(byte)

        case 3:
            let firstPart: UInt8 = try coder.decode(value: data[offset])
            let secondPart: UInt8 = try coder.decode(value: data[offset + 1])
            let thirdPart: UInt8 = try coder.decode(value: data[offset + 2])
            
            let firstByte = (firstPart << 2) | (secondPart >> 4)
            let secondByte = (secondPart << 4) | (thirdPart >> 2)
            decoded.append(firstByte)
            decoded.append(secondByte)

        default:
            assertionFailure()
        }

        return decoded
    }
}

// TODO: Move to `Base64` declaration in swift 3.1
public enum Base64Error: Error {
    case badData
}

// MARK: - Private extensions

private extension CodingAlphabet {
    func decode(value: UInt8) throws -> UInt8 {
        guard let decodedByte = decode(value: value) else {
            throw Base64Error.badData
        }
        
        return decodedByte
    }
}
