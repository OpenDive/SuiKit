//
//  SuiNSClient.swift
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

import SwiftyJSON
@preconcurrency import AnyCodable
import Foundation

public class SuiNSClient {
    private let suiClient: SuiProvider
    public var contractObject: SuiNSContract?
    public var networkType: NetworkType?

    public init(
        suiClient: SuiProvider,
        contractObject: SuiNSContract? = nil,
        networkType: NetworkType? = nil
    ) {
        self.suiClient = suiClient
        self.contractObject = contractObject
        self.networkType = networkType
    }

    public func getSuiNSContractObject() async throws {
        guard self.contractObject?.packageId == nil else { return }

        let contractJsonFileUrl = "\(gcsUrl)\(self.networkType != nil && self.networkType == .testnet ? testnetJsonFile : devnetJsonFile)"
        guard let url = URL(string: contractJsonFileUrl) else { return }

        var requestUrl = URLRequest(url: url)
        requestUrl.httpMethod = "GET"

        guard let result = try await withCheckedThrowingContinuation({ (con: CheckedContinuation<Data?, Error>) in
            let task = URLSession.shared.dataTask(with: requestUrl) { data, _, error in
                if let error = error {
                    con.resume(throwing: error)
                } else if let data = data {
                    con.resume(returning: data)
                } else {
                    con.resume(returning: nil)
                }
            }
            task.resume()
        }) else { return }

        let json = JSON(result)

        self.contractObject = SuiNSContract(
            packageId: json["packageId"].stringValue,
            suins: json["suins"].stringValue,
            registry: json["registry"].stringValue,
            reverseRegistry: json["reverseRegistry"].stringValue
        )
    }

    public func getDynamicFieldObject(
        parentObjectId: String,
        key: JSON,
        type: String = "0x1::string::String"
    ) async throws -> SuiObjectResponse? {
        guard let dynamicFieldObject = try await self.suiClient.getDynamicFieldObject(
            parentId: parentObjectId,
            name: DynamicFieldName(type: type, value: key)
        ) else { return nil }

        guard dynamicFieldObject.error?.localizedDescription != "dynamicFieldNotFound" else { return nil }

        return dynamicFieldObject
    }

    // TODO: Implement rest of function
    // https://github.com/MystenLabs/sui/blob/d9342b76642aee726637567ebc02af270e2b602a/sdk/suins-toolkit/src/client.ts#L83
//    public func getNameData(dataObjectId: String, fields: [DataFields] = []) async throws -> String? {
//        guard !dataObjectId.isEmpty else { return nil }
//        
//        let dynamicFields = (try await self.suiClient.getDynamicFields(
//            parentId: dataObjectId)
//        ).data
//
//        let filteredFields = Set(fields)
//        let filteredDynamicFields = dynamicFields.filter { field in
//            let dataFieldName = field.name.value["value"].stringValue
//            guard let fieldName = DataFields(rawValue: dataFieldName) else { return false }
//            return filteredFields.contains(fieldName)
//        }
//
//        var data: [String: MoveValue] = [:]
//        try await filteredDynamicFields.asyncForEach { fieldInfo in
//            let object = try await self.suiClient.getObject(objectId: fieldInfo.objectId, options: SuiObjectDataOptions(showContent: true))
//
//            if let object {
//                if let parsedObject = SuiNSParser.parseObjectDataResponse(response: object) {
//                    print(parsedObject)
//                }
//            }
//        }
//        return nil
//    }

    /// Returns the name object data.
    ///
    /// If the input domain has not been registered, it will return an empty object.
    /// If `showAvatar` is included, the owner will be fetched as well.
    public func getNameObject(
        name: String,
        showOwner: Bool = false,
        showAvatar: Bool = false
    ) async throws -> NameObject? {
        let (domain, tld) = name.extractDomainAndTLD()
        try await self.getSuiNSContractObject()

        guard let contractObject = self.contractObject else { return nil }
        guard let domain, let tld else { return nil }

        guard let registryResponse = try await self.getDynamicFieldObject(
            parentObjectId: contractObject.registry,
            key: JSON([tld, domain]),
            type: "\(contractObject.packageId)::domain::Domain"
        ) else { return nil }

        guard var namedObject = SuiNSParser.parseRegistryResponse(
            response: registryResponse
        ) else { return nil }

        // check if we should also query for avatar.
        // we can only query if the object has an avatar set
        // and the query includes avatar.
        let includeAvatar = namedObject.avatar != nil && showAvatar

        // IF we have showOwner or includeAvatar flag, we fetch the owner &/or avatar,
        // We use Promise.all to do these calls at the same time.
        if let nftId = namedObject.nftId {
            if includeAvatar || showOwner {
                let owner = try await SuiNSQueries.getOwner(
                    client: self.suiClient,
                    nftId: nftId
                )
                var avatar: SuiObjectResponse?
                if includeAvatar, let avatarName = namedObject.avatar {
                    avatar = try await SuiNSQueries.getAvatar(
                        client: self.suiClient,
                        avatar: avatarName
                    )
                }
                namedObject.owner = (owner != nil && showOwner) ? owner : nil

                // Parse avatar NFT, check ownership and fixup the request response.
                if includeAvatar {
                    if let avatar {
                        if
                            case .addressOwner(let addressOwner) = avatar.data?.owner,
                            addressOwner == namedObject.owner,
                            let display = avatar.data?.display,
                            let displayData = display.data {
                            namedObject.avatar = displayData["image_url"]
                        } else {
                            namedObject.avatar = avatarNotOwned
                        }
                    }
                } else {
                    namedObject.avatar = nil
                }
            }
        }

        return namedObject
    }

    /// Returns the linked address of the input domain if the link was set. Otherwise, it will return undefined.
    /// - Parameter domain: A domain name ends with `.sui`
    public func getAddress(
        domain: String
    ) async throws -> String? {
        guard let targetAddress = try await self.getNameObject(
            name: domain
        ) else { return nil }
        return targetAddress.targetAddress
    }

    /// Returns the default name of the input address if it was set. Otherwise, it will return undefined.
    /// - Parameter address: A Sui address.
    public func getName(address: String) async throws -> String? {
        guard let res = try await self.getDynamicFieldObject(
            parentObjectId: self.contractObject?.reverseRegistry ?? "",
            key: JSON(address),
            type: "address"
        ) else { return nil }

        guard
            let data = SuiNSParser.parseObjectDataResponse(response: res),
            let value = data["value"]
        else { return nil }

        let labels = value["fields"]["labels"].arrayValue
        return !labels.isEmpty ? labels.map { $0.stringValue }.reversed().joined(separator: ".") : nil
    }
}
