import Foundation

protocol IUrlProvider {
    func obtainUrls(completion: @escaping ([String]?, Error?)->Void)
}

enum UrlProviderError: Error {
    case obtainDataError(String)
}

class UrlProvider: NSObject, IUrlProvider, URLSessionDelegate {
    func obtainUrls(completion: @escaping ([String]?, Error?) -> Void) {
        
        guard let configUrl = URL(string: "https://89.208.230.60/test/item") else {
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        let request = URLRequest(url: configUrl)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                completion(nil, UrlProviderError.obtainDataError("Obtain data error"))
                return
            }
            
            do {
                let parser = ConfigurationParser()
                let urls = try parser.parse(data: data)
                completion(urls, nil)
            }
            catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
