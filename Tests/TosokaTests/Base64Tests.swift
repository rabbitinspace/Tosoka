import XCTest
@testable import Tosoka

class Base64Tests: XCTestCase {
    
    // MARK: - Properties
    
    var coder: Base64<URLSafeCodingAlphabet>!
    
    // MARK: - Preparations
    
    override func setUp() {
        super.setUp()
        
        coder = Base64(coder: URLSafeCodingAlphabet.self)
    }
    
    // MARK: - Encoding
    
    func testEncodingWithoutPadding() {
        XCTAssertEqual(encode("any carnal pleasur", withExpectedOutputLenght: 24), "YW55IGNhcm5hbCBwbGVhc3Vy")
    }
    
    func testEncodingWithOnePadding() {
        XCTAssertEqual(encode("any carnal pleasure.", withExpectedOutputLenght: 28), "YW55IGNhcm5hbCBwbGVhc3VyZS4=")
        XCTAssertEqual(encode("any carnal pleasu", withExpectedOutputLenght: 24), "YW55IGNhcm5hbCBwbGVhc3U=")
    }
    
    func testEncodingWithTwoPaddings() {
        XCTAssertEqual(encode("any carnal pleasure", withExpectedOutputLenght: 28), "YW55IGNhcm5hbCBwbGVhc3VyZQ==")
        XCTAssertEqual(encode("any carnal pleas", withExpectedOutputLenght: 24), "YW55IGNhcm5hbCBwbGVhcw==")
    }
    
    private func encode(_ string: String, withExpectedOutputLenght expectedOutputLenght: Int) -> String? {
        guard let data = string.data(using: .utf8) else {
            XCTFail()
            return nil
        }
        
        let result = coder.encode(data)
        XCTAssertEqual(result.count, expectedOutputLenght)
        return String(data: result, encoding: .utf8)
    }
    
    // MARK: - Decoding
    
    
    
    // MARK: - All tests
    
    static var allTests : [(String, (Base64Tests) -> () throws -> Void)] {
        return [
            ("testEncodingWithoutPadding", testEncodingWithoutPadding),
            ("testEncodingWithOnePadding", testEncodingWithOnePadding),
            ("testEncodingWithTwoPaddings", testEncodingWithTwoPaddings),
        ]
    }
}


