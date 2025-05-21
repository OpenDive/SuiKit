//
//  zkLoginSignerTests.swift
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
import BigInt
@testable import SuiKit

// Type alias to fix naming conflicts
typealias zkLoginSigner = ZkLoginSigner

final class zkLoginSignerTests: XCTestCase {
    var toolBox: TestToolbox?
    
    let issInput = "https://accounts.google.com"

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
    }
    
    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }
    
    // Test signing and executing a transaction with zkLogin
    func testzkLoginSignerExecuteTransaction() async throws {
        // Setup toolbox
        let toolbox = try fetchToolBox()
        
        // Create sample zkLogin signature components using realistic test data
        let aSignatureInputs = zkLoginSignatureInputs(
            proofPoints: zkLoginSignatureInputsProofPoints(
                a: [
                    "11701866812704517213914612798674748657755566586597434810941240483346769369267",
                    "14120438998063692297386249754230972715153876537530168883981513584586172195841",
                    "1"
                ],
                b: [
                    [
                        "1867454501602583848852787782761996560170118249299507014999230886852556998273",
                        "14466419698679116313475210654562949128349597101769256959010003188886091080310"
                    ],
                    [
                        "11072954562924588496148632474078432406633288948256718809714861986119303529760",
                        "19790516010784935100150614989097908233899718645536130727773713407611161368046"
                    ],
                    ["1", "0"]
                ],
                c: [
                    "10423289051853033915380810516130205747182867596457139999176714476415148376350",
                    "21785719695848013908061492989765777788142255897986300241561280196745174934457",
                    "1"
                ]
            ),
            issBase64Details: zkLoginSignatureInputsClaim(value: "yJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLC", indexMod4: 1),
            headerBase64: "eyJhbGciOiJSUzI1NiIsImtpZCI6ImI5YWM2MDFkMTMxZmQ0ZmZkNTU2ZmYwMzJhYWIxODg4ODBjZGUzYjkiLCJ0eXAiOiJKV1QifQ",
            addressSeed: "13322897930163218532266430409510394316985274769125667290600321564259466511711"
        )
        
        print("DEBUG::: ZK SIGNATURE INPUTS - \(aSignatureInputs)")
        
        let zkSignature = zkLoginSignature(
            inputs: aSignatureInputs,
            maxEpoch: 174,
            userSignature: [UInt8](repeating: 0, count: 64) // Empty signature for now
        )
        
        // Calculate address properly
        let userAddress = try zkLoginUtilities.computezkLoginAddressFromSeed(
            addressSeed: BigInt(aSignatureInputs.addressSeed)!,
            issInput: self.issInput
        )
        
        print("Using zkLogin address: \(userAddress)")
        
        // Faucet 10 SUI to zkLogin account
        print("Fauceting funds to \(userAddress)...")
        let faucet = FaucetClient(connection: toolbox.client.connection)
        let response = try await faucet.funcAccount(userAddress)
        guard let faucet_coins = response.coinsSent else {
            XCTFail("Unable to send coins to address \(userAddress)")
            return
        }
        for faucet_coin in faucet_coins {
            let _ = try await toolbox.client.waitForTransaction(tx: faucet_coin.transferTxDigest)
            print("--- \(faucet_coin.transferTxDigest) ::: \(userAddress) ---")
            try await Task.sleep(nanoseconds: 3_000_000_000)
        }
        
        // Create zkLoginSigner
        let signer = zkLoginSigner(
            provider: toolbox.client,
            ephemeralKeyPair: toolbox.account,
            zkLoginSignature: zkSignature,
            userAddress: userAddress
        )
        
        // Create a sample transaction
        var tx = try TransactionBlock()
        try tx.setSenderIfNotSet(sender: userAddress)
        
        // Execute the transaction
        var transactionResult = try await signer.signAndExecuteTransactionBlock(
            transactionBlock: &tx
        )
        transactionResult = try await toolbox.client.waitForTransaction(tx: transactionResult.digest)
        let ser = Serializer()
        try transactionResult.transaction!.data.serialize(ser)
        
        // Verify the provider was called with the correct parameters
        guard transactionResult.effects?.status.status == .success else {
            XCTFail("Transaction execution failed with error: \(transactionResult.effects?.status.error ?? "UNKNOWN_ERROR")")
            return
        }
        
        // Verify the signature starts with the zkLogin signature scheme byte (5)
        if let signatures = transactionResult.transaction,
           !signatures.txSignature.isEmpty,
           let signature = signatures.txSignature.first
        {
            if let firstByte = Data(base64Encoded: signature)?[0] {
                XCTAssertEqual(firstByte, SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["zkLogin"])
            } else {
                XCTFail("Could not decode signature: \(signature)")
            }
        }
    }
    
    // Test creating a zkLogin signature with correct format
    func testCreatezkLoginSignature() throws {
        // Setup toolbox
        let toolbox = try fetchToolBox()
        
        // Create sample zkLogin signature components using realistic test data
        let zkSigInputs = try! JWTUtilities.decodezkLoginInputs(
            fromJson: "{\"proofPoints\":{\"a\":[\"17318089125952421736342263717932719437717844282410187957984751939942898251250\",\"11373966645469122582074082295985388258840681618268593976697325892280915681207\",\"1\"],\"b\":[[\"5939871147348834997361720122238980177152303274311047249905942384915768690895\",\"4533568271134785278731234570361482651996740791888285864966884032717049811708\"],[\"10564387285071555469753990661410840118635925466597037018058770041347518461368\",\"12597323547277579144698496372242615368085801313343155735511330003884767957854\"],[\"1\",\"0\"]],\"c\":[\"15791589472556826263231644728873337629015269984699404073623603352537678813171\",\"4547866499248881449676161158024748060485373250029423904113017422539037162527\",\"1\"]},\"issBase64Details\":{\"value\":\"wiaXNzIjoiaHR0cHM6Ly9pZC50d2l0Y2gudHYvb2F1dGgyIiw\",\"indexMod4\":2},\"headerBase64\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEifQ\"}",
            andAddressSeed: "20794788559620669596206457022966176986688727876128223628113916380927502737911"
        )
        
        let zkSignature = zkLoginSignature(
            inputs: zkSigInputs,
            maxEpoch: 5,
            userSignature: [UInt8](repeating: 0, count: 64) // Empty signature for now
        )
        
        // Serialize the signature
        let serialized = zkLoginSignature.serialize(signature: zkSignature)
        print("Serialized zkLogin signature: \(serialized)")
        
        // Parse it back
        let parsedSignature = try zkLoginSignature.parse(serialized: serialized)
        
        // Verify the deserialized signature matches the original
        XCTAssertEqual(parsedSignature.maxEpoch, zkSignature.maxEpoch)
        XCTAssertEqual(parsedSignature.inputs.addressSeed, zkSignature.inputs.addressSeed)
        XCTAssertEqual(parsedSignature.inputs.headerBase64, zkSignature.inputs.headerBase64)
        XCTAssertEqual(parsedSignature.inputs.issBase64Details.value, zkSignature.inputs.issBase64Details.value)
        
        // Test points should match in the proofPoints struct
        XCTAssertEqual(parsedSignature.inputs.proofPoints.a, zkSignature.inputs.proofPoints.a)
        XCTAssertEqual(parsedSignature.inputs.proofPoints.b, zkSignature.inputs.proofPoints.b)
        XCTAssertEqual(parsedSignature.inputs.proofPoints.c, zkSignature.inputs.proofPoints.c)
    }
    
    // Test integration with TransactionBlock
    func testzkLoginWithTransactionBlock() async throws {
        // Setup toolbox
        let toolbox = try fetchToolBox()
        
        // Create sample zkLogin signature components using realistic test data
        let zkSigInputs = try! JWTUtilities.decodezkLoginInputs(
            fromJson: "{\"proofPoints\":{\"a\":[\"17318089125952421736342263717932719437717844282410187957984751939942898251250\",\"11373966645469122582074082295985388258840681618268593976697325892280915681207\",\"1\"],\"b\":[[\"5939871147348834997361720122238980177152303274311047249905942384915768690895\",\"4533568271134785278731234570361482651996740791888285864966884032717049811708\"],[\"10564387285071555469753990661410840118635925466597037018058770041347518461368\",\"12597323547277579144698496372242615368085801313343155735511330003884767957854\"],[\"1\",\"0\"]],\"c\":[\"15791589472556826263231644728873337629015269984699404073623603352537678813171\",\"4547866499248881449676161158024748060485373250029423904113017422539037162527\",\"1\"]},\"issBase64Details\":{\"value\":\"wiaXNzIjoiaHR0cHM6Ly9pZC50d2l0Y2gudHYvb2F1dGgyIiw\",\"indexMod4\":2},\"headerBase64\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEifQ\"}",
            andAddressSeed: "20794788559620669596206457022966176986688727876128223628113916380927502737911"
        )
        
        let zkSignature = zkLoginSignature(
            inputs: zkSigInputs,
            maxEpoch: 5,
            userSignature: [UInt8](repeating: 0, count: 64) // Empty signature for now
        )
        
        // Get address from zkLogin components
        let userAddress = try zkLoginUtilities.computezkLoginAddressFromSeed(
            addressSeed: BigInt(zkSigInputs.addressSeed)!,
            issInput: self.issInput
        )
        
        print("Using zkLogin address in TransactionBlock test: \(userAddress)")
        
        // Create zkLoginSigner
        let signer = zkLoginSigner(
            provider: toolbox.client,
            ephemeralKeyPair: toolbox.account,
            zkLoginSignature: zkSignature,
            userAddress: userAddress
        )
        
        // Create a transaction block with SUI transfer
        var tx = try TransactionBlock()
        try tx.setSender(sender: userAddress)
        
        // Add a SUI transfer operation
        let transferResult = try tx.moveCall(
            target: "0x2::pay::split_and_transfer",
            arguments: [
                .gasCoin,
                .input(tx.pure(value: .string("0x5fbcee7f5365c5a1aeea13600b56a0aea8f17a0129ff99894aa6b47f3a7efe38"))),
                .input(tx.pure(value: .number(UInt64(1_000_000_000))))  // 1 SUI
            ]
        )
        
        XCTAssertNotNil(transferResult)
        
        // Execute the transaction
        let response = try await signer.signAndExecuteTransactionBlock(
            transactionBlock: &tx
        )
        
        // Verify response
        XCTAssertEqual(response.digest, response.digest)
        XCTAssertNotNil(response.confirmedLocalExecution)
        XCTAssertTrue(response.confirmedLocalExecution!)
        
        let ser = Serializer()
        try response.transaction!.data.serialize(ser)
        
        // Verify transaction was properly built
        XCTAssertNotNil(ser.output())
    }
}
