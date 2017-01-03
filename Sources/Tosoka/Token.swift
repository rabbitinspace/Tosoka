import Foundation

public final class Token<T: JSONCoding, U: Base64Codable> {
    
    // MARK: - Pyblic types
    
    public enum Error: Swift.Error {
        case encodingFailed
        case decodingFailed
        case signingFailed
    }

    // MARK: - Private properties

    private let signature: Signature
    private let jsonCoder: T
    private let base64Coder: U
    
    fileprivate var claims = [String: Any]()
    
    private var header: [String: Any] {
        return [
            "alg": signature.algorithm,
            "typ": "JWT"
        ]
    }

    // MARK: - Init & deinit

    public init(signature: Signature, jsonCoder: T, base64Coder: U) {
        self.signature = signature
        self.jsonCoder = jsonCoder
        self.base64Coder = base64Coder
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
        guard let signature = (try self.signature.signingToken(token)).data(using: .utf8) else {
            throw Error.encodingFailed
        }
        
        guard let encodedSignature = base64Coder.encode(signature).utf8String else {
            throw Error.encodingFailed
        }
        
        return token.appending(".\(encodedSignature)")
    }
}

// MARK: - Operators

infix operator ~>

public extension Token {
    public static func ~><T: Claim>(token: Token, claim: T.Type) -> T.Content? {
        return token.claims[claim.name] as? T.Content
    }
}

public extension Token {
    public static func +=<T: Claim>(token: inout Token, claim: T) {
        token.claims[T.name] = claim.content
    }

    public static func +=<T: Claim>(token: inout Token, claims: [T]) {
        claims.forEach {
            token += $0
        }
    }
}

// MARK: - Private extensions

private extension Data {
    var utf8String: String? {
        return String(data: self, encoding: .utf8)
    }
}
