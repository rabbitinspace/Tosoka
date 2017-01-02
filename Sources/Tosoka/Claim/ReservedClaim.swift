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
    public typealias Content = String

    public static var name: String {
        return ReservedClaim.issuer.name
    }

    public var content: String
}

public struct Subject: Claim {
    public typealias Content = String

    public static var name: String {
        return ReservedClaim.subject.name
    }

    public var content: String
}

public struct Audience: Claim {
    public typealias Content = [String]

    public static var name: String {
        return ReservedClaim.audience.name
    }

    public var content: Array<String>
}

public extension Audience {
    public init(content: String) {
        let audience = [content]
        self.init(content: audience)
    }
}

public struct Expiring: Claim {
    public typealias Content = Date

    public static var name: String {
        return ReservedClaim.expiring.name
    }

    public var content: Date
}

public struct NotBefore: Claim {
    public typealias Content = Date

    public static var name: String {
        return ReservedClaim.notBefore.name
    }

    public var content: Date
}

public struct Issued: Claim {
    public typealias Content = Date

    public static var name: String {
        return ReservedClaim.issued.name
    }

    public var content: Date
}

public struct ID: Claim {
    public typealias Content = String

    public static var name: String {
        return ReservedClaim.id.name
    }

    public var content: String
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
