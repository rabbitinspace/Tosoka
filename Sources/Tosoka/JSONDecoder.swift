import Foundation

public protocol JSONDecoder {
    func makeJSON(with data: Data) -> [String: Any]?
}
