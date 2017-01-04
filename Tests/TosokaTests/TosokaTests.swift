import XCTest
@testable import Tosoka

class TosokaTests: XCTestCase {
    
    let signature = Signature.sha256("secret")
    
    func testDecoding() {
        do {
            let token = try Tosoka.makeToken(signature: signature)
            let _ = try Tosoka(token: token, signature: signature)
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingPayload() {
        do {
            let subject = Subject(content: "123")
            let token = try Tosoka.makeToken(signature: signature) { tosoka in
                tosoka += subject
            }
            
            let decodedToken = try Tosoka(token: token, signature: signature)
            let decodedSubject = decodedToken ~> Subject.self
            
            XCTAssertEqual(subject.content, decodedSubject?.content)
        } catch {
            XCTFail()
        }
    }
    
    func testExpiringClaim() {
        do {
            let expiringClaim = Expiring(content: Date(timeIntervalSinceNow: 1000))
            let expiredClaim = Expiring(content: Date(timeIntervalSinceNow: -10))
            
            let token = try Tosoka.makeToken(signature: signature) { tosoka in
                tosoka += expiringClaim
            }
            
            let notExpiredToken = try Tosoka(token: token, signature: signature)
            guard let decodedExpiringClaim = notExpiredToken ~> Expiring.self else {
                XCTFail()
                return
            }
            
            XCTAssertEqualWithAccuracy(expiringClaim.content.timeIntervalSince1970, decodedExpiringClaim.content.timeIntervalSince1970, accuracy: 0.01)
            
            let expiredToken = try Tosoka.makeToken(signature: signature) { tosoka in
                tosoka += expiredClaim
            }
            
            XCTAssertThrowsError(try Tosoka(token: expiredToken, signature: signature), "Token should be expired") { error in
                XCTAssert((error as? TokenError) == .expired)
            }
        } catch {
            XCTFail()
        }
    }

    static var allTests : [(String, (TosokaTests) -> () throws -> Void)] {
        return [
//            ("testExample", testExample),
        ]
    }
}
