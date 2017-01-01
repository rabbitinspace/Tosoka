import Foundation
import XCTest
@testable import Tosoka

class Base64URLSafeDecodingTests: XCTestCase {
    
    // MARK: - Tests
    
//    func testJSON() {
//        let encoded = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
//        guard let data = encoded.data(using: .utf8) else {
//            XCTFail()
//            return
//        }
//        
//        let decoded = try! coder.decode(data)
//        let json = try? JSONSerialization.jsonObject(with: decoded, options: .allowFragments)
//        print(json as Any)
//    }
//    
//    func testJSON2() {
//        let json = [
//            "sub": "123456\n7890",
//            "name": "John Doe",
//            "admin": true
//        ] as [String : Any]
//        
//        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
//        let encoded = coder.encode(data, withPadding: true)
//        
//        XCTAssertEqual(
//            encoded,
//            data.base64EncodedData()
//        )
//        
//        let decoded = try? coder.decode(encoded)
//        let newJSON = (try? JSONSerialization.jsonObject(with: decoded ?? Data(), options: [])) as? [String: Any]
//        
//        XCTAssert(json.count == newJSON?.count && json.count == 3)
//        
//        XCTAssertEqual(
//            json["sub"] as? String,
//            newJSON?["sub"] as? String
//        )
//        
//        XCTAssertEqual(
//            json["name"] as? String,
//            newJSON?["name"] as? String
//        )
//        
//        XCTAssertEqual(
//            json["admin"] as? String,
//            newJSON?["admin"] as? String
//        )
//    }
    
    func testDecodingWithoutPadding() {
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhc3Vy"),
            "any carnal pleasur"
        )
    }
    
    func testDecodingWithOnePadding() {
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhc3VyZS4="),
            "any carnal pleasure."
            
        )
        
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhc3U="),
            "any carnal pleasu"
        )
    }
    
    func testDecodingWithTwoPadding() {
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhc3VyZQ=="),
            "any carnal pleasure"
            
        )
        
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhcw=="),
            "any carnal pleas"
        )
    }
    
    func testDecodingWithOneDisabledPadding() {
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhc3VyZS4"),
            "any carnal pleasure."
        )
        
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhc3U"),
            "any carnal pleasu"
        )
    }
    
    func testDecodingWithTwoDisabledPadding() {
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhc3VyZQ"),
            "any carnal pleasure"
        )
        
        XCTAssertEqual(
            decode("YW55IGNhcm5hbCBwbGVhcw"),
            "any carnal pleas"
        )
    }
    
    // MARK: - rfc4648 test vectors
    
    func testStandardTestVectorsWithPadding() {
        XCTAssertEqual(
            decode(""),
            ""
        )
        
        XCTAssertEqual(
            decode("Zg=="),
            "f"
        )
        
        XCTAssertEqual(
            decode("Zm8="),
            "fo"
        )
        
        XCTAssertEqual(
            decode("Zm9v"),
            "foo"
        )
        
        XCTAssertEqual(
            decode("Zm9vYg=="),
            "foob"
        )
        
        XCTAssertEqual(
            decode("Zm9vYmE="),
            "fooba"
        )
        
        XCTAssertEqual(
            decode("Zm9vYmFy"),
            "foobar"
        )
    }
    
    func testStandardTestVectorsWithoutPadding() {
        XCTAssertEqual(
            decode(""),
            ""
        )
        
        XCTAssertEqual(
            decode("Zg"),
            "f"
        )
        
        XCTAssertEqual(
            decode("Zm8"),
            "fo"
        )
        
        XCTAssertEqual(
            decode("Zm9v"),
            "foo"
        )
        
        XCTAssertEqual(
            decode("Zm9vYg"),
            "foob"
        )
        
        XCTAssertEqual(
            decode("Zm9vYmE"),
            "fooba"
        )
        
        XCTAssertEqual(
            decode("Zm9vYmFy"),
            "foobar"
        )
    }
    
    // MARK: - Private
    
    private func decode(_ string: String) -> String? {
        guard let data = string.data(using: .utf8) else {
            XCTFail()
            return nil
        }
        
        let coder = Base64(coder: URLSafeCodingAlphabet.self)
        guard let result = try? coder.decode(data) else {
            XCTFail()
            return nil
        }
        
        return String(data: result, encoding: .utf8)
    }
}
