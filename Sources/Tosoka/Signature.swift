import Foundation
import CCrypto

// TODO: Should use JSON Web Key instead of strings

/// Signing algorithm
///
/// - none: no signing
/// - sha256: hmac-sha256 using secret key
/// - sha512: hmac-sha512 using secret key
public enum Signature {
    case none
    case sha256(String)
    case sha512(String)
}

extension Signature {
    /// string representation of `self` according to rfc7519
    var algorithm: String {
        switch self {
        case .none:
            return "none"
            
        case .sha256:
            return "HS256"

        case .sha512:
            return "HS512"
        }
    }
}

extension Signature {
    
    // MARK: - Public types
    
    /// Error that may occur while computing signature
    ///
    /// - failed: signing failed and error isn't known
    public enum SigningError: Error {
        case failed
    }
    
    // MARK: - Methods
    
    /// Return signature for provided `string`
    ///
    /// - Parameter string: string to sign
    /// - Returns: signature for `string`
    /// - Throws: `SigningError`
    func signing(_ string: String) throws -> String {
        let engine: UnsafePointer<EVP_MD>
        let secretKey: String
        
        switch self {
        case .none:
            return ""
            
        case let .sha256(key):
            secretKey = key
            engine = EVP_sha256()
            
        case let .sha512(key):
            secretKey = key
            engine = EVP_sha512()
        }
        
        return try macString(string, withKey: secretKey, using: engine)
    }
    
    // MARK: - Private
    
    /// Calculates mac for `string` with secret `key` using `engine` as hash function
    ///
    /// - Parameters:
    ///   - string: string to be mac-ed
    ///   - key: secret key used for hash calculating
    ///   - engine: hash functionfor mac calculation
    /// - Returns: mac for provided `string`
    /// - Throws: `SigningError`
    private func macString(_ string: String, withKey key: String, using engine: UnsafePointer<EVP_MD>) throws -> String {
        guard let digest = HMAC(engine, key, Int32(key.utf8.count), string, string.utf8.count, nil, nil) else {
            throw SigningError.failed
        }
        
        return String(cString: digest)
    }
}

