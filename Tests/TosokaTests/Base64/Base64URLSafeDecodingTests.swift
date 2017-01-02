import Foundation
import XCTest
@testable import Tosoka

class Base64URLSafeDecodingTests: XCTestCase {
    
    // MARK: - Tests

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
    
    // MARK: - All tests
    
    static var allTests : [(String, (Base64URLSafeDecodingTests) -> () throws -> Void)] {
        return [
            ("testDecodingWithoutPadding", testDecodingWithoutPadding),
            ("testDecodingWithOnePadding", testDecodingWithOnePadding),
            ("testDecodingWithTwoPadding", testDecodingWithTwoPadding),
            ("testDecodingWithOneDisabledPadding", testDecodingWithOneDisabledPadding),
            ("testDecodingWithTwoDisabledPadding", testDecodingWithTwoDisabledPadding),
            ("testStandardTestVectorsWithPadding", testStandardTestVectorsWithPadding),
            ("testStandardTestVectorsWithoutPadding", testStandardTestVectorsWithoutPadding),
        ]
    }
}
