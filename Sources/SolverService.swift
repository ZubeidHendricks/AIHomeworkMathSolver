import UIKit
import Vision

enum SolveError: Error { case badImage, noExpression, notConfigured }

struct SolveResult {
    let expression: String
    let answer: String
    let steps: [String]
}

protocol MathSolving {
    /// Recognize math text in a photo and solve arithmetic on-device.
    func solve(image: UIImage) async throws -> SolveResult
    /// Solve a typed expression.
    func solve(text: String) throws -> SolveResult
}

/// On-device: Vision OCR extracts the expression, then it's evaluated locally.
/// Handles arithmetic (+ − × ÷, parentheses, powers, %). Full step-by-step
/// algebra/word-problems is the Remote (LLM) upgrade.
struct OnDeviceSolver: MathSolving {
    func solve(image: UIImage) async throws -> SolveResult {
        guard let cg = image.cgImage else { throw SolveError.badImage }
        let text: String = await withCheckedContinuation { cont in
            let request = VNRecognizeTextRequest { req, _ in
                let s = (req.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: " ") ?? ""
                cont.resume(returning: s)
            }
            request.recognitionLevel = .accurate
            try? VNImageRequestHandler(cgImage: cg, options: [:]).perform([request])
        }
        return try solve(text: text)
    }

    func solve(text: String) throws -> SolveResult {
        let cleaned = Self.normalize(text)
        guard !cleaned.isEmpty else { throw SolveError.noExpression }
        guard let value = Self.evaluate(cleaned) else { throw SolveError.noExpression }
        let answer = Self.format(value)
        return SolveResult(
            expression: cleaned,
            answer: answer,
            steps: ["Read: \(cleaned)", "Evaluate left to right with operator precedence", "= \(answer)"]
        )
    }

    /// Turn human/OCR math into an NSExpression-friendly string.
    static func normalize(_ raw: String) -> String {
        var s = raw
        let map: [String: String] = ["×": "*", "✕": "*", "·": "*", "÷": "/", "−": "-", "—": "-", "^": "**", "=": ""]
        for (k, v) in map { s = s.replacingOccurrences(of: k, with: v) }
        // Keep only math characters.
        let allowed = Set("0123456789.+-*/()% ")
        s = String(s.filter { allowed.contains($0) })
        return s.trimmingCharacters(in: .whitespaces)
    }

    static func evaluate(_ expr: String) -> Double? {
        guard expr.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil else { return nil }
        // NSExpression does INTEGER division on integer literals (10/4 -> 2), so
        // promote standalone integer literals to decimals to force float math.
        let floatized = expr.replacingOccurrences(
            of: #"(?<![\d.])(\d+)(?![\d.])"#,
            with: "$1.0",
            options: .regularExpression)
        let expression = NSExpression(format: floatized)
        guard let result = expression.expressionValue(with: nil, context: nil) as? NSNumber else { return nil }
        return result.doubleValue
    }

    static func format(_ value: Double) -> String {
        if value == value.rounded() && abs(value) < 1e15 {
            return String(Int(value))
        }
        return String(format: "%g", value)
    }
}

/// Production solver (LLM) with full step-by-step + algebra/word problems.
struct RemoteSolver: MathSolving {
    let apiKey: String
    func solve(image: UIImage) async throws -> SolveResult { throw SolveError.notConfigured }
    func solve(text: String) throws -> SolveResult { throw SolveError.notConfigured }
}
