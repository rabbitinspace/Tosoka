import Foundation
import CCrypto

// TODO: Should use JSON Web Key instead of strings
public enum Signature {
    case sha256(String)
    case sha512(String)
}

extension Signature {
    var algorithm: String {
        switch self {
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
    
    func signingToken(_ token: String) throws -> String {
        let engine: UnsafePointer<EVP_MD>
        let secretKey: String
        
        switch self {
        case let .sha256(key):
            secretKey = key
            engine = EVP_sha256()
            
        case let .sha512(key):
            secretKey = key
            engine = EVP_sha512()
        }
        
        return try macString(token, withKey: secretKey, using: engine)
    }
    
    // MARK: - Private
    
    private func macString(_ string: String, withKey key: String, using engine: UnsafePointer<EVP_MD>) throws -> String {
        guard let digest = HMAC(engine, key, Int32(key.utf8.count), string, string.utf8.count, nil, nil) else {
            throw SigningError.failed
        }
        
        return String(cString: digest)
    }
}

