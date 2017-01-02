import Foundation

public protocol JSONEncoder {
    func makeData(with json: [String: Any]) -> Data?
}
