import Foundation
@testable import Tosoka

final class LinuxJSONCoder: JSONCoding {
    func makeData(with json: [String: Any]) -> Data? {
        return (try? Jay().dataFromJson(anyDictionary: json)).map { Data(bytes: $0) }
    }
    
    func makeJSON(with data: Data) -> [String: Any]? {
        return (try? Jay().anyJsonFromData([UInt8](data))) as? [String: Any]
    }
}

