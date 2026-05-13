import Dependencies
import AnalyticClient
@preconcurrency import FirebaseAnalytics
@preconcurrency import FirebaseCrashlytics

extension AnalyticClient: DependencyKey {
    public static var liveValue: Self {
        .init(
            initialize: { config in
                Analytics.setAnalyticsCollectionEnabled(config.collectionEnabled)
                if let id = config.userID {
                    Crashlytics.crashlytics().setUserID(id)
                    Analytics.setUserID(id)
                }
                for (name, value) in config.userProperties {
                    Analytics.setUserProperty(value, forName: name)
                }
            },
            trackScreen: { name, params in
                var merged: [String: Any] = [
                    AnalyticsParameterScreenName: name,
                    AnalyticsParameterScreenClass: "\(name)View",
                ]
                for (k, v) in params { merged[k] = v.anyValue }
                Analytics.logEvent(AnalyticsEventScreenView, parameters: merged)
            },
            trackEvent: { name, params in
                if params.isEmpty {
                    Analytics.logEvent(name, parameters: nil)
                } else {
                    var dict: [String: Any] = [:]
                    for (k, v) in params { dict[k] = v.anyValue }
                    Analytics.logEvent(name, parameters: dict)
                }
            },
            setUserID: { id in
                // Crashlytics clears with `""`; Analytics clears with `nil`.
                Crashlytics.crashlytics().setUserID(id ?? "")
                Analytics.setUserID(id)
            },
            setUserProperty: { value, name in
                // Firebase accepts `nil` to clear the property.
                Analytics.setUserProperty(value, forName: name)
            },
            setAnalyticsCollectionEnabled: { enabled in
                Analytics.setAnalyticsCollectionEnabled(enabled)
            },
            log: { message in
                Crashlytics.crashlytics().log(message)
            },
            recordError: { error, userInfo in
                if let userInfo {
                    var dict: [String: Any] = [:]
                    for (k, v) in userInfo { dict[k] = v.anyValue }
                    Crashlytics.crashlytics().record(error: error, userInfo: dict)
                } else {
                    Crashlytics.crashlytics().record(error: error, userInfo: nil)
                }
            }
        )
    }
}
