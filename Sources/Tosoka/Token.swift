import Foundation

public final class Token<T: JSONCoding, U: Base64Coding> {
    
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
    
    public convenience init(token: String, for audience: Audience? = nil, signature: Signature, jsonCoder: T, base64Coder: U) throws {
        self.init(signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
        
        try assembleFromToken(token, for: audience)
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
                throw TokenError.encodingFailed
        }
        
        guard let encodedHeader = base64Coder.encode(header).utf8String,
            let encodedPayload = base64Coder.encode(payload).utf8String else {
                throw TokenError.encodingFailed
        }
        
        let token = "\(encodedHeader).\(encodedPayload)"
        guard let signature = (try self.signature.signing(token)).data(using: .utf8) else {
            throw TokenError.encodingFailed
        }
        
        guard let encodedSignature = base64Coder.encode(signature).utf8String else {
            throw TokenError.encodingFailed
        }
        
        return token.appending(".\(encodedSignature)")
    }
    
    // MARK: - Private
    
    private func assembleFromToken(_ token: String, for audience: Audience?) throws {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw TokenError.corrupted
        }
        
        guard let encodedHeader = parts[0].data(using: .utf8),
            let encodedPayload = parts[1].data(using: .utf8),
            let encodedSignature = parts[2].data(using: .utf8) else {
                throw TokenError.decodingFailed
        }
        
        let decodedHeader = try base64Coder.decode(encodedHeader)
        let decodedPayload = try base64Coder.decode(encodedPayload)
        let decodedSignature = try base64Coder.decode(encodedSignature)
        
        guard let header = jsonCoder.makeJSON(with: decodedHeader),
            let payload = jsonCoder.makeJSON(with: decodedPayload),
            let signature = String(data: decodedSignature, encoding: .utf8) else {
                throw TokenError.decodingFailed
        }
        
        claims = payload
        
        guard (header[HeaderKey.algorithm] as? String) == self.signature.algorithm else {
            throw TokenError.corrupted
        }
        
        try validateSignature(signature, forHeader: parts[0], payload: parts[1])
        try validateToken(indendedFor: audience)
    }
    
    private func validateSignature(_ signature: String, forHeader header: String, payload: String) throws {
        let expectedSignature = try self.signature.signing("\(header).\(payload)")
        guard signature == expectedSignature else {
            throw TokenError.corrupted
        }
    }
    
    private func validateToken(indendedFor audience: Audience?) throws {
        if let audience = audience {
            guard let tokenAudience = self ~> Audience.self, tokenAudience.isValid(for: audience) else {
                throw TokenError.invalidAudience
            }
        }
        
        if let expirationDate = self ~> Expiring.self {
            guard expirationDate.isValid() else {
                throw TokenError.expired
            }
        }
        
        if let notBeforeDate = self ~> NotBefore.self {
            guard notBeforeDate.isValid() else {
                throw TokenError.fromFuture
            }
        }
    }
}

public enum TokenError: Error {
    case encodingFailed
    case decodingFailed
    case signingFailed
    case corrupted
    case invalidAudience
    case expired
    case fromFuture
}

// MARK: - Operators

extension Token: ClaimReadable {
    public static func ~><T: Claim>(token: Token, claim: T.Type) -> T? {
        guard let rawValue = token.claims[claim.name] as? T.RawValue else {
            return nil
        }
        
        return T.init(rawValue: rawValue)
    }
}

extension Token: ClaimWritable {
    public static func +=<T: Claim>(token: inout Token, claim: T) {
        token.claims[T.name] = claim.rawValue
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
