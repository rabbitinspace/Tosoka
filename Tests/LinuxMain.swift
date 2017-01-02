import XCTest
@testable import TosokaTests

XCTMain([
     testCase(TosokaTests.allTests),
     testCase(Base64URLSafeDecodingTests.allTests),
     testCase(Base64URLSafeEncodingTests.allTests),
     testCase(JSONBase64Tests.allTests),
])
