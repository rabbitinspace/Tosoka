import Foundation

/// A claim for a json web token
public protocol Claim: RawRepresentable {
    
    /// Type of the value that claim contains
    associatedtype Content
    
    /// Name of the claim
    static var name: String { get }
    
    /// Value of the claim
    var content: Content { get }
    
    /// Creates new instance of the claim with desired value
    ///
    /// - Parameter content: value for the claim
    init(content: Content)
    
    /// Checks if `self` does not violates `requirments` in the form of `Self`
    ///
    /// - Parameter requirment: claim that is required / expected
    /// - Returns: true is `self` is valid relatively to `requirment`
    func isValid(for requirment: Self?) -> Bool
}

// MARK: - Default implementation

extension Claim {
    public func isValid(for requirment: Self?) -> Bool {
        return true
    }
    
    public var rawValue: Content {
        return content
    }
    
    public init?(rawValue: Content) {
        self.init(content: rawValue)
    }
}

extension Claim where Content: Equatable {
    public func isValid(for requirment: Self?) -> Bool {
        guard let requirment = requirment else {
            return true
        }
        
        return content == requirment.content
    }
}

// Generics are shit

//public extension Claim where Content: Integer {
//    public var rawValue: Content {
//        return content
//    }
//    
//    public init?(rawValue: Content) {
//        self.init(content: rawValue)
//    }
//}
//
//public extension Claim where Content: FloatingPoint {
//    public var rawValue: Content {
//        return content
//    }
//    
//    public init?(rawValue: Content) {
//        self.init(content: rawValue)
//    }
//}
//
//public extension Claim where Content == String {
//    public typealias RawValue = String
//    
//    public var rawValue: String {
//        return content
//    }
//    public init?(rawValue: String) {
//        self.init(content: rawValue)
//    }
//}
//
//public extension Claim where Content == Date {
//    public typealias RawValue = TimeInterval
//
//    public var rawValue: TimeInterval {
//        return content.timeIntervalSince1970
//    }
//    public init?(rawValue: TimeInterval) {
//        let date = Date(timeIntervalSince1970: rawValue)
//        self.init(content: date)
//    }
//}
