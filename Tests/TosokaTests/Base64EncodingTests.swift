import XCTest
@testable import Tosoka

class Base64EncodingTests: XCTestCase {
    
    // MARK: - Properties
    
    var coder: Base64<URLSafeCodingAlphabet>!
    
    // MARK: - Preparations
    
    override func setUp() {
        super.setUp()
        
        coder = Base64(coder: URLSafeCodingAlphabet.self)
    }
    
    // MARK: - Tests
    
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
    
    func testEncodingWithTwoPadding() {
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
    
    func testEncodingWithTwoDisabledPadding() {
        XCTAssertEqual(
            encode("any carnal pleasure", withExpectedOutputLength: 26, isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhc3VyZQ"
        )

        XCTAssertEqual(
            encode("any carnal pleas", withExpectedOutputLength: 22, isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhcw"
        )
    }
    
    // MARK: - rfc4648 test vectors

    func testStandardTestVectorsWithPadding() {
        XCTAssertEqual(
            encode("", withExpectedOutputLength: 0, isPaddingEnabled: true),
            ""
        )
        
        XCTAssertEqual(
            encode("f", withExpectedOutputLength: 4, isPaddingEnabled: true),
            "Zg=="
        )

        XCTAssertEqual(
            encode("fo", withExpectedOutputLength: 4, isPaddingEnabled: true),
            "Zm8="
        )

        XCTAssertEqual(
            encode("foo", withExpectedOutputLength: 4, isPaddingEnabled: true),
            "Zm9v"
        )

        XCTAssertEqual(
            encode("foob", withExpectedOutputLength: 8, isPaddingEnabled: true),
            "Zm9vYg=="
        )

        XCTAssertEqual(
            encode("fooba", withExpectedOutputLength: 8, isPaddingEnabled: true),
            "Zm9vYmE="
        )

        XCTAssertEqual(
            encode("foobar", withExpectedOutputLength: 8, isPaddingEnabled: true),
            "Zm9vYmFy"
        )
    }

    func testStandardTestVectorsWithoutPadding() {
        XCTAssertEqual(
            encode("", withExpectedOutputLength: 0, isPaddingEnabled: false),
            ""
        )
        
        XCTAssertEqual(
            encode("f", withExpectedOutputLength: 2, isPaddingEnabled: false),
            "Zg"
        )

        XCTAssertEqual(
            encode("fo", withExpectedOutputLength: 3, isPaddingEnabled: false),
            "Zm8"
        )

        XCTAssertEqual(
            encode("foo", withExpectedOutputLength: 4, isPaddingEnabled: false),
            "Zm9v"
        )

        XCTAssertEqual(
            encode("foob", withExpectedOutputLength: 6, isPaddingEnabled: false),
            "Zm9vYg"
        )

        XCTAssertEqual(
            encode("fooba", withExpectedOutputLength: 7, isPaddingEnabled: false),
            "Zm9vYmE"
        )

        XCTAssertEqual(
            encode("foobar", withExpectedOutputLength: 8, isPaddingEnabled: false),
            "Zm9vYmFy"
        )
    }
    
    // MARK: - Private
    
    private func encode(_ string: String, withExpectedOutputLength expectedOutputLength: Int, isPaddingEnabled: Bool) -> String? {
        guard let data = string.data(using: .utf8) else {
            XCTFail()
            return nil
        }
        
        let result = coder.encode(data, withPadding: isPaddingEnabled)
        XCTAssertEqual(result.count, expectedOutputLength)
        return String(data: result, encoding: .utf8)
    }
    
    // MARK: - All tests
    
    static var allTests : [(String, (Base64EncodingTests) -> () throws -> Void)] {
        return [
            ("testEncodingWithoutPadding", testEncodingWithoutPadding),
            ("testEncodingWithOnePadding", testEncodingWithOnePadding),
            ("testEncodingWithTwoPadding", testEncodingWithTwoPadding),
            ("testEncodingWithOneDisabledPadding", testEncodingWithOneDisabledPadding),
            ("testEncodingWithTwoDisabledPadding", testEncodingWithTwoDisabledPadding),
            ("testStandardTestVectorsWithPadding", testStandardTestVectorsWithPadding),
            ("testStandardTestVectorsWithoutPadding", testStandardTestVectorsWithoutPadding),
        ]
    }
}


