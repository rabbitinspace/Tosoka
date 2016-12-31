import Foundation

public struct Base64<Alphabet:CodingAlphabet> {

    // MARK: - Private properties

    private let coder: Alphabet

    // MARK: - Init & deinit

    public init(coder: Alphabet.Type) {
        self.coder = coder.init()
    }

    // MARK: - Encoding

    public func encode(_ data: Data) -> Data {
        let uncodedCount = data.count % 3
        let encodedLenght = (data.count / 3) * 4 + (uncodedCount > 0 ? 4 : 0)
        var encoded = Data(capacity: encodedLenght)
        var offset = 0

        print(data.count)

        while offset + 2 < data.count {
            let firstGroup = data[offset] >> 2
            let secondGroup = ((data[offset] & 0b11) << 4) | ((data[offset + 1] & 0b11110000) >> 4)
            let thirdGroup = ((data[offset + 1] & 0b00001111) << 2) | ((data[offset + 2] & 0b11000000) >> 6)
            let fourthGroup = data[offset + 2] & 0b00111111

            encoded.append(coder.encode(value: firstGroup))
            encoded.append(coder.encode(value: secondGroup))
            encoded.append(coder.encode(value: thirdGroup))
            encoded.append(coder.encode(value: fourthGroup))

            offset += 3
        }

        switch uncodedCount {
        case 1:
            // Final quantum is 8 bits long
            let firstGroup = data[offset] >> 2
            let secondGroup = (data[offset] & 0b11) << 4
            encoded.append(coder.encode(value: firstGroup))
            encoded.append(coder.encode(value: secondGroup))
            encoded.append(coder.padding)
            encoded.append(coder.padding)

        case 2:
            // Final quantum is 16 bits long
            let firstGroup = data[offset] >> 2
            let secondGroup = ((data[offset] & 0b11)) << 4 | ((data[offset + 1] & 0b11110000) >> 4)
            let thirdGroup = (data[offset + 1] & 0b00001111) << 2
            encoded.append(coder.encode(value: firstGroup))
            encoded.append(coder.encode(value: secondGroup))
            encoded.append(coder.encode(value: thirdGroup))
            encoded.append(coder.padding)


        default:
            assert(data.count == offset)
        }

        return encoded
    }

    // MARK: - Decoding


}
