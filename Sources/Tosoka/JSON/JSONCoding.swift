import Foundation

/// A generic JSON encoder/decoder
public protocol JSONCoding {
    
    /// Serializes `json` dictionaty to `Data`
    ///
    /// - Parameter json: json object as dictionary
    /// - Returns: serialized `json` object or `nil` on error
    func makeData(with json: [String: Any]) -> Data?
    
    /// Deserializes `data` to json dictionary
    ///
    /// - Parameter data: bytes to be deserialized
    /// - Returns: deserialized `data` or `nil` on error
    func makeJSON(with data: Data) -> [String: Any]?
}
