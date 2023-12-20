//
//  File.swift
//  
//
//  Created by Marcus Arnett on 12/19/23.
//

import Foundation
import Apollo
import ApolloAPI

public struct GraphQLHelper {
    public static func executeQuery<T: GraphQLQuery>(client: ApolloClient, query: T) async throws -> GraphQLResult<T.Data> {
        return try await withCheckedThrowingContinuation { (con: CheckedContinuation<GraphQLResult<T.Data>, Error>) in
            let _ = client.fetch(query: query) { result in
                switch result {
                case .success(let graphQLresult):
                    con.resume(returning: graphQLresult)
                case .failure(let err):
                    con.resume(throwing: err)
                }
            }
        }
    }
}
