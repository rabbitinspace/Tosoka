import Foundation
import XCTest
@testable import Tosoka

class Base64DecodingTests: XCTestCase {
    
    // MARK: - Properties
    
    var coder: Base64<URLSafeCodingAlphabet>!
    
    // MARK: - Preparations
    
    override func setUp() {
        super.setUp()
        
        coder = Base64(coder: URLSafeCodingAlphabet.self)
    }
    
    // MARK: - Tests
    
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
        
        guard let result = try? coder.decode(data) else {
            XCTFail()
            return nil
        }
        
        return String(data: result, encoding: .utf8)
    }
}
