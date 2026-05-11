import Testing

@testable import neomouse

@Test("sendNotification runs without crashing") func testSendNotification() {
    sendNotification()
}
