import Foundation

public protocol Claim {
    associatedtype Content
    
    static var name: String { get }
    
    var content: Content { get }
    var isValid: Bool { get }
}

extension Claim {
    public var isValid: Bool {
        return true
    }
}
