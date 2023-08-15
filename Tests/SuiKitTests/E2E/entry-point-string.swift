//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/15/23.
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
        let _ = try tx.moveCall(
            target: "\(self.fetchPackageId())::entry_point_types::\(funcName)",
            arguments: [
                .input(tx.pure(value: .string(str))),
                .input(tx.pure(value: .number(UInt64(len))))
            ]
        )
        let result = try await self.fetchToolBox().client.signAndExecuteTransactionBlock(
            &tx,
            try self.fetchToolBox().account,
            SuiTransactionBlockResponseOptions(
                showInput: false,
                showEffects: true,
                showEvents: false,
                showObjectChanges: true,
                showBalanceChanges: false
            )
        )
        try await self.fetchToolBox().client.waitForTransaction(result["digest"].stringValue)
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            print("DEBUG: RESULT - \(result)")
            XCTFail("Transaction Failed")
            return
        }
    }

    private func callWithString(str: [String], len: Int, funcName: String) async throws {
        var tx = try TransactionBlock()
        let _ = try tx.moveCall(
            target: "\(self.fetchPackageId())::entry_point_types::\(funcName)",
            arguments: [
                .input(tx.pure(value: .array(str.map { .string($0) }))),
                .input(tx.pure(value: .number(UInt64(len))))
            ]
        )
        let result = try await self.fetchToolBox().client.signAndExecuteTransactionBlock(
            &tx,
            try self.fetchToolBox().account,
            SuiTransactionBlockResponseOptions(
                showInput: false,
                showEffects: true,
                showEvents: false,
                showObjectChanges: true,
                showBalanceChanges: false
            )
        )
        try await self.fetchToolBox().client.waitForTransaction(result["digest"].stringValue)
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            print("DEBUG: RESULT - \(result)")
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
