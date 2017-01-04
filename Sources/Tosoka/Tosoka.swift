import Foundation

public final class Tosoka {
    public typealias ClaimGrabber = (inout Tosoka) -> Void

    public static func makeToken(signature: Signature, claimGrabber grabClaims: ClaimGrabber? = nil) throws -> String {
        var tosoka = Tosoka(signature: signature)
        grabClaims?(&tosoka)
        return try tosoka.encode()
    }
    
    fileprivate var actualToken: Token<JSONCoder, Base64<URLSafeCodingAlphabet>>
    
    
    public init(signature: Signature) {
        let jsonCoder = JSONCoder()
        let base64Coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
        
        actualToken = Token(signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
    }
    
    public init(token: String, signature: Signature) throws {
        let jsonCoder = JSONCoder()
        let base64Coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
        
        actualToken = try Token(token: token, signature: signature, jsonCoder: jsonCoder, base64Coder: base64Coder)
    }
    
    public func encode() throws -> String {
        return try actualToken.build()
    }
    
    public subscript(name: String) -> Any? {
        get {
            return actualToken[name]
        }
        
        set {
            actualToken[name] = newValue
        }
    }
}

extension Tosoka: ClaimReadable {
    public static func ~><T: Claim>(token: Tosoka, claim: T.Type) -> T? {
        return token.actualToken ~> claim
    }
}

extension Tosoka: ClaimWritable {
    public static func +=<T: Claim>(token: inout Tosoka, claim: T) {
        token.actualToken += claim
    }
    
    public static func +=<T: Claim>(token: inout Tosoka, claims: [T]) {
        claims.forEach { token += $0 }
    }
}
