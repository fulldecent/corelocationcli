import XCTest

final class CoreLocationCLITests: XCTestCase {
    func testSanity() {
        // Basic smoke test to ensure the test target is wired up.
        XCTAssertTrue(true)
    }
}

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(CoreLocationCLITests.allTests)
        ]
    }
#endif

extension CoreLocationCLITests {
    static var allTests = [
        ("testSanity", testSanity)
    ]
}
