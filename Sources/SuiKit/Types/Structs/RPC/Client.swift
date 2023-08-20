//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/10/23.
//

import Foundation
import SwiftyJSON
import AnyCodable

public typealias HttpHeaders = [String: String]
public typealias RequestParamsLike = [AnyCodable]

public struct RpcParameters: Codable, RPCErrorRequest {
    public var method: String
    public var args: [AnyCodable]
}

public struct ValidResponse: Codable {
    public var jsonrpc: String = "2.0"
    public let id: String
    public let result: JSON
}

public struct ErrorResponse: Codable, Error {
    public var jsonrpc: String = "2.0"
    public let id: String
    public let error: ErrorObject
}

public struct ErrorObject: Codable {
    public let code: AnyCodable
    public let message: String
    public let data: AnyCodable?
}

public struct JsonRpcClient {
    public static let PACKAGE_VERSION = "0.33.0"
    public static let TARGETED_RPC_VERSION = "1.1.0"

    private let url: URL
    private let httpHeaders: HttpHeaders
    private let session: URLSession

    public init(url: URL, httpHeaders: HttpHeaders? = nil) {
        self.url = url
        self.httpHeaders = [
            "Content-Type": "application/json",
            "Client-Sdk-Type": "swift",
            "Client-Sdk-Version": Self.PACKAGE_VERSION,
            "Client-Target-Api-Version": Self.TARGETED_RPC_VERSION
        ].merging(httpHeaders ?? [:]) { (_, new) in new }

        self.session = URLSession(configuration: .default)
    }

    public static func processSuiJsonRpc(_ url: URL, _ request: SuiRequest) async throws -> SuiResponse {
        let data = try await Self.sendSuiJsonRpc(url, request)

        do {
            return try JSONDecoder().decode(SuiResponse.self, from: data)
        } catch {
            let error = try JSONDecoder().decode(SuiClientError.self, from: data)
            throw error
        }
    }

    public static func sendSuiJsonRpc(_ url: URL, _ request: SuiRequest) async throws -> Data {
        var requestUrl = URLRequest(url: url)
        requestUrl.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        requestUrl.httpMethod = "POST"

        do {
            let requestData = try JSONEncoder().encode(request)
            requestUrl.httpBody = requestData
        } catch {
            throw SuiError.encodingError
        }

        return try await withCheckedThrowingContinuation { (con: CheckedContinuation<Data, Error>) in
            let task = URLSession.shared.dataTask(with: requestUrl) { data, _, error in
                if let error = error {
                    con.resume(throwing: error)
                } else if let data = data {
                    con.resume(returning: data)
                } else {
                    con.resume(returning: Data())
                }
            }

            task.resume()
        }
    }

    public func call(request: Data?) async throws -> String {
        var urlRequest = URLRequest(url: self.url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request
        urlRequest.allHTTPHeaderFields = self.httpHeaders

        let (data, response) = try await self.session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown Error"])
        }

        if httpResponse.statusCode == 200 {
            guard let result = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response data"])
            }
            return result
        } else {
            let isHtml = httpResponse.allHeaderFields["Content-Type"] as? String == "text/html"
            let errorMessage = "\(httpResponse.statusCode) \(httpResponse.description)\(isHtml ? "" : ": \(String(describing: data))")"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }

    public func request<T: Decodable>(withType type: T.Type, method: String, args: RequestParamsLike) async throws -> JSON {
        let req = RpcParameters(method: method, args: args)
        let requestData = try JSONEncoder().encode(req)
        let responseString = try await call(request: requestData)

        guard let responseData = responseString.data(using: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode response string"])
        }

        do {
            let response = try JSONDecoder().decode(ValidResponse.self, from: responseData)
            return response.result
        } catch {
            do {
                let response = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                throw response
            } catch {
                throw RPCError(options: (req: RpcParameters(method: method, args: args), code: nil, data: responseData, cause: nil))
            }
        }
    }
}
