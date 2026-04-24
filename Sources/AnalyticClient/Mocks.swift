import Dependencies

extension DependencyValues {
    public var analyticClient: AnalyticClient {
        get { self[AnalyticClient.self] }
        set { self[AnalyticClient.self] = newValue }
    }
}

extension AnalyticClient: TestDependencyKey {
    public static var testValue: Self { Self() }
    public static var previewValue: Self { Self() }
}

extension AnalyticClient {
    /// No-op mock — all calls succeed silently. Useful when a test doesn't care about analytics.
    public static let noop: Self = .init(
        trackScreen:                    { _, _ in },
        trackEvent:                     { _, _ in },
        setUserID:                      { _ in },
        setUserProperty:                { _, _ in },
        setAnalyticsCollectionEnabled:  { _ in },
        log:                            { _ in },
        recordError:                    { _, _ in }
    )
}
