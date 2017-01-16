import Foundation

/// JSON web token
public final class Token<T: JSONCoding, U: Base64Coding> {
    
    // MARK: - Private properties
    
    /// Token signing algorithm
    private let signature: Signature
    
    /// JSON encoder/decoder
    private let jsonCoder: T
    
    /// Base64 encoder/decoder
    private let base64Coder: U
    
    /// Claims, associated with the token
    fileprivate var claims = [String: Any]()
    
    /// JOSE header for the token
    private var header: [String: Any] {
        return [
            HeaderKey.algorithm: signature.algorithm,
            HeaderKey.type: tokenType
        ]
    }

    // MARK: - Init & deinit

    /// Creates instance of `self` with desired `signature` and json and base64 encoders/decoders
    ///
    /// - Parameters:
    ///   - signature: algorithm for token signature
    ///   - jsonCoder: json encoder/decoder
    ///   - base64Coder: base64 encoder/decoder
    public init(signature: Signature, jsonCoder: T, base64Coder: U) {
        self.signature = signature
        self.jsonCoder = jsonCoder
        self.base64Coder = base64Coder
    }
    
    /// Creates instance of `self` from encoded `token` intended for `audience` and signed with `signature`, using provided json/base64 encoders/decoders
    ///
    /// - Parameters:
    ///   - token: string representation of already encoded token
    ///   - audience: audience for which token is intended
    ///   - signature: signature of the encoded token
    ///   - jsonCoder: json encoder/decoder
    ///   - base64Coder: base64 encoder/decoder
    /// - Throws: `TokenError`, `Signature.SigningError`, `T` and `U`'s implementations errors
    public convenience init(token: String, for audience: Audience? = nil, signature: Signature, jsonCoder: T, base64Coder: U) throws {
        self.init(signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
        
        try assembleFromToken(token, for: audience)
    }

    // MARK: - Public API
    
    /// Returns a valid token that can be used for example in HTTP headers
    ///
    /// - Returns: Encoded and signed token
    /// - Throws: `TokenError`, `Signature.SigningError`
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
        let signature = try self.signature.signing(token)
        
        guard let encodedSignature = base64Coder.encode(signature).utf8String else {
            throw TokenError.encodingFailed
        }
        
        return token.appending(".\(encodedSignature)")
    }
    
    // MARK: - Private
    
    /// Builds up itself from encoded `token` intended for `audience`
    ///
    /// - Parameters:
    ///   - token: encoded token
    ///   - audience: audience, token is intended for
    /// - Throws: `TokenError`, `Signature.SigningError`, `T` an `U`'s implementations errors
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
            let payload = jsonCoder.makeJSON(with: decodedPayload) else {
                throw TokenError.decodingFailed
        }
        
        claims = payload
        
        guard (header[HeaderKey.algorithm] as? String) == self.signature.algorithm else {
            throw TokenError.corrupted
        }
        
        try validateSignature(decodedSignature, forHeader: parts[0], payload: parts[1])
        try validateToken(indendedFor: audience)
    }
    
    /// Validates `signature` for base64 encoded `header` and `payload`
    ///
    /// - Parameters:
    ///   - signature: signature of a token
    ///   - header: base64 encoded header of a token
    ///   - payload: base64 encoded payload of a token
    /// - Throws: `TokenError`, `Signature.SigningError`
    private func validateSignature(_ signature: Data, forHeader header: String, payload: String) throws {
        let expectedSignature = try self.signature.signing("\(header).\(payload)")
        guard signature == expectedSignature else {
            throw TokenError.corrupted
        }
    }
    
    /// Validates claims of a token which is intended for an `audience`
    ///
    /// - Parameter audience: audience, token is intended for
    /// - Throws: `TokenError`
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

// MARK: - Public types

/// Encoding/decoding errors
///
/// - encodingFailed: error occured during encoding
/// - decodingFailed: error occured during decoding
/// - corrupted: token is corrupted or has bad signature
/// - invalidAudience: token is intended for another audience
/// - expired: token is expired
/// - fromFuture: token's "not before" claim is after current date
public enum TokenError: Error {
    case encodingFailed
    case decodingFailed
    case corrupted
    case invalidAudience
    case expired
    case fromFuture
}

// MARK: - Extensions

// MARK: - ClaimAccessible

extension Token: ClaimAccessible {
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
}

// MARK: - ClaimReadable

extension Token: ClaimReadable {
    public static func ~><T: Claim>(token: Token, claim: T.Type) -> T? {
        guard let rawValue = token.claims[claim.name] as? T.RawValue else {
            return nil
        }
        
        return T.init(rawValue: rawValue)
    }
}

// MARK: - ClaimWritable

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
