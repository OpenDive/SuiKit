//
//  JsonRpcClient.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftyJSON
@preconcurrency import AnyCodable

public struct JsonRpcClient {
    /// Represents the package version.
    public static let PACKAGE_VERSION = "0.33.0"

    /// Represents the targeted RPC version.
    public static let TARGETED_RPC_VERSION = "1.1.0"

    /// Shared URLSession with optimized configuration
    private static let sharedSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil  // Disable caching for RPC calls
        config.httpMaximumConnectionsPerHost = 10
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [
            "User-Agent": "SuiKit/\(PACKAGE_VERSION)",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        return URLSession(configuration: config)
    }()

    private let url: URL
    private let httpHeaders: HttpHeaders
    private let session: URLSession

    /// Initializes a new `JsonRpcClient` with the given URL and optionally custom HTTP headers.
    /// - Parameters:
    ///   - url: The URL of the JSON-RPC server.
    ///   - httpHeaders: Optional custom HTTP headers.
    ///   - session: Optional custom URLSession (uses optimized shared session by default).
    public init(url: URL, httpHeaders: HttpHeaders? = nil, session: URLSession? = nil) {
        self.url = url
        self.httpHeaders = [
            "Content-Type": "application/json",
            "Client-Sdk-Type": "swift",
            "Client-Sdk-Version": Self.PACKAGE_VERSION,
            "Client-Target-Api-Version": Self.TARGETED_RPC_VERSION
        ].merging(httpHeaders ?? [:]) { (_, new) in new }

        self.session = session ?? Self.sharedSession
    }

    /// Process a JSON-RPC request and returns a `SuiResponse`.
    /// - Parameters:
    ///   - url: The URL of the JSON-RPC server.
    ///   - request: The `SuiRequest` to be sent.
    /// - Returns: A `SuiResponse` object.
    /// - Throws: Decoding errors if the response cannot be decoded.
    public static func processSuiJsonRpc(_ url: URL, _ request: SuiRequest) async throws -> SuiResponse {
        let data = try await Self.sendSuiJsonRpc(url, request)

        do {
            return try JSONDecoder().decode(SuiResponse.self, from: data)
        } catch {
            let error = try JSONDecoder().decode(SuiClientError.self, from: data)
            throw error
        }
    }

    /// Sends a JSON-RPC request and returns the received data.
    /// - Parameters:
    ///   - url: The URL of the JSON-RPC server.
    ///   - request: The `SuiRequest` to be sent.
    /// - Returns: The received `Data`.
    /// - Throws: Encoding errors if the request cannot be encoded.
    public static func sendSuiJsonRpc(_ url: URL, _ request: SuiRequest) async throws -> Data {
        var requestUrl = URLRequest(url: url)
        requestUrl.allHTTPHeaderFields = ["Content-Type": "application/json"]
        requestUrl.httpMethod = "POST"

        do {
            let requestData = try JSONEncoder().encode(request)
            requestUrl.httpBody = requestData
            let (data, _) = try await URLSession.shared.data(for: requestUrl)
            return data
        } catch {
            throw SuiError.customError(message: "Encoding error")
        }
    }

    /// Performs a call to the JSON-RPC server with the given request data.
    /// - Parameter request: The request data to be sent.
    /// - Returns: A string containing the server response.
    /// - Throws: Various errors related to the HTTP response and decoding failures.
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

    /// Performs a JSON-RPC request and decodes the response.
    /// - Parameters:
    ///   - type: The type of the expected response.
    ///   - method: The JSON-RPC method to be called.
    ///   - args: The parameters for the JSON-RPC method.
    /// - Returns: A `JSON` object containing the result of the call.
    /// - Throws: Various errors related to encoding, decoding, and invalid responses.
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
