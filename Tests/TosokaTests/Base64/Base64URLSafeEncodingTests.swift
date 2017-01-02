import XCTest
@testable import Tosoka

class Base64URLSafeEncodingTests: XCTestCase {
    
    // MARK: - Tests
    
    func testEncodingWithoutPadding() {
        let input = "any carnal pleasur"
        let output = "YW55IGNhcm5hbCBwbGVhc3Vy"

        XCTAssertEqual(encode(input, isPaddingEnabled: true), output)
        XCTAssertEqual(encode(input, isPaddingEnabled: false), output)
    }
    
    func testEncodingWithOnePadding() {
        XCTAssertEqual(
            encode("any carnal pleasure.", isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhc3VyZS4="
        )

        XCTAssertEqual(
            encode("any carnal pleasu", isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhc3U="
        )
    }
    
    func testEncodingWithTwoPadding() {
        XCTAssertEqual(
            encode("any carnal pleasure", isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhc3VyZQ=="
        )

        XCTAssertEqual(
            encode("any carnal pleas", isPaddingEnabled: true),
            "YW55IGNhcm5hbCBwbGVhcw=="
        )
    }
    
    func testEncodingWithOneDisabledPadding() {
        XCTAssertEqual(
            encode("any carnal pleasure.", isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhc3VyZS4"
        )

        XCTAssertEqual(
            encode("any carnal pleasu", isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhc3U"
        )
    }
    
    func testEncodingWithTwoDisabledPadding() {
        XCTAssertEqual(
            encode("any carnal pleasure", isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhc3VyZQ"
        )

        XCTAssertEqual(
            encode("any carnal pleas", isPaddingEnabled: false),
            "YW55IGNhcm5hbCBwbGVhcw"
        )
    }
    
    // MARK: - rfc4648 test vectors

    func testStandardTestVectorsWithPadding() {
        XCTAssertEqual(
            encode("", isPaddingEnabled: true),
            ""
        )
        
        XCTAssertEqual(
            encode("f", isPaddingEnabled: true),
            "Zg=="
        )

        XCTAssertEqual(
            encode("fo", isPaddingEnabled: true),
            "Zm8="
        )

        XCTAssertEqual(
            encode("foo", isPaddingEnabled: true),
            "Zm9v"
        )

        XCTAssertEqual(
            encode("foob", isPaddingEnabled: true),
            "Zm9vYg=="
        )

        XCTAssertEqual(
            encode("fooba", isPaddingEnabled: true),
            "Zm9vYmE="
        )

        XCTAssertEqual(
            encode("foobar", isPaddingEnabled: true),
            "Zm9vYmFy"
        )
    }

    func testStandardTestVectorsWithoutPadding() {
        XCTAssertEqual(
            encode("", isPaddingEnabled: false),
            ""
        )
        
        XCTAssertEqual(
            encode("f", isPaddingEnabled: false),
            "Zg"
        )

        XCTAssertEqual(
            encode("fo", isPaddingEnabled: false),
            "Zm8"
        )

        XCTAssertEqual(
            encode("foo", isPaddingEnabled: false),
            "Zm9v"
        )

        XCTAssertEqual(
            encode("foob", isPaddingEnabled: false),
            "Zm9vYg"
        )

        XCTAssertEqual(
            encode("fooba", isPaddingEnabled: false),
            "Zm9vYmE"
        )

        XCTAssertEqual(
            encode("foobar", isPaddingEnabled: false),
            "Zm9vYmFy"
        )
    }
    
    // MARK: - Private
    
    private func encode(_ string: String, isPaddingEnabled: Bool) -> String? {
        guard let data = string.data(using: .utf8) else {
            XCTFail()
            return nil
        }
        
        let coder = Base64(coder: URLSafeCodingAlphabet.self, isPaddingEnabled: isPaddingEnabled)
        
        let result = coder.encode(data)
        return String(data: result, encoding: .utf8)
    }
    
    // MARK: - All tests
    
    static var allTests : [(String, (Base64URLSafeEncodingTests) -> () throws -> Void)] {
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


