import XCTest
// SolverService.swift is compiled into this test target.

final class SolverTests: XCTestCase {
    private let solver = OnDeviceSolver()

    func testBasicArithmetic() throws {
        XCTAssertEqual(try solver.solve(text: "2 + 2").answer, "4")
        XCTAssertEqual(try solver.solve(text: "100 - 58").answer, "42")
    }

    func testOperatorPrecedenceAndParentheses() throws {
        XCTAssertEqual(try solver.solve(text: "12 * (3 + 4)").answer, "84")
        XCTAssertEqual(try solver.solve(text: "2 + 3 * 4").answer, "14")
    }

    func testUnicodeOperatorsNormalized() throws {
        XCTAssertEqual(try solver.solve(text: "6 × 7").answer, "42")
        XCTAssertEqual(try solver.solve(text: "20 ÷ 4").answer, "5")
    }

    func testDecimalResult() throws {
        let r = try solver.solve(text: "10 / 4")
        XCTAssertEqual(r.answer, "2.5")
    }

    func testNonMathThrows() {
        XCTAssertThrowsError(try solver.solve(text: "hello there"))
    }

    func testStepsProvided() throws {
        XCTAssertFalse(try solver.solve(text: "1 + 1").steps.isEmpty)
    }
}
