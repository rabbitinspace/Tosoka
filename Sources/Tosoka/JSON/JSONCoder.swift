import Foundation

/// Generic json encoder/decoder
///
/// - Note: JSONSerialization.jsonObject(with:options:) is still unimplemented in swift 3.0,
/// but it is in swift 3.1
/// - Todo: Replace with JSONSerialization in swift 3.1
public struct JSONCoder: JSONCoding {
    public func makeData(with json: [String : Any]) -> Data? {
        #if os(macOS)
            return try? JSONSerialization.data(withJSONObject: json, options: [])
        #else
            return nil
        #endif
    }
    
    public func makeJSON(with data: Data) -> [String : Any]? {
        #if os(macOS)
            return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
        #else
            return nil
        #endif
    }
}

