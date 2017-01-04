import Foundation

infix operator ~> 

public protocol ClaimReadable {
    static func ~><T: Claim>(token: Self, claim: T.Type) -> T?
}
