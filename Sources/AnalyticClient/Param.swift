import Foundation

extension AnalyticClient {
    /// Typed parameter value for analytics events. Widens `[String: String]` so numeric
    /// metrics (revenue, durations, counts) keep their native type for Firebase aggregation.
    /// Conforms to `ExpressibleByStringLiteral` / `…IntegerLiteral` / `…FloatLiteral` /
    /// `…BooleanLiteral` so call sites stay ergonomic:
    ///
    /// ```swift
    /// await analyticClient.trackEvent("purchase", [
    ///     "product_id": "pro.yearly",   // string literal
    ///     "price": 29.99,               // float literal
    ///     "count": 1,                   // int literal
    ///     "gifted": false,              // bool literal
    /// ])
    /// ```
    ///
    /// Named `Param` rather than `Value` because TCA's `TestDependencyKey` protocol
    /// declares an `associatedtype Value = Self` that collides with any nested
    /// `AnalyticClient.Value` at name-lookup time.
    public enum Param: Sendable, Equatable {
        case string(String)
        case int(Int)
        case double(Double)
        case bool(Bool)

        /// The underlying Foundation value suitable for `Analytics.logEvent(_:parameters:)`.
        public var anyValue: Any {
            switch self {
            case .string(let s): return s
            case .int(let i): return i
            case .double(let d): return d
            case .bool(let b): return b
            }
        }

        /// A lossless string form — used by analytics backends that accept only strings,
        /// and by `Crashlytics.record(error:userInfo:)` which takes `[String: Any]`.
        public var stringValue: String {
            switch self {
            case .string(let s): return s
            case .int(let i): return String(i)
            case .double(let d): return String(d)
            case .bool(let b): return String(b)
            }
        }
    }

    /// Convenience alias for the common analytics-params dictionary shape.
    /// Callers that want `[String: AnalyticClient.Param]` can write `AnalyticClient.Params` instead.
    public typealias Params = [String: Param]
}

extension AnalyticClient.Param: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self = .string(value) }
}

extension AnalyticClient.Param: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self = .int(value) }
}

extension AnalyticClient.Param: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self = .double(value) }
}

extension AnalyticClient.Param: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self = .bool(value) }
}
