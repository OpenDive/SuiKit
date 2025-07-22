//
//  GraphQLSuiProvider.swift
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
import Blake2
import Apollo
import ApolloAPI
import BigInt

public struct GraphQLSuiProvider {
    private var apollo: ApolloClient

    public init(connection: any ConnectionProtocol) {
        self.apollo = ApolloClient(url: URL(string: connection.graphql!)!)
    }

    // TODO: Implement function when write becomes available
    /// Runs the transaction in dev-inspect mode. Which allows for nearly any transaction (or Move call) with any arguments. Detailed results are provided, including both the transaction effects and any return values.
    /// - Parameters:
    ///   - transactionBlock: BCS encoded TransactionKind(as opposed to TransactionData, which include gasBudget and gasPrice).
    ///   - sender: The account that sends the transaction.
    ///   - gasPrice: Gas is not charged, but gas usage is still calculated. Default to use reference gas price.
    ///   - epoch: The epoch to perform the call. Will be set from the system state object if not provided.
    /// - Returns: The results of the inspection, encapsulated in a `DevInspectResults` object, if successful.
    /// - Throws: Throws an error if inspection fails, or if any error occurs during the process.
    public func devInspectTransactionBlock(
        transactionBlock: inout TransactionBlock,
        sender: Account,
        gasPrice: Int? = nil,
        epoch: String? = nil
    ) async throws -> DevInspectResults? {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Return transaction execution effects including the gas cost summary, while the effects are not committed to the chain.
    /// - Parameter transactionBlock: The bytes representing the transaction block to be dry run.
    /// - Returns: A `SuiTransactionBlockResponse` representing the outcome of the dry run.
    /// - Throws: Throws an error if the dry run fails or if any error occurs during the process.
    public func dryRunTransactionBlock(
        transactionBlock: [UInt8]
    ) async throws -> SuiTransactionBlockResponse {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Function to sign and execute a transaction block, making the transactions within
    /// the block occur on the blockchain.
    /// - Parameters:
    ///   - transactionBlock: The transaction block to be signed and executed.
    ///   - signer: The account that signs the transaction block.
    ///   - options: Additional options for the response of the executed transaction block.
    ///   - requestType: The type of the Sui request being made.
    /// - Returns: A `SuiTransactionBlockResponse` representing the outcome of the executed transaction block.
    /// - Throws: Throws an error if signing or executing the transaction block fails, or if any error occurs during the process.
    public func signAndExecuteTransactionBlock(
        transactionBlock: inout TransactionBlock,
        signer: Account,
        options: SuiTransactionBlockResponseOptions? = nil,
        requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Execute the transaction and wait for results if desired. Request types: 1. WaitForEffectsCert: waits for TransactionEffectsCert and then return to client.
    ///
    /// This mode is a proxy for transaction finality. 2. WaitForLocalExecution: waits for TransactionEffectsCert and make sure the node executed the transaction
    /// locally before returning the client. The local execution makes sure this node is aware of this transaction when client fires subsequent queries.
    /// However if the node fails to execute the transaction locally in a timely manner, a bool type in the response is set to false to indicated the case.
    /// request_type is default to be `WaitForEffectsCert` unless options.show_events or options.show_effects is true.
    /// - Parameters:
    ///   - transactionBlock: BCS serialized transaction data bytes without its type tag, as base-64 encoded string.
    ///   - signature: A list of signatures (`flag || signature || pubkey` bytes, as base-64 encoded string). Signature is committed to the intent message of the transaction data, as base-64 encoded string.
    ///   - options: options for specifying the content to be returned
    ///   - requestType: The request type, derived from `SuiTransactionBlockResponseOptions` if None
    /// - Returns: A `SuiTransactionBlockResponse` representing the outcome of the executed transaction block.
    /// - Throws: Throws an error if executing the transaction block fails or if any error occurs during the process.
    public func executeTransactionBlock(
        transactionBlock: String,
        signature: String,
        options: SuiTransactionBlockResponseOptions? = nil,
        requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Execute the transaction and wait for results if desired. Request types: 1. WaitForEffectsCert: waits for TransactionEffectsCert and then return to client.
    ///
    /// This mode is a proxy for transaction finality. 2. WaitForLocalExecution: waits for TransactionEffectsCert and make sure the node executed the transaction
    /// locally before returning the client. The local execution makes sure this node is aware of this transaction when client fires subsequent queries.
    /// However if the node fails to execute the transaction locally in a timely manner, a bool type in the response is set to false to indicated the case.
    /// request_type is default to be `WaitForEffectsCert` unless options.show_events or options.show_effects is true.
    /// - Parameters:
    ///   - transactionBlock: BCS serialized transaction data bytes without its type tag, as base-64 encoded string.
    ///   - signature: A list of signatures (`flag || signature || pubkey` bytes, as base-64 encoded string). Signature is committed to the intent message of the transaction data, as base-64 encoded string.
    ///   - options: options for specifying the content to be returned
    ///   - requestType: The request type, derived from `SuiTransactionBlockResponseOptions` if None
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiTransactionBlockResponse` containing the results of the executed transaction block.
    public func executeTransactionBlock(
        transactionBlock: [UInt8],
        signature: String,
        options: SuiTransactionBlockResponseOptions? = nil,
        requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
        throw SuiError.notImplemented
    }

    /// Return the first four bytes of the chain's genesis checkpoint digest.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `String` representing the chain identifier.
    public func getChainIdentifier() async throws -> String {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetChainIdentifierQuery()
        )
        return result.data!.chainIdentifier
    }

    /// Return a checkpoint.
    /// - Parameter digest: Checkpoint digest
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `Checkpoint` object representing the retrieved checkpoint.
    public func getCheckpoint(digest: String) async throws -> Checkpoint {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetCheckpointQuery(
                id: .init(
                    CheckpointId(digest: digest)
                )
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return Checkpoint(graphql: data)
    }

    /// Return a checkpoint.
    /// - Parameter id: Checkpoint sequence number
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `Checkpoint` object representing the retrieved checkpoint.
    public func getCheckpoint(sequenceNumber: Int) async throws -> Checkpoint {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetCheckpointQuery(
                id: .init(
                    CheckpointId(sequenceNumber: sequenceNumber)
                )
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return Checkpoint(graphql: data)
    }

    /// Return paginated list of checkpoints.
    /// - Parameters:
    ///   - cursor: An optional paging cursor. If provided, the query will start from the next item after the specified cursor. Default to start from the first item if not specified.
    ///   - limit: Maximum item returned per page, default to [QUERY_MAX_RESULT_LIMIT_CHECKPOINTS] if not specified.
    ///   - order: A `SortOrder` enum value indicating the order of the results, defaulting to descending, defaults to ascending order, oldest record first.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `CheckpointPage` object containing a list of retrieved checkpoints and pagination information.
    public func getCheckpoints(
        cursor: String? = nil,
        limit: Int? = nil,
        order: SortOrder = .descending
    ) async throws -> CheckpointPage {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: order == .descending ?
                GetCheckpointsQuery(
                    first: .none,
                    before: (cursor != nil ? .init(stringLiteral: cursor!) : .none),
                    last: (limit != nil ? .init(integerLiteral: limit!) : .none),
                    after: .none
                ) :
                GetCheckpointsQuery(
                    first: (limit != nil ? .init(integerLiteral: limit!) : .none),
                    before: .none,
                    last: .none,
                    after: (cursor != nil ? .init(stringLiteral: cursor!) : .none)
                )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return CheckpointPage(
            data: data.checkpoints.nodes.map { Checkpoint(graphql: $0) },
            pageInfo: PageInfo(graphql: data.checkpoints.pageInfo)
        )
    }

    // TODO: Implement endpoint function
    /// Return transaction events.
    /// - Parameter transactionDigest: The digest of the transaction for which to retrieve events.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `PaginatedSuiMoveEvent` object containing a list of retrieved events and pagination information.
    public func getEvents(
        transactionDigest: String
    ) async throws -> PaginatedSuiMoveEvent {
        throw SuiError.notImplemented
    }

    /// Return the sequence number of the latest checkpoint that has been executed.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `String` representing the latest checkpoint sequence number.
    public func getLatestCheckpointSequenceNumber() async throws -> String {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetLatestCheckpointSequenceNumberQuery()
        )
        return "\(result.data!.checkpoint!.sequenceNumber)"
    }

    // TODO: Implement function when write becomes available
    /// Retrieves the loaded child objects associated with a given digest from the Sui blockchain.
    /// - Parameter digest: The digest string of the parent object.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `TransactionEffectsModifiedAtVersions` representing the loaded child objects.
    public func getLoadedChildObjects(
        digest: String
    ) async throws -> [TransactionEffectsModifiedAtVersions] {
        throw SuiError.notImplemented
    }

    /// Return the argument types of a Move function, based on normalized Type.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module and function.
    ///   - module: The string identifier of the module containing the function.
    ///   - function: The string identifier of the function whose argument types are to be retrieved.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `SuiMoveFunctionArgType` representing the argument types of the specified Move function.
    public func getMoveFunctionArgTypes(
        package: String,
        module: String,
        function: String
    ) async throws -> [SuiMoveFunctionArgType] {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetMoveFunctionArgTypesQuery(packageId: package, module: module, function: function)
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return data.object!.asMovePackage!.module!.function!.parameters!.map {
            SuiMoveFunctionArgType(graphql: $0)
        }
    }

    /// Return a structured representation of Move function.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module and function.
    ///   - moduleName: The string identifier of the module containing the function.
    ///   - functionName: The string identifier of the function to be normalized.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedFunction` object representing the normalized representation of the specified Move function, or `nil` if not found.
    public func getNormalizedMoveFunction(
        package: String,
        moduleName: String,
        functionName: String
    ) async throws -> SuiMoveNormalizedFunction? {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetNormalizedMoveFunctionQuery(
                packageId: package,
                module: moduleName,
                function: functionName
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return SuiMoveNormalizedFunction(graphql: data)
    }

    /// Return a structured representation of Move module.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module.
    ///   - module: The string identifier of the module to be normalized.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedModule` object representing the normalized representation of the specified Move module, or `nil` if not found.
    public func getNormalizedMoveModule(
        package: String,
        module: String
    ) async throws -> SuiMoveNormalizedModule? {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetNormalizedMoveModuleQuery(
                packageId: package,
                module: module
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return SuiMoveNormalizedModule(graphql: data.object!.asMovePackage!.module!, package: package)
    }

    /// Return structured representations of all modules in the given package.
    /// - Parameter package: The string identifier of the package containing the modules.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedModules` object representing the normalized representation of the specified Move modules.
    public func getNormalizedMoveModulesByPackage(
        package: String, cursor: String? = nil
    ) async throws -> SuiMoveNormalizedModules {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetNormalizedMoveModulesByPackageQuery(
                packageId: package,
                cursor: cursor == nil ?
                    GraphQLNullable<String>.init(nilLiteral: ()) :
                    GraphQLNullable<String>.init(stringLiteral: cursor!)
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return data.object!.asMovePackage!.modules?.nodes.reduce(into: [String: SuiMoveNormalizedModule]()) {
            $0[$1.name] = SuiMoveNormalizedModule(graphql: $1, package: package)
        } ?? [:]
    }

    /// Return a structured representation of Move struct.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module and struct.
    ///   - module: The string identifier of the module containing the struct.
    ///   - structure: The string identifier of the struct to be normalized.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedStruct` object representing the normalized representation of the specified Move struct, or `nil` if not found.
    public func getNormalizedMoveStruct(
        package: String,
        module: String,
        structure: String
    ) async throws -> SuiMoveNormalizedStruct? {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetNormalizedMoveStructQuery(
                packageId: package,
                module: module,
                struct: structure
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return SuiMoveNormalizedStruct(structure: data.object!.asMovePackage!.module!.struct!)
    }

    /// Return the object information for a specified object.
    /// - Parameters:
    ///   - objectId: The string identifier of the object to be retrieved.
    ///   - options: The optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if the address is invalid or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiObjectResponse` object representing the retrieved Sui object, or `nil` if not found.
    public func getObject(
        objectId: String,
        options: SuiObjectDataOptions? = nil
    ) async throws -> SuiObjectResponse? {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetObjectQuery(
                id: objectId,
                showBcs: options?.showBcs ?? false,
                showOwner: options?.showOwner ?? false,
                showPreviousTransaction: options?.showPreviousTransaction ?? false,
                showContent: options?.showContent ?? false,
                showType: options?.showType ?? false,
                showStorageRebate: options?.showStorageRebate ?? false
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return SuiObjectResponse(error: nil, data: SuiObjectData(graphql: data.object!))
    }

    /// Return the protocol config table for the given version number. If the version number is not specified, If none is specified, the node uses the version of the latest epoch it has processed.
    /// - Parameter version: An optional protocol version specifier. If omitted, the latest protocol config table for the node will be returned.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `ProtocolConfig` object representing the protocol configuration.
    public func getProtocolConfig(
        version: String? = nil
    ) async throws -> ProtocolConfig {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetProtocolConfigQuery(
                protocolVersion: version != nil ? .init(stringLiteral: version!) : .none
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return ProtocolConfig(graphql: data.protocolConfig)
    }

    /// Return the total number of transaction blocks known to the server.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `UInt64` representing the total number of transaction blocks.
    public func getTotalTransactionBlocks() async throws -> BigInt {
        let result = try await GraphQLClient.fetchQuery(client: self.apollo, query: GetTotalTransactionBlocksQuery())
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return BigInt(stringLiteral: data.checkpoint!.networkTotalTransactions!)
    }

    // TODO: Implement function when write becomes available
    /// Return the transaction response object.
    /// - Parameters:
    ///   - digest: A `String` representing the digest of the queried transaction.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if the digest is invalid or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiTransactionBlockResponse` object representing the retrieved transaction block.
    public func getTransactionBlock(
        digest: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> SuiTransactionBlockResponse {
        throw SuiError.notImplemented
    }

    /// Return the object data for a list of objects.
    /// - Parameters:
    ///   - ids: An array of `objectId` representing the ids of the objects to be retrieved.
    ///   - options: An optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if any address is invalid or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `SuiObjectResponse` representing the retrieved Sui objects.
    public func getMultiObjects(
        ids: [ObjectId],
        options: SuiObjectDataOptions? = nil
    ) async throws -> [SuiObjectResponse] {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: MultiGetObjectsQuery(
                ids: ids,
                limit: .init(integerLiteral: ids.count),
                cursor: .none,
                showBcs: options?.showBcs ?? false,
                showContent: options?.showContent ?? false,
                showDisplay: options?.showDisplay ?? false,
                showType: options?.showType ?? false,
                showOwner: options?.showOwner ?? false,
                showPreviousTransaction: options?.showPreviousTransaction ?? false,
                showStorageRebate: options?.showStorageRebate ?? false
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return data.objects.nodes.map { object in
            SuiObjectResponse(error: nil, data: SuiObjectData(
                graphql: object,
                showBcs: options?.showBcs ?? false
            ))
        }
    }

    // TODO: Implement function when write becomes available
    /// Returns an ordered list of transaction responses The method will throw an error if the input contains any duplicate or the input size exceeds `QUERY_MAX_RESULT_LIMIT`.
    /// - Parameters:
    ///   - digests: An array of `String` representing the digests of the transaction blocks to be retrieved.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if any digest is invalid, if there are duplicate digests, or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `SuiTransactionBlockResponse` representing the retrieved transaction blocks.
    public func multiGetTransactionBlocks(
        digests: [String],
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> [SuiTransactionBlockResponse] {
        throw SuiError.notImplemented
    }

    /// Return the object information for a specified version.
    ///
    /// There is no software-level guarantee/SLA that objects with past versions can be retrieved by this API, even if the object and version exists/existed. The result may vary across nodes depending on their pruning policies.
    /// - Parameters:
    ///   - id: A `String` representing the id of the object to be retrieved.
    ///   - version: An `Int` representing the version of the object to be retrieved.
    ///   - options: An optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An `ObjectRead` object representing the retrieved past object, or `nil` if not found.
    public func tryGetPastObject(
        id: String,
        version: Int,
        options: SuiObjectDataOptions? = nil
    ) async throws -> ObjectRead? {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: TryGetPastObjectQuery(
                id: id,
                version: .init(stringLiteral: "\(version)"),
                showBcs: options?.showBcs ?? false,
                showOwner: options?.showOwner ?? false,
                showPreviousTransaction: options?.showPreviousTransaction ?? false,
                showContent: options?.showContent ?? false,
                showType: options?.showType ?? false,
                showStorageRebate: options?.showStorageRebate ?? false
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        // TODO: Implement proper error handling.
        return .versionFound(SuiObjectData(graphql: data.object!, showBcs: options?.showBcs ?? false))
    }

    // TODO: Implement function when write becomes available
    /// Return the object information for a specified version.
    ///
    /// There is no software-level guarantee/SLA that objects with past versions can be retrieved by this API, even if the object and version exists/existed. The result may vary across nodes depending on their pruning policies.
    /// - Parameters:
    ///   - objects: An array of `GetPastObjectRequest` representing the requests for the objects to be retrieved.
    ///   - options: An optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `ObjectRead` representing the retrieved past objects.
    public func tryMultiGetPastObjects(
        objects: [GetPastObjectRequest],
        options: SuiObjectDataOptions? = nil
    ) async throws -> [ObjectRead] {
        throw SuiError.notImplemented
    }

    /// Return the total coin balance for all coin type, owned by the address owner.
    /// - Parameter account: The account whose balances are to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: An array of `CoinBalance` representing the balances of different coins in the account.
    public func getAllBalances(
        account: Account
    ) async throws -> [CoinBalance] {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetAllBalancesQuery(
                owner: try account.address(),
                limit: .none,
                cursor: .none
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return try data.address!.balances.nodes.map { try CoinBalance(graphql: $0) }
    }

    /// Return all Coin objects owned by an address.
    /// - Parameters:
    ///   - account: Any object conforming to `PublicKeyProtocol` whose associated coins are to be retrieved.
    ///   - cursor: Optional. A cursor for pagination.
    ///   - limit: Optional. A limit on the number of coins to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: A `PaginatedCoins` object containing the retrieved coins and pagination information.
    public func getAllCoins(
        account: any PublicKeyProtocol,
        cursor: String? = nil,
        limit: UInt? = nil
    ) async throws -> PaginatedCoins {
        return try await self.getCoins(
            account: try account.toSuiAddress(),
            cursor: cursor,
            limit: limit
        )
    }

    /// Return the total coin balance for one coin type, owned by the address owner.
    /// - Parameters:
    ///   - account: Any object conforming to `PublicKeyProtocol` whose balance is to be retrieved.
    ///   - coinType: Optional. The type of the coin whose balance is to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: A `CoinBalance` object representing the balance of the specified coin in the account.
    public func getBalance(
        account: any PublicKeyProtocol,
        coinType: String? = nil
    ) async throws -> CoinBalance {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetBalanceQuery(
                owner: try account.toSuiAddress(),
                type: coinType != nil ? .init(stringLiteral: coinType!) : .none
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return try CoinBalance(graphql: data.address!.balance!)
    }

    /// Return metadata (e.g., symbol, decimals) for a coin.
    /// - Parameter coinType: type name for the coin (e.g., 0x168da5bf1f48dafc111b0a488fa454aca95e0b5e::usdc::USDC)
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response, or if the coinType is invalid.
    /// - Returns: A `SuiCoinMetadata` object representing the metadata of the specified coin.
    public func getCoinMetadata(
        coinType: String
    ) async throws -> SuiCoinMetadata {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetCoinMetadataQuery(coinType: coinType)
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return SuiCoinMetadata(graphql: data.coinMetadata!)
    }

    /// Return all Coin<`coin_type`> objects owned by an address.
    /// - Parameters:
    ///   - account: The account whose coins are to be retrieved.
    ///   - coinType: Optional type name for the coin (e.g., 0x168da5bf1f48dafc111b0a488fa454aca95e0b5e::usdc::USDC), default to 0x2::sui::SUI if not specified.
    ///   - cursor: Optional. A cursor for pagination.
    ///   - limit: Optional. A limit on the number of coins to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: A `PaginatedCoins` object containing the retrieved coins and pagination information.
    public func getCoins(
        account: String,
        coinType: String? = nil,
        cursor: String? = nil,
        limit: UInt? = nil
    ) async throws -> PaginatedCoins {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetCoinsQuery(
                owner: account,
                first: limit != nil ? .init(integerLiteral: Int(limit!)) : .null,
                cursor: cursor != nil ? .init(stringLiteral: cursor!) : .null,
                type: coinType != nil ? .init(stringLiteral: coinType!) : .null
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return PaginatedCoins(
            data: try data.address!.coins.nodes.map { try CoinStruct(graphql: $0) },
            pageInfo: PageInfo(graphql: data.address!.coins.pageInfo)
        )
    }

    // TODO: Implement function when write becomes available
    /// Return the committee information for the asked `epoch`.
    /// - Parameter epoch: he epoch of interest. If None, default to the latest epoch.
    /// - Returns: A `CommitteeInfo` object containing the information of the committee for the specified epoch.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getCommitteeInfo(
        epoch: String
    ) async throws -> CommitteeInfo {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Return the dynamic field object information for a specified object.
    /// - Parameters:
    ///   - parentId: The ID of the queried parent object.
    ///   - name: The Name of the dynamic field.
    /// - Returns: An optional `SuiObjectResponse` containing the information of the dynamic field object, `nil` if not found.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getDynamicFieldObject(
        parentId: String,
        name: String
    ) async throws -> SuiObjectResponse? {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Return the dynamic field object information for a specified object.
    /// - Parameters:
    ///   - parentId: The ID of the queried parent object.
    ///   - name: The Name of the dynamic field.
    /// - Returns: An optional `SuiObjectResponse` containing the information of the dynamic field object, `nil` if not found.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getDynamicFieldObject(
        parentId: String,
        name: DynamicFieldName
    ) async throws -> SuiObjectResponse? {
        throw SuiError.notImplemented
    }

    /// Return the list of dynamic field objects owned by an object.
    /// - Parameters:
    ///   - parentId: The ID of the parent object.
    ///   - filter: An optional filter to apply to the dynamic fields.
    ///   - options: An optional set of options to apply to the dynamic fields.
    ///   - limit: Maximum item returned per page, default to [QUERY_MAX_RESULT_LIMIT] if not specified.
    ///   - cursor: An optional paging cursor. If provided, the query will start from the next item after the specified cursor. Default to start from the first item if not specified.
    /// - Returns: A `DynamicFieldPage` containing the paginated dynamic fields.
    /// - Throws: `SuiError.unableToValidateAddress` if the parent ID is not a valid Sui address.
    ///           `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getDynamicFields(
        parentId: String,
        filter: SuiObjectDataFilter? = nil,
        options: SuiObjectDataOptions? = nil,
        limit: Int? = nil,
        cursor: String? = nil
    ) async throws -> DynamicFieldPage {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Return the latest SUI system state object on-chain.
    /// - Returns: A `JSON` object containing the information of the latest Sui system state.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func info() async throws -> JSON {
        throw SuiError.notImplemented
    }

    /// Return the list of objects owned by an address.
    ///
    /// If the address owns more than `QUERY_MAX_RESULT_LIMIT` objects, the pagination is not accurate, because previous page may have been updated when the next page is fetched.
    /// Please use suix_queryObjects if this is a concern.
    /// - Parameters:
    ///   - owner: The identifier of the owner.
    ///   - filter: An optional filter to apply to the owned objects.
    ///   - options: An optional set of options to apply to the owned objects.
    ///   - cursor: An optional cursor for paginating through owned objects.
    ///   - limit: An optional limit to the number of owned objects returned.
    /// - Returns: A `PaginatedObjectsResponse` containing the paginated owned objects.
    /// - Throws: `SuiError.unableToValidateAddress` if the owner is not a valid Sui address.
    ///           `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getOwnedObjects(
        owner: String,
        filter: SuiObjectDataFilter? = nil,
        options: SuiObjectDataOptions? = nil,
        cursor: String? = nil,
        limit: Int? = nil
    ) async throws -> PaginatedObjectsResponse {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetOwnedObjectsQuery(
                owner: owner,
                limit: limit != nil ? .init(integerLiteral: limit!) : .none,
                cursor: cursor != nil ? .init(stringLiteral: cursor!) : .none,
                showBcs: options?.showBcs ?? false,
                showContent: options?.showContent ?? false,
                showType: options?.showType ?? false,
                showOwner: options?.showOwner ?? false,
                showPreviousTransaction: options?.showPreviousTransaction ?? false,
                showStorageRebate: options?.showStorageRebate ?? false,
                filter: filter != nil ? .init(ObjectFilter(filter: filter!)) : .none
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return PaginatedObjectsResponse(
            data: data.address!.objects.nodes.map {
                SuiObjectResponse(
                    error: nil,
                    data: SuiObjectData(graphql: $0, showBcs: options?.showBcs ?? false)
                )
            },
            pageInfo: PageInfo(
                graphql: data.address!.objects.pageInfo
            )
        )
    }

    /// Return the reference gas price for the network.
    /// - Returns: A UInt64 representing the reference gas price.
    /// - Throws: An error if the RPC request fails.
    public func getReferenceGasPrice() async throws -> BigInt {
        let result = try await GraphQLClient.fetchQuery(client: self.apollo, query: GetReferenceGasPriceQuery())
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return BigInt(data.epoch!.referenceGasPrice!, radix: 10)!
    }

    // TODO: Implement function when write becomes available
    /// Retrieves the staking information for a given owner.
    /// - Parameter owner: The address of the owner whose staking information is to be retrieved.
    /// - Returns: An array of `DelegatedStake` objects representing the staking information.
    /// - Throws: An error if the RPC request fails or JSON parsing errors occur.
    public func getStakes(
        owner: String
    ) async throws -> [DelegatedStake] {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Retrieves the staking information for given stake IDs.
    ///
    /// If a Stake was withdrawn its status will be Unstaked.
    /// - Parameter stakes: An array of stake IDs whose staking information is to be retrieved.
    /// - Returns: An array of `DelegatedStake` objects representing the staking information.
    /// - Throws: An error if the RPC request fails or JSON parsing errors occur.
    public func getStakesByIds(
        stakes: [String]
    ) async throws -> [DelegatedStake] {
        throw SuiError.notImplemented
    }

    /// Retrieves the total supply of a coin type.
    /// - Parameter coinType: The type of the coin whose total supply is to be retrieved.
    /// - Returns: A UInt64 representing the total supply of the coin type.
    /// - Throws: An error if the RPC request fails.
    public func totalSupply(_ coinType: String) async throws -> BigInt {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetTotalSupplyQuery(coinType: coinType)
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return BigInt(data.coinMetadata!.supply!, radix: 10)! * BigInt(10).power(data.coinMetadata!.decimals!)
    }

    /// Retrieves the annual percentage yield (APY) of validators.
    /// - Returns: A `ValidatorApys` object representing the APYs of validators.
    /// - Throws: An error if the RPC request fails.
    public func getValidatorsApy() async throws -> ValidatorApys {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: GetValidatorsApyQuery()
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return ValidatorApys(graphql: data)
    }

    /// Queries events from the blockchain with provided filters.
    /// - Parameters:
    ///   - query: An optional `SuiEventFilter` to filter the events.
    ///   - cursor: An optional `EventId` to fetch events after a specific event ID.
    ///   - limit: An optional integer to limit the number of events fetched.
    ///   - order: An optional `SortOrder` enum to sort the fetched events.
    /// - Returns: A `PaginatedSuiMoveEvent` object representing the fetched events.
    /// - Throws: An error if the RPC request fails or the event parsing fails.
    public func queryEvents(
        query: SuiEventFilter? = nil,
        cursor: EventId? = nil,
        limit: Int? = nil,
        order: SortOrder? = nil
    ) async throws -> PaginatedSuiMoveEvent {
        let result = try await GraphQLClient.fetchQuery(
            client: self.apollo,
            query: order == .ascending ?
            QueryEventsQuery(
                filter: query != nil ? EventFilter(suiEventFilter: query!) : EventFilter(),
                before: .none,
                after: .none,
                first: (limit != nil ? .init(integerLiteral: limit!) : .none),
                last: .none
            ) :
            QueryEventsQuery(
                filter: query != nil ? EventFilter(suiEventFilter: query!) : EventFilter(),
                before: .none,
                after: .none,
                first: .none,
                last: (limit != nil ? .init(integerLiteral: limit!) : .none)
            )
        )
        guard let data = result.data else { throw SuiError.customError(message: "Missing GraphQL data") }
        return PaginatedSuiMoveEvent(
            data: data.events.nodes.map { SuiEvent(graphql: $0) },
            pageInfo: PageInfo(graphql: data.events.pageInfo)
        )
    }

    /// Queries transaction blocks based on provided parameters.
    /// - Parameters:
    ///   - cursor: An optional string used as a starting point to fetch transaction blocks.
    ///   - limit: An optional integer representing the maximum number of transaction blocks to fetch.
    ///   - order: An optional `SortOrder` enum to sort the fetched transaction blocks.
    ///   - filter: An optional `TransactionFilter` to filter the fetched transaction blocks.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to specify response options.
    /// - Returns: A `PaginatedTransactionResponse` object containing the transaction blocks that meet the given criteria.
    /// - Throws: An error if the RPC request fails or if the parsing of the received data fails.
    public func queryTransactionBlocks(
        cursor: String? = nil,
        limit: Int? = nil,
        order: SortOrder? = nil,
        filter: TransactionFilter? = nil,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> PaginatedTransactionResponse {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Resolves a nameservice address to its corresponding account address.
    /// - Parameter name: A string representing the nameservice address to resolve.
    /// - Returns: An `AccountAddress` representing the resolved account address.
    /// - Throws: An error if the RPC request fails or if the conversion from hexadecimal fails.
    public func resolveNameserviceAddress(name: String) async throws -> AccountAddress {
        throw SuiError.notImplemented
    }

    // TODO: Implement Resolve Name Service Names
    /// Waits for a transaction to be processed and retrieves the transaction block.
    /// - Parameters:
    ///   - tx: A string representing the transaction hash.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to specify response options.
    /// - Returns: A `SuiTransactionBlockResponse` object containing the information of the processed transaction block.
    /// - Throws: A `SuiError.transactionTimedOut` error if the transaction does not get processed within a certain time frame, or other errors if the RPC request fails.
    public func waitForTransaction(
        tx: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> SuiTransactionBlockResponse {
        throw SuiError.notImplemented
    }

    // TODO: Implement function when write becomes available
    /// Checks if a transaction block is valid by ensuring it has a timestamp.
    /// - Parameters:
    ///   - tx: A string representing the transaction hash.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to specify response options.
    /// - Returns: A Boolean indicating whether the transaction block is valid.
    private func isValidTransactionBlock(
        tx: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async -> Bool {
        return false
    }
}
