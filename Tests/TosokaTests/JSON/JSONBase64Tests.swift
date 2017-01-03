import Foundation
import XCTest
@testable import Tosoka

class JSONBase64Tests: XCTestCase {
    
    // MARK: - Properties
    
    var base64Coder: Base64<URLSafeCodingAlphabet>!
    var jsonCoder: JSONCoding!
    
    // MARK: - Preparations
    
    override func setUp() {
        super.setUp()
        
        base64Coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: false)
        jsonCoder = JSONCoder()
        
        // TODO: - Remove comments if JSONSerialization works fine on swift3.1-dev
//        #if os(macOS)
//            jsonCoder = JSONCoder()
//        #else
//            jsonCoder = LinuxJSONCoder()
//        #endif
    }
    
    // MARK: - Tests
    
    func testHeaderJSON() {
        let header = [
            "alg": "HS256",
            "typ": "JWT"
        ]
        
        guard let headerData = jsonCoder.makeData(with: header) else {
            XCTFail()
            return
        }
        
        let systemEncodedHeaderString = encode(headerData)
        let customEncodedHeaderData = base64Coder.encode(headerData)
        
        XCTAssertEqual(
            systemEncodedHeaderString,
            String(data: customEncodedHeaderData, encoding: .utf8)
        )
        
        guard let systemDecodedHeaderData = decode(systemEncodedHeaderString),
            let customDecodedHeaderData = try? base64Coder.decode(customEncodedHeaderData) else {
                XCTFail()
                return
        }
        
        XCTAssertEqual(systemDecodedHeaderData, customDecodedHeaderData)
        XCTAssertEqual(systemDecodedHeaderData, headerData)
        XCTAssertEqual(customDecodedHeaderData, headerData)
        
        guard let headerFromSystemDecoder = jsonCoder.makeJSON(with: systemDecodedHeaderData),
            let headerFromCustomDecoder = jsonCoder.makeJSON(with: customDecodedHeaderData) else {
                XCTFail()
                return
        }
        
        XCTAssertEqual(
            headerFromCustomDecoder["alg"] as? String,
            headerFromSystemDecoder["alg"] as? String
        )
        
        XCTAssertEqual(
            headerFromCustomDecoder["typ"] as? String,
            headerFromSystemDecoder["typ"] as? String
        )
        
        XCTAssertEqual(
            headerFromCustomDecoder["alg"] as? String,
            header["alg"]
        )
        
        XCTAssertEqual(
            headerFromCustomDecoder["typ"] as? String,
            header["typ"]
        )
    }
    
    // MARK: - Private
    
    // base64 encoding from rfc7515, Appendix C
    private func encode(_ data: Data) -> String {
        let encodedString = data.base64EncodedString().components(separatedBy: "=")[0]
        return encodedString
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    // base64 decoding from rfc7515, Appendix C
    private func decode(_ string: String) -> Data? {
        let encodedString = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let stringToDecode: String
        switch encodedString.utf8.count % 4 {
        case 0, 2, 3:
            stringToDecode = encodedString
            
        case 2:
            stringToDecode = encodedString.appending("==")
            
        case 3:
            stringToDecode = encodedString.appending("=")
            
        default:
            return nil
        }
        
        return Data(base64Encoded: stringToDecode)
    }
    
    // MARK: - All tests
    
    static var allTests : [(String, (JSONBase64Tests) -> () throws -> Void)] {
        return [
            ("testHeaderJSON", testHeaderJSON),
        ]
    }
}
