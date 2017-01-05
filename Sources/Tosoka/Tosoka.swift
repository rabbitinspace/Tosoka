import Foundation

/// JSON web token
///
/// It's just a convenience wrapper arount `Token` with defaut json/base64 encoders/decoders
public final class Tosoka {
    
    // MARK: - Public types
    
    /// Clojure for adding claims
    public typealias ClaimGrabber = (inout Tosoka) -> Void

    /// Creates encoded token
    ///
    /// - Parameters:
    ///   - signature: signing algorithm for the token
    ///   - grabClaims: clojure for adding claims
    /// - Returns: encoded json web token
    /// - Throws: `TokenError`, `Signature.SigningError`
    public static func makeToken(signature: Signature, claimGrabber grabClaims: ClaimGrabber? = nil) throws -> String {
        var tosoka = Tosoka(signature: signature)
        grabClaims?(&tosoka)
        return try tosoka.encode()
    }
    
    /// Actual token
    fileprivate var token: Token<JSONCoder, Base64<URLSafeCodingAlphabet>>
    
    /// Creates instance of `self` with desired `signature`
    ///
    /// - Parameter signature: desired signing algorithm
    public init(signature: Signature) {
        let jsonCoder = JSONCoder()
        let base64Coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
        
        token = Token(signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
    }
    
    /// Creates instance of `self` from encoded `token` intended for `audience` and signed with `signature`
    ///
    /// - Parameters:
    ///   - token: string representation of already encoded token
    ///   - audience: audience for which token is intended
    ///   - signature: signature of the encoded token
    /// - Throws: `TokenError`, `Signature.SigningError`, `Base64Error`, `JSONSerialization`'s errors
    public init(token: String, for audience: Audience? = nil, signature: Signature) throws {
        let jsonCoder = JSONCoder()
        let base64Coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
        
        self.token = try Token(
            token: token,
            for: audience,
            signature: signature,
            jsonCoder: jsonCoder,
            base64Coder: base64Coder
        )
    }
    
    /// Returns a valid token that can be used for example in HTTP headers
    ///
    /// - Returns: Encoded and signed token
    /// - Throws: `TokenError`, `Signature.SigningError`
    public func encode() throws -> String {
        return try token.build()
    }
}

// MARK: - ClaimAccessible

extension Tosoka: ClaimAccessible {
    public subscript(name: String) -> Any? {
        get {
            return token[name]
        }
        
        set {
            token[name] = newValue
        }
    }
    
    public subscript(claim: ReservedClaim) -> Any? {
        get {
            return token[claim]
        }
        
        set {
            token[claim] = newValue
        }
    }
}

// MARK: - ClaimReadable

extension Tosoka: ClaimReadable {
    public static func ~><T: Claim>(token: Tosoka, claim: T.Type) -> T? {
        return token.token ~> claim
    }
}

// MARK: - ClaimWritable

extension Tosoka: ClaimWritable {
    public static func +=<T: Claim>(token: inout Tosoka, claim: T) {
        token.token += claim
    }
    
    public static func +=<T: Claim>(token: inout Tosoka, claims: [T]) {
        claims.forEach { token += $0 }
    }
}
