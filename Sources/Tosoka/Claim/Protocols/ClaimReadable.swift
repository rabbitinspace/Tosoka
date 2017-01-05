import Foundation

infix operator ~> 

/// Provides type-safe read access to claims and it's values
public protocol ClaimReadable {
    
    /// Returns typed value from `token` for the `claim` of type `T`
    ///
    /// - Parameters:
    ///   - token: holder of the claims
    ///   - claim: type of the claim that will be read
    /// - Returns: value of the `claim`
    static func ~><T: Claim>(token: Self, claim: T.Type) -> T?
}
