import Foundation

struct BridgePayload: Codable {
    let kind: String
    let timestamp: Date
    let body: [String: String]

    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return (try? encoder.encode(self)) ?? Data()
    }
}
