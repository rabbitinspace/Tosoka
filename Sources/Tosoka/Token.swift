import Foundation

public final class Token<T: JSONCoding, U: Base64Coding> {
    
    // MARK: - Pyblic types
    
    public enum Error: Swift.Error {
        case encodingFailed
        case decodingFailed
        case signingFailed
        case corrupted
    }

    // MARK: - Private properties

    private let signature: Signature
    private let jsonCoder: T
    private let base64Coder: U
    
    fileprivate var claims = [String: Any]()
    
    private var header: [String: Any] {
        return [
            HeaderKey.algorithm: signature.algorithm,
            HeaderKey.type: tokenType
        ]
    }

    // MARK: - Init & deinit

    public init(signature: Signature, jsonCoder: T, base64Coder: U) {
        self.signature = signature
        self.jsonCoder = jsonCoder
        self.base64Coder = base64Coder
    }
    
    public convenience init(token: String, signature: Signature, jsonCoder: T, base64Coder: U) throws {
        self.init(signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
        try assembleFromToken(token)
    }

    // MARK: - Public subscripts

    public subscript(name: String) -> Any? {
        get {
            return claims[name]
        }

        set {
            claims[name] = newValue
        }
    }

    public subscript(claim: ReservedClaim) -> Any? {
        get {
            return self[claim.name]
        }

        set {
            self[claim.name] = newValue
        }
    }
    
    // MARK: - Public API
    
    public func build() throws -> String {
        guard let header = jsonCoder.makeData(with: header),
            let payload = jsonCoder.makeData(with: claims) else {
                throw Error.encodingFailed
        }
        
        guard let encodedHeader = base64Coder.encode(header).utf8String,
            let encodedPayload = base64Coder.encode(payload).utf8String else {
                throw Error.encodingFailed
        }
        
        let token = "\(encodedHeader).\(encodedPayload)"
        guard let signature = (try self.signature.signing(token)).data(using: .utf8) else {
            throw Error.encodingFailed
        }
        
        guard let encodedSignature = base64Coder.encode(signature).utf8String else {
            throw Error.encodingFailed
        }
        
        return token.appending(".\(encodedSignature)")
    }
    
    // MARK: - Private
    
    private func assembleFromToken(_ token: String) throws {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw Error.corrupted
        }
        
        guard let encodedHeader = parts[0].data(using: .utf8),
            let encodedPayload = parts[1].data(using: .utf8),
            let encodedSignature = parts[2].data(using: .utf8) else {
                throw Error.decodingFailed
        }
        
        let decodedHeader = try base64Coder.decode(encodedHeader)
        let decodedPayload = try base64Coder.decode(encodedPayload)
        let decodedSignature = try base64Coder.decode(encodedSignature)
        
        guard let header = jsonCoder.makeJSON(with: decodedHeader),
            let payload = jsonCoder.makeJSON(with: decodedPayload),
            let signature = String(data: decodedSignature, encoding: .utf8) else {
                throw Error.decodingFailed
        }
        
        guard (header[HeaderKey.algorithm] as? String) == self.signature.algorithm else {
            throw Error.corrupted
        }
        
        try validateSignature(signature, forHeader: parts[0], payload: parts[1])
        claims = payload
    }
    
    private func validateSignature(_ signature: String, forHeader header: String, payload: String) throws {
        let expectedSignature = try self.signature.signing("\(header).\(payload)")
        guard signature == expectedSignature else {
            throw Error.corrupted
        }
    }
}

// MARK: - Operators

extension Token: ClaimReadable {
    public static func ~><T: Claim>(token: Token, claim: T.Type) -> T.Content? {
        return token.claims[claim.name] as? T.Content
    }
}

extension Token: ClaimWritable {
    public static func +=<T: Claim>(token: inout Token, claim: T) {
        token.claims[T.name] = claim.content
    }
}

// MARK: - Private extensions

private extension Token {
    struct HeaderKey {
        static var algorithm: String {
            return "alg"
        }
        
        static var type: String {
            return "typ"
        }
    }
    
    var tokenType: String {
        return "JWT"
    }
}

private extension Data {
    var utf8String: String? {
        return String(data: self, encoding: .utf8)
    }
}
