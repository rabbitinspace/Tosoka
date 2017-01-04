import Foundation

public protocol Claim: RawRepresentable {
    associatedtype Content
    
    static var name: String { get }
    
    var content: Content { get }
    
    init(content: Content)
    
    func isValid(for requirment: Self?) -> Bool
}

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
