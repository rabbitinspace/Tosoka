import Foundation

public protocol JSONCoding {
    func makeData(with json: [String: Any]) -> Data?
    func makeJSON(with data: Data) -> [String: Any]?
}
