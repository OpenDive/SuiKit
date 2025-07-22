//
//  SuiNSTest.swift
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
import XCTest
@testable import SuiKit

final class SuiNSTest: XCTestCase {
    let domainName = "test.sui"
    let walletAddress = "0xfce343a643991c592c4f1a9ee415a7889293f694ab8828f78e3c81d11c9530c6"

    var nonExistingDomain: String?
    var nonExistingWalletAddress: String?
    var client: SuiNSClient?

    override func setUp() async throws {
        self.client = SuiNSClient(
            suiClient: SuiProvider(
                connection: TestnetConnection()
            ),
            contractObject: SuiNSContract(
                packageId: "0xfdba31b34a43e058f17c5cf4b12d9b9e0a08c0623d8569092c022e0c77df46d3",
                suins: "0x4acaf19db12fafce1943bbd44c7f794e1d81d00aeb63617096e5caa39499ba88",
                registry: "0xac06695279c2a92436068cebe5ea778135ac503337642e27493431603ae6a71d",
                reverseRegistry: "0x34a36dd204f8351a157d19b87bada9d448ec40229d56f22bff04fa23713a5c31"
            )
        )
        self.nonExistingDomain = "\(self.walletAddress).sui"
        self.nonExistingWalletAddress = walletAddress.dropLast(4) + "0000"
    }

    func fetchClient() throws -> SuiNSClient {
        guard let nsClient = self.client else {
            XCTFail("Failed to get Client")
            throw NSError(domain: "Failed to get Client", code: -1)
        }
        return nsClient
    }

    func fetchNonExistingDomain() throws -> String {
        guard let domain = self.nonExistingDomain else {
            XCTFail("Failed to get Domain")
            throw NSError(domain: "Failed to get Domain", code: -1)
        }
        return domain
    }

    func fetchNonExistingWalletAddress() throws -> String {
        guard let walletAddress = self.nonExistingWalletAddress else {
            XCTFail("Failed to get Wallet Address")
            throw NSError(domain: "Failed to get Wallet Address", code: -1)
        }
        return walletAddress
    }

    func testThatGettingAddressWorksAsIntendedWithInputDomainHavingALinkedAddressSet() async throws {
        let client = try self.fetchClient()
        let domainWallet = try await client.getAddress(domain: self.domainName)
        XCTAssertEqual(self.walletAddress, domainWallet)
    }

    func testThatGettingAddressWorksAsIntendedWithInputDomainNothavingALinkedAddressSet() async throws {
        let client = try self.fetchClient()
        let nonExistingDomain = try self.fetchNonExistingDomain()
        let domainWallet = try await client.getAddress(domain: nonExistingDomain)
        XCTAssertNil(domainWallet)
    }

    func testThatGettingNameWorksAsIntendedWithInputDomainHavingADefaultNameSet() async throws {
        let client = try self.fetchClient()
        let name = try await client.getName(address: self.walletAddress)
        XCTAssertEqual(name, self.domainName)
    }

    func testThatGettingNameWorksAsIntendedWithInputDomainNotHavingADefaultNameSet() async throws {
        let client = try self.fetchClient()
        let walletDomain = try self.fetchNonExistingWalletAddress()
        let name = try await client.getName(address: walletDomain)
        XCTAssertNil(name)
    }

    func testThatGettingNameObjectWorksAsIntendedWithGettingDataRelatedToTheName() async throws {
        let client = try self.fetchClient()
        let nameObject = try await client.getNameObject(name: self.domainName, showOwner: true, showAvatar: true)
        XCTAssertEqual(nameObject, NameObject(
            id: "0x7ee9ac31830e91f76f149952f7544b6d007b9a5520815e3d30264fa3d2791ad1",
            owner: self.walletAddress,
            targetAddress: self.walletAddress,
            avatar: "https://api-testnet.suifrens.sui.io/suifrens/0x4e3ba002444df6c6774f41833f881d351533728d585343c58cca1fec1fef74ef/svg",
            contentHash: "QmZsHKQk9FbQZYCy7rMYn1z6m9Raa183dNhpGCRm3fX71s",
            nftId: "0x2879ff9464f06c0779ca34eec6138459a3e9855852dd5d1a025164c344b2b555",
            expirationTimestampMs: "1715765005617"
        ))
    }

    func testThatGettingNameObjectWorksAsIntendedWithAvatarFlagDisabled() async throws {
        let client = try self.fetchClient()
        let nameObject = try await client.getNameObject(name: self.domainName, showOwner: true)
        XCTAssertNil(nameObject?.avatar)
    }

    func testThatGettingNameObjectWorksAsIntendedWithOwnerFlagDisabled() async throws {
        let client = try self.fetchClient()
        let nameObject = try await client.getNameObject(name: self.domainName, showAvatar: true)
        XCTAssertNil(nameObject?.owner)
    }

//    func testThatGettingNameDataWorksAsIntended() async throws {
//        let client = try self.fetchClient()
//        let result = try await client.getNameData(dataObjectId: "0x7ee9ac31830e91f76f149952f7544b6d007b9a5520815e3d30264fa3d2791ad1", fields: [.avatar, .contentHash])
//    }
}
