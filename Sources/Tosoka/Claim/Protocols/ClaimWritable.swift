import Foundation

/// Provides type-safe write access to claims values
public protocol ClaimWritable {
    
    /// Adds `claim` to `token` claims
    ///
    /// - Parameters:
    ///   - token: claim holder to add new claim
    ///   - claim: new claim to be added
    static func +=<T: Claim>(token: inout Self, claim: T)
}
