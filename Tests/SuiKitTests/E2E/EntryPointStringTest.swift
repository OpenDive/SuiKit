//
//  EntryPointStringTest.swift
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

final class EntryPointStringTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.packageId = try await self.fetchToolBox().publishPackage("entry-point-types").packageId
    }

    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }

    private func fetchPackageId() throws -> String {
        guard let packageId = self.packageId else {
            XCTFail("Failed to get Package ID")
            throw NSError(domain: "Failed to get Package ID", code: -1)
        }
        return packageId
    }

    private func callWithString(str: String, len: Int, funcName: String) async throws {
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(self.fetchPackageId())::entry_point_types::\(funcName)",
            arguments: [
                .input(tx.pure(value: .string(str))),
                .input(tx.pure(value: .number(UInt64(len))))
            ]
        )
        let options = SuiTransactionBlockResponseOptions(showEffects: true)
        var result = try await self.fetchToolBox().client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: try self.fetchToolBox().account,
            options: options
        )
        result = try await self.fetchToolBox().client.waitForTransaction(tx: result.digest, options: options)
        guard result.effects?.status.status == .success else {
            XCTFail("Transaction Failed")
            return
        }
    }

    private func callWithString(str: [String], len: Int, funcName: String) async throws {
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(self.fetchPackageId())::entry_point_types::\(funcName)",
            arguments: [
                .input(tx.pure(value: .array(str.map { .string($0) }))),
                .input(tx.pure(value: .number(UInt64(len))))
            ]
        )
        let options = SuiTransactionBlockResponseOptions(showEffects: true)
        var result = try await self.fetchToolBox().client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: try self.fetchToolBox().account,
            options: options
        )
        result = try await self.fetchToolBox().client.waitForTransaction(
            tx: result.digest,
            options: options
        )
        guard result.effects?.status.status == .success else {
            XCTFail("Transaction Failed")
            return
        }
    }

    func testThatAsciiStringsWillBeCalled() async throws {
        let s = "SomeString"
        try await self.callWithString(str: s, len: s.count, funcName: "ascii_arg")
    }

    func testThatUtf8StringsWillBeCalled() async throws {
        let s = "çå∞≠¢õß∂ƒ∫"
        let byteLength = 24
        try await self.callWithString(str: s, len: byteLength, funcName: "utf8_arg")
    }

    func testThatStringVecsWillBeCalled() async throws {
        let s1 = "çå∞≠¢"
        let s2 = "õß∂ƒ∫"
        let byteLength = 24
        try await self.callWithString(str: [s1, s2], len: byteLength, funcName: "utf8_vec_arg")
    }
}
