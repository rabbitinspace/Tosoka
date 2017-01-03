import Foundation

public final class Tosoka {
    fileprivate let token: Token<JSONCoder, Base64<URLSafeCodingAlphabet>>
    
    
    public init(signature: Signature) {
        let jsonCoder = JSONCoder()
        let base64Coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
        
        token = Token(signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
    }
    
    public init(token: String, signature: Signature, audience: Audience? = nil) throws {
        let jsonCoder = JSONCoder()
        let base64Coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
        
        self.token = try Token(token: token, signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
        try validateClaims()
    }
    
    private func validateClaims() throws {
        
    }
    
    public func makeToken() throws -> String {
        return try token.build()
    }
}

extension Tosoka: ClaimReadable {
    public static func ~><T: Claim>(token: Tosoka, claim: T.Type) -> T.Content? {
        return token ~> claim
    }
}

extension Tosoka: ClaimWritable {
    public static func +=<T: Claim>(token: inout Tosoka, claim: T) {
        token += claim
    }
    
    public static func +=<T: Claim>(token: inout Tosoka, claims: [T]) {
        claims.forEach { token += $0 }
    }
}
