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
    
    func testEncodingEmptyString() {
        XCTAssertEqual(
            encode("", withExpectedOutputLength: 0, isPaddingEnabled: true),
            ""
        )

        XCTAssertEqual(
            encode("", withExpectedOutputLength: 0, isPaddingEnabled: false),
            ""
        )
    }
    
    func testEncodingWithoutPadding() {
        let input = "any carnal pleasur"
        let output = "YW55IGNhcm5hbCBwbGVhc3Vy"
        let length = 24

        XCTAssertEqual(encode(input, withExpectedOutputLength: length, isPaddingEnabled: true), output)

        XCTAssertEqual(encode(input, withExpectedOutputLength: length, isPaddingEnabled: false), output)
    }
    
    func testEncodingWithOnePadding() {
        XCTAssertEqual(
            encode("any carnal pleasure.", withExpectedOutputLength: 28, isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhc3VyZS4="
        )

        XCTAssertEqual(
            encode("any carnal pleasu", withExpectedOutputLength: 24, isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhc3U="
        )
    }
    
    func testEncodingWithTwoPaddings() {
        XCTAssertEqual(
            encode("any carnal pleasure", withExpectedOutputLength: 28, isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhc3VyZQ=="
        )

        XCTAssertEqual(
            encode("any carnal pleas", withExpectedOutputLength: 24, isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhcw=="
        )
    }
    
    func testEncodingWithOneDisabledPadding() {
        XCTAssertEqual(
            encode("any carnal pleasure.", withExpectedOutputLength: 27, isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhc3VyZS4"
        )

        XCTAssertEqual(
            encode("any carnal pleasu", withExpectedOutputLength: 23, isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhc3U"
        )
    }
    
    func testEncodingWithTwoDisabledPaddings() {
        XCTAssertEqual(
            encode("any carnal pleasure", withExpectedOutputLength: 26, isPaddingEnabled: false)
            , "YW55IGNhcm5hbCBwbGVhc3VyZQ"
        )

        XCTAssertEqual(
            encode("any carnal pleas", withExpectedOutputLength: 22, isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhcw"
        )
    }
    
    private func encode(_ string: String, withExpectedOutputLength expectedOutputLength: Int, isPaddingEnabled: Bool) -> String? {
        guard let data = string.data(using: .utf8) else {
            XCTFail()
            return nil
        }
        
        let result = coder.encode(data, withPadding: isPaddingEnabled)
        XCTAssertEqual(result.count, expectedOutputLength)
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


