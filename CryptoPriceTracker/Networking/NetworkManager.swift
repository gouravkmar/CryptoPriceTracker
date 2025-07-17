//
//  NetworkManager.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 17/07/25.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init(){}
    enum RequestType: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    struct NetworkRequest {
        var host : String // without the https 
        var path : String
        var acceptEncoding : String?
        var requestType : RequestType
        var params : [String:String]
        var contentType : String?
        var authorisation : String?
        var customHeaders : [String: String]?
        var body : Data?
        var timoutInterval : Int
        
        var requestHeaders: [String: String] { // this returns a full dict of request params from the struct, some keys i have written in struct so that we have to make the dict when we have to pass some custom params, otherwise a simple struct can handle all requests
                var headers: [String: String] = [:]
                
                if let contentType = contentType {
                    headers["Content-Type"] = contentType
                }
                
                if let acceptEncoding = acceptEncoding {
                    headers["Accept-Encoding"] = acceptEncoding
                }
                
                if let authorisation = authorisation {
                    headers["Authorization"] = authorisation
                }

                if let custom = customHeaders {
                    for (key, value) in custom {
                        headers[key] = value
                    }
                }
                return headers
            }
    }
    enum NetworkError : Error {
        case faultyURL
        case faultyBody
        case badResponse(code : Int)
    }
    
    private func createRequest(networkRequest : NetworkRequest) throws -> URLRequest {
        
        var components = URLComponents()
        components.scheme = "https" // considering using https method for now only
        components.host = networkRequest.host
        components.path = networkRequest.path //accepting in a path form only eg: /coin/v3/bitcoin
        components.queryItems = networkRequest.params.map{ URLQueryItem(name: $0.key, value: $0.value)}
        
        guard let url = components.url else { throw NetworkError.faultyURL}
        
        var request = URLRequest(url: url, timeoutInterval: TimeInterval(networkRequest.timoutInterval))
        
        request.httpMethod = networkRequest.requestType.rawValue
        if [.post, .put, .delete].contains(networkRequest.requestType),
           let body = networkRequest.body {
            request.httpBody = body
        }
        networkRequest.requestHeaders.forEach{
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return request
    
    }
    
    
    func makeAPIRequest(networkRequest : NetworkRequest) async throws -> (Data,URLResponse){
        
        let dataRequest = try createRequest(networkRequest: networkRequest)
        let session = URLSession.shared
        let (data,response) = try await session.data(for: dataRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse(code: 0) // need to establish code for this
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse(code: httpResponse.statusCode)
        }
        
        return (data,response)
    }
    
}
