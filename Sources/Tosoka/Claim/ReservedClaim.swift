import Foundation

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

public struct Issuer: Claim {
    public static var name: String {
        return ReservedClaim.issuer.name
    }

    public let content: String

    public init(content: String) {
        self.content = content
    }
}

public struct Subject: Claim {
    public static var name: String {
        return ReservedClaim.subject.name
    }

    public let content: String
    
    public init(content: String) {
        self.content = content
    }
}

public struct Audience: Claim {
    public static var name: String {
        return ReservedClaim.audience.name
    }

    public let content: Set<String>
    
    public init(content: Set<String>) {
        self.content = content
    }
    
    public var rawValue: [String] {
        return Array(content)
    }
    
    public init?(rawValue: [String]) {
        self.init(content: rawValue)
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
