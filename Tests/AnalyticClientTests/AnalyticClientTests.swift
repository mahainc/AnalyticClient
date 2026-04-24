import Foundation
import Testing
@testable import AnalyticClient

@Suite("AnalyticClient mocks + AnalyticClient.Param")
struct AnalyticClientTests {

    @Test("AnalyticClient.Param literal conversions")
    func analyticParamLiterals() {
        let s: AnalyticClient.Param = "hello"
        let i: AnalyticClient.Param = 42
        let d: AnalyticClient.Param = 3.14
        let b: AnalyticClient.Param = true

        #expect(s == .string("hello"))
        #expect(i == .int(42))
        #expect(d == .double(3.14))
        #expect(b == .bool(true))
    }

    @Test("AnalyticClient.Param stringValue is lossless")
    func analyticParamStringValue() {
        #expect(AnalyticClient.Param.string("hi").stringValue == "hi")
        #expect(AnalyticClient.Param.int(42).stringValue == "42")
        #expect(AnalyticClient.Param.double(3.14).stringValue == "3.14")
        #expect(AnalyticClient.Param.bool(true).stringValue == "true")
    }

    @Test("noop mock can be called without crashing")
    func noopMock() async {
        let client = AnalyticClient.noop
        await client.trackScreen("Home", [:])
        await client.trackEvent("tap_button", ["id": "start"])
        await client.setUserID("u-123")
        await client.log("diagnostic")
        struct E: Error, Sendable {}
        await client.recordError(E(), ["key": "value", "count": 7])
    }

    @Test("custom client captures typed params")
    func customClientTypedParams() async {
        actor Spy {
            var events: [(String, AnalyticClient.Params)] = []
            func record(event: String, params: AnalyticClient.Params) { events.append((event, params)) }
        }
        let spy = Spy()
        let client = AnalyticClient(
            trackScreen: { _, _ in },
            trackEvent:  { name, params in await spy.record(event: name, params: params) },
            setUserID:   { _ in },
            log:         { _ in },
            recordError: { _, _ in }
        )

        await client.trackEvent("purchase", [
            "product_id": "pro.yearly",
            "price": 29.99,
            "count": 1,
            "gifted": false,
        ])
        let events = await spy.events
        #expect(events.count == 1)
        #expect(events[0].0 == "purchase")
        #expect(events[0].1["price"] == .double(29.99))
        #expect(events[0].1["count"] == .int(1))
        #expect(events[0].1["gifted"] == .bool(false))
    }
}
