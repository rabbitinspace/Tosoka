import Foundation

/// Registered claims
///
/// Claims that is registered according to rfc7519
///
/// - issuer: "issuer" claim
/// - subject: "subject" claim
/// - audience: "audience" claim
/// - expiring: "expiration time" claim
/// - notBefore: "not before" claim
/// - issued: "issued at" claim
/// - id: "jwt id" claim
public enum ReservedClaim {
    case issuer
    case subject
    case audience
    case expiring
    case notBefore
    case issued
    case id
}

// MARK: - Predefined claims

/// Issuer claim
public struct Issuer: Claim {
    public static var name: String {
        return ReservedClaim.issuer.name
    }

    public let content: String

    public init(content: String) {
        self.content = content
    }
}

/// Subject claim
public struct Subject: Claim {
    public static var name: String {
        return ReservedClaim.subject.name
    }

    public let content: String
    
    public init(content: String) {
        self.content = content
    }
}

/// Audience claim
public struct Audience: Claim {
    public static var name: String {
        return ReservedClaim.audience.name
    }

    public let content: Set<String>
    
    public var rawValue: [String] {
        return Array(content)
    }
    
    public init(content: Set<String>) {
        self.content = content
    }
    
    public init?(rawValue: [String]) {
        self.init(content: rawValue)
    }
    
    public func isValid(for requirment: Audience?) -> Bool {
        guard let requirment = requirment else {
            return content.isEmpty
        }
        
        return content.isSuperset(of: requirment.content)
    }
}

public extension Audience {
    public init(content: String) {
        let audience = [content]
        self.init(content: audience)
    }

    public init(content: [String]) {
        let audience = Set(content)
        self.init(content: audience)
    }
}

/// Expiring time claim
public struct Expiring: Claim {
    public static var name: String {
        return ReservedClaim.expiring.name
    }

    public let content: Date
    
    public var rawValue: TimeInterval {
        return content.timeIntervalSince1970
    }
    
    public init(content: Date) {
        self.content = content
    }
 
    public init?(rawValue: TimeInterval) {
        self.init(content: Date(timeIntervalSince1970: rawValue))
    }
    
    public func isValid(for requirment: Expiring? = nil) -> Bool {
        return Date() < content
    }
}

/// Not before claim
public struct NotBefore: Claim {
    public static var name: String {
        return ReservedClaim.notBefore.name
    }

    public let content: Date

    public var rawValue: TimeInterval {
        return content.timeIntervalSince1970
    }

    
    public init(content: Date) {
        self.content = content
    }
    
    public init?(rawValue: TimeInterval) {
        self.init(content: Date(timeIntervalSince1970: rawValue))
    }
    
    public func isValid(for requirment: NotBefore? = nil) -> Bool {
        return Date() >= content
    }
}

/// Issued at claim
public struct Issued: Claim {
    public static var name: String {
        return ReservedClaim.issued.name
    }

    public let content: Date
    
    public var rawValue: TimeInterval {
        return content.timeIntervalSince1970
    }
    
    public init(content: Date) {
        self.content = content
    }
  
    
    public init?(rawValue: TimeInterval) {
        self.init(content: Date(timeIntervalSince1970: rawValue))
    }
}

/// JWT ID claim
public struct ID: Claim {
    public static var name: String {
        return ReservedClaim.id.name
    }

    public let content: String
    
    public init(content: String) {
        self.content = content
    }
}

// MARK: - Internal extensions

extension ReservedClaim {
    
    /// Name of the claim according to rfc7519
    public var name: String {
        switch self {
        case .issuer:
            return "iss"

        case .subject:
            return "sub"

        case .audience:
            return "aud"

        case .expiring:
            return "exp"

        case .notBefore:
            return "nbf"

        case .issued:
            return "iat"

        case .id:
            return "jti"
        }
    }
}
