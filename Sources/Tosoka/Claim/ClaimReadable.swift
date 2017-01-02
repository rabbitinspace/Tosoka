import Foundation

public protocol ClaimReadable {
    associatedtype Content

    static var name: String { get }
}
