# AnalyticClient

A TCA-style dependency client wrapping Firebase Analytics + Crashlytics behind a uniform `trackEvent` / `trackScreen` / `setUserProperty` / `recordError` surface. Includes an OS Logger for tracing every call through Console.app.

## Layout

- **`AnalyticClient`** — interface: `initialize`, `trackScreen`, `trackEvent`, `setUserID`, `setUserProperty`, `setAnalyticsCollectionEnabled`, `log`, `recordError`, plus a `Param` value type and `AnalyticConfig`. Ships a `Logger.analyticClient` static so the live impl (and downstream code) can route events through OSLog with a known subsystem.
- **`AnalyticClientLive`** — Firebase Analytics + Crashlytics wrapper that registers the live `DependencyKey` and emits OS Logger info / notice events as it crosses the façade.

## Installation

```swift
.package(url: "https://github.com/mahainc/AnalyticClient.git", from: "1.1.0"),
```

`AnalyticClient` on feature targets; `AnalyticClientLive` on the app target.

## Configure Firebase

Ensure `FirebaseApp.configure()` runs at app launch (typically in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`). Ship `GoogleService-Info.plist` in the app target.

Then initialize the client at app start:

```swift
import AnalyticClient

@Dependency(\.analyticClient) var analytics

await analytics.initialize(AnalyticConfig(/* … */))
```

## Usage

```swift
import AnalyticClient
import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    enum Action {
        case onAppear
        case startTapped
    }

    @Dependency(\.analyticClient) var analytics

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    await analytics.trackScreen("Onboarding", [:])
                }

            case .startTapped:
                return .run { _ in
                    await analytics.trackEvent("onboarding_start_tapped", [:])
                }
            }
        }
    }
}
```

## Console tracing

Every call routes through `Logger.analyticClient` (subsystem `com.mahainc.AnalyticClient`, category `live`):

```bash
log stream --predicate 'subsystem == "com.mahainc.AnalyticClient"'
```

`.info` for normal traffic, `.notice` when Firebase will silently drop a payload (reserved param prefix, etc.).

## Testing

`@DependencyClient` generates unimplemented `testValue` defaults:

```swift
let store = TestStore(initialState: OnboardingFeature.State()) {
    OnboardingFeature()
} withDependencies: {
    $0.analyticClient.trackEvent = { _, _ in }
    $0.analyticClient.trackScreen = { _, _ in }
}
```

## Dependencies

- `swift-dependencies` from 1.9.0
- `swift-case-paths` from 1.5.0
- `firebase-ios-sdk` (FirebaseAnalytics + FirebaseCrashlytics) from 12.13.0

## Platform support

- iOS 16+

## License

MIT — see [LICENSE](./LICENSE).
