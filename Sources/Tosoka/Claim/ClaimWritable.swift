import Foundation

public protocol ClaimWritable {
    static func +=<T: Claim>(token: inout Self, claim: T)
}
