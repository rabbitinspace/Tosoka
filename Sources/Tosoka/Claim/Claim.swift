import Foundation

public protocol Claim: ClaimReadable {
    var content: Content { get }
    var isValid: Bool { get }
}

extension Claim {
    public var isValid: Bool {
        return true
    }
}
