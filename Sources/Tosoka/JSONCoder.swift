import Foundation


public struct JSONCoder: JSONEncoder, JSONDecoder {
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

