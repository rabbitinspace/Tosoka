import Foundation

public struct Token {

    // MARK: - Private properties

    fileprivate var claims = [String: Any]()

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
}

// MARK: - Operators

infix operator ~>

public extension Token {
    public static func ~><T:Claim>(token: Token, claim: T.Type) -> T.Content? {
        return token.claims[claim.name] as? T.Content
    }
}

public extension Token {
    public static func +=<T:Claim>(token: inout Token, claim: T) {
        token.claims[T.name] = claim.content
    }

    public static func +=<T:Claim>(token: inout Token, claims: [T]) {
        claims.forEach {
            token += $0
        }
    }
}
