import Foundation

/// Provides raw access to claims and it's values
public protocol ClaimAccessible {
    
    /// Accesses `claim`'s value
    ///
    /// - Parameter claim: name of the claim
    subscript(claim: String) -> Any? { get set }
    
    /// Accessor for value of reserved `claim`
    ///
    /// - Parameter claim: reserved claim
    subscript(claim: ReservedClaim) -> Any? { get set }
}
