import Foundation

protocol IConfigurationParser {
    func parse(data: Data) throws -> [String]
}

enum ConfigurationParserError: Error {
    case wrongJson(String)
}

class ConfigurationParser: IConfigurationParser {
    func parse(data: Data) throws -> [String] {
        
        guard let root = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
              let results = root["results"] as? [String: String] else {
                  throw ConfigurationParserError.wrongJson("Wrong Json Format")
        }
        
        var urls: [String] = []
        if let src = results["src"] {
            urls.append(src)
        }
        if let single = results["single"] {
            urls.append(single)
        }
        if let split_v = results["split_v"] {
            urls.append(split_v)
        }
        if let split_h = results["split_h"] {
            urls.append(split_h)
        }
        
        return urls
    }
}
