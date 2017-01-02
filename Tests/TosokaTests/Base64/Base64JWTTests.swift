import Foundation
import XCTest
@testable import Tosoka

class Base64JWTTests: XCTestCase {
    
    // MARK: - Properties
    
    var coder: Base64<URLSafeCodingAlphabet>!
    
    // MARK: - Preparations
    
    override func setUp() {
        super.setUp()
        coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
    }
    
    // MARK: - Tests
    
    
    
    // MARK: - Base64 encoding/decoding
    
    // from rfc7515, Appendix C
    private func encode(_ data: Data) -> String {
        let encodedString = data.base64EncodedString().components(separatedBy: "=")[0]
        return encodedString
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    // from rfc7515, Appendix C
    private func decode(_ string: String) -> Data? {
        let encodedString = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let stringToDecode: String
        switch encodedString.utf8.count {
        case 2:
            stringToDecode = encodedString.appending("==")
            
        case 3:
            stringToDecode = encodedString.appending("=")
        
        default:
            return nil
        }
        
        return Data(base64Encoded: stringToDecode)
    }
}
