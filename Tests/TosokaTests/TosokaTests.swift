import XCTest
@testable import Tosoka

class TosokaTests: XCTestCase {

    let signature = Signature.sha256("secret")

    // MARK: - Decoding

    func testDecoding() {
        do {
            let token = try Tosoka.makeToken(signature: signature)
            let _ = try Tosoka(token: token, signature: signature)
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingWithoutSignature() {
        do {
            let token = try Tosoka.makeToken(signature: .none)
            let _ = try Tosoka(token: token, signature: .none)
        } catch {
            XCTFail()
        }
    }

    func testDecodingPayload() {
        do {
            let subject = Subject(content: "123")
            let token = try Tosoka.makeToken(signature: signature) { tosoka in
                tosoka += subject
                tosoka["user_id"] = 123
                tosoka["is_admin"] = false
            }

            let decodedToken = try Tosoka(token: token, signature: signature)
            let decodedSubject = decodedToken ~> Subject.self

            XCTAssertEqual(subject.content, decodedSubject?.content)
            XCTAssertEqual(decodedToken["user_id"] as? Int, 123)
            XCTAssertEqual(decodedToken["is_admin"] as? Bool, false)
        } catch {
            XCTFail()
        }
    }

    func testExpiringClaimDecoding() {
        do {
            let expiringClaim = Expiring(content: Date(timeIntervalSinceNow: 1000))
            let expiredClaim = Expiring(content: Date(timeIntervalSinceNow: -10))

            let encodedToken = try Tosoka.makeToken(signature: signature) { $0 += expiringClaim }

            let notExpiredToken = try Tosoka(token: encodedToken, signature: signature)
            guard let decodedExpiringClaim = notExpiredToken ~> Expiring.self else {
                XCTFail()
                return
            }

            XCTAssertEqualWithAccuracy(expiringClaim.content.timeIntervalSince1970, decodedExpiringClaim.content.timeIntervalSince1970, accuracy: 0.01)

            let expiredToken = try Tosoka.makeToken(signature: signature) { $0 += expiredClaim }

            XCTAssertThrowsError(try Tosoka(token: expiredToken, signature: signature), "Token should be expired") { error in
                XCTAssert((error as? TokenError) == .expired)
            }
        } catch {
            XCTFail()
        }
    }

    func testNotBeforeClaimDecoding() {
        do {
            let pastClaim = NotBefore(content: Date.distantPast)
            let futureClaim = NotBefore(content: Date.distantFuture)

            var encodedToken = try Tosoka.makeToken(signature: signature) { $0 += pastClaim }
            let validToken = try Tosoka(token: encodedToken, signature: signature)
            guard let decodedPastClaim = validToken ~> NotBefore.self else {
                XCTFail()
                return
            }

            XCTAssertEqualWithAccuracy(pastClaim.content.timeIntervalSince1970, decodedPastClaim.content.timeIntervalSince1970, accuracy: 0.01)

            encodedToken = try Tosoka.makeToken(signature: signature) { $0 += futureClaim }
            XCTAssertThrowsError(try Tosoka(token: encodedToken, signature: signature), "Token should be invalid") { error in
                XCTAssert((error as? TokenError) == .fromFuture)
            }
        } catch {
            XCTFail()
        }
    }

    func testAudienceClaimDecoding() {
        do {
            let targetAudience = Audience(content: ["group1", "group2"])
            let currentAudience = Audience(content: "group1")
            let wrongAudience = Audience(rawValue: ["group1, group3"])

            let encodedToken = try Tosoka.makeToken(signature: signature) { $0 += targetAudience }

            let token = try Tosoka(token: encodedToken, signature: signature)
            guard let decodedAudience = token ~> Audience.self else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetAudience.content, decodedAudience.content)

            let _ = try Tosoka(token: encodedToken, for: targetAudience, signature: signature)
            let _ = try Tosoka(token: encodedToken, for: currentAudience, signature: signature)

            XCTAssertThrowsError(try Tosoka(token: encodedToken, for: wrongAudience, signature: signature),
                "Token must be rejected due to wrong audience") { error in
                    XCTAssert((error as? TokenError) == .invalidAudience)
            }
        } catch {
            XCTFail()
        }
    }

    // MARK: - Signature

    func testWrongSignature() {
        do {
            let encodedToken = try Tosoka.makeToken(signature: signature)
            
            XCTAssertThrowsError(
                try Tosoka(token: encodedToken, signature: .sha512("secret")),
                "Should throw because of bad signature"
            ) { error in
                XCTAssert((error as? TokenError) == .corrupted)
            }
            
            XCTAssertThrowsError(
                try Tosoka(token: encodedToken, signature: .none),
                "Should throw because of bad signature"
            ) { error in
                XCTAssert((error as? TokenError) == .corrupted)
            }
        } catch {
            XCTFail()
        }
    }

    func testCorruptedSignature() {
        do {
            let encodedToken = try Tosoka.makeToken(signature: signature)
            let differentToken = try Tosoka.makeToken(signature: .sha512("secret"))
            
            var tokenParts = encodedToken.characters.split(separator: ".").map { String.init($0) }
            tokenParts[2] = .init(differentToken.characters.split(separator: ".")[2])
            
            let resignedToken = tokenParts.joined(separator: ".")
            XCTAssertThrowsError(
                try Tosoka(token: resignedToken, signature: signature),
                "Should throw because of bad signature"
            ) { error in
                XCTAssert((error as? TokenError) == .corrupted)
            }
        } catch {
            XCTFail()
        }
    }

    // MARK: - All tests

    static var allTests : [(String, (TosokaTests) -> () throws -> Void)] {
        return [
           ("testDecoding", testDecoding),
           ("testDecodingWithoutSignature", testDecodingWithoutSignature),
           ("testDecodingPayload", testDecodingPayload),
           ("testExpiringClaimDecoding", testExpiringClaimDecoding),
           ("testNotBeforeClaimDecoding", testNotBeforeClaimDecoding),
           ("testAudienceClaimDecoding", testAudienceClaimDecoding),
           ("testWrongSignature", testWrongSignature),
           ("testCorruptedSignature", testCorruptedSignature),
        ]
    }
}
