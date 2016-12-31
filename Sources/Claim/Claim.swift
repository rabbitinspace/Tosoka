import Foundation

public protocol Claim: ClaimReadable {
    var content: Content { get }
}
