//
//  BCS.swift
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

final class BCSTest: XCTestCase {
    private func ref() -> SuiObjectRef {
        return SuiObjectRef(
            objectId: "1000000000000000000000000000000000000000000000000000000000000000",
            version: "10000",
            digest: ([UInt8]([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9])).base58EncodedString
        )
    }

    // Oooh-weeee we nailed it!
    func testThatSerializingSimpleProgrammingTransactionsWorksAsIntended() throws {
        let moveCall: MoveCallTransaction = try MoveCallTransaction(
            target: "0x2::display::new",
            typeArguments: ["0x6::capy::Capy"],
            arguments: [
                .gasCoin,
                .nestedResult(NestedResult(index: 0, resultIndex: 1)),
                .input(TransactionBlockInput(index: 3)),
                .result(Result(index: 1))
            ]
        )
        let ser = Serializer()
        try Serializer._struct(ser, value: moveCall)

        let moveCallBytes: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 100, 105, 115, 112, 108, 97, 121, 3, 110, 101, 119, 1, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 99, 97, 112, 121, 4, 67, 97, 112, 121, 0, 4, 0, 3, 0, 0, 1, 0, 1, 3, 0, 2, 1, 0]
        let resultBytes = [UInt8](ser.output())

        XCTAssertEqual(moveCallBytes, resultBytes)
    }

    func testThatValidatesThatAProgrammableTransactionWillSerializeAndDeserializeAsIntended() throws {
        let serValue = Serializer()
        let serArguments = Serializer()
        let serAccount = Serializer()

        try serValue.sequence(["Capy {name}", "A cute little creature", "https://api.capy.art/{id}/svg"], Serializer.str)
        try serArguments.sequence(["name", "description", "img_url"], Serializer.str)
        try Serializer._struct(serAccount, value: AccountAddress.fromHex(self.ref().objectId))

        let sui = try Inputs.normalizeSuiAddress(value: "0x2").replacingOccurrences(of: "0x", with: "")
        let values = serValue.output()
        let arguments = serArguments.output()
        let account = serAccount.output()

        let txData = TransactionData.V1(TransactionDataV1(
            kind: .programmableTransaction(
                ProgrammableTransaction(
                    inputs: [
                        // first argument is the publisher object
                        Input(type: .object(.immOrOwned(ImmOrOwned(ref: self.ref())))),

                        // second argument is a vector of names
                        Input(type: .pure(PureCallArg(value: [UInt8](arguments)))),

                        // third argument is a vector of values
                        Input(type: .pure(PureCallArg(value: [UInt8](values)))),

                        // 4th and last argument is the account address to send display to
                        Input(type: .pure(PureCallArg(value: [UInt8](account))))
                    ],
                    transactions: [
                        .moveCall(
                            try MoveCallTransaction(
                                target: "\(sui)::display::new",
                                typeArguments: ["\(sui)::capy::Capy"],
                                arguments: [
                                    // publisher object
                                    .input(TransactionBlockInput(index: 0))
                                ]
                            )
                        ),
                        .moveCall(
                            try MoveCallTransaction(
                                target: "\(sui)::display::add_multiple",
                                typeArguments: ["\(sui)::capy::Capy"],
                                arguments: [
                                    // result of the first transaction
                                    .result(Result(index: 0)),
                                    // second argument - vector of names
                                    .input(TransactionBlockInput(index: 1)),
                                    // third argument - vector of values
                                    .input(TransactionBlockInput(index: 2))
                                ]
                            )
                        ),
                        .moveCall(
                            try MoveCallTransaction(
                                target: "\(sui)::display::update_version",
                                typeArguments: ["\(sui)::capy::Capy"],
                                arguments: [
                                    // result of the first transaction again
                                    .result(Result(index: 0))
                                ]
                            )
                        ),
                        .transferObjects(
                            TransferObjectsTransaction(
                                objects: [
                                    // the display object
                                    .result(Result(index: 0))
                                ],
                                // address is also an input
                                address: .input(TransactionBlockInput(index: 3))
                            )
                        )
                    ]
                )
            ),
            sender: try AccountAddress.fromHex(try Inputs.normalizeSuiAddress(value: "0xBAD")),
            gasData: SuiGasData(payment: [self.ref()], owner: sui, price: "1", budget: "1000000"),
            expiration: .none
        ))

        let ser = Serializer()
        try Serializer._struct(ser, value: txData)
        let resultBytes = ser.output()
        let der = Deserializer(data: resultBytes)
        let result: TransactionData = try Deserializer._struct(der)
        if case .V1(let transactionDataV1Result) = result {
            if case .V1(let transactionDataV1TxData) = txData {
                XCTAssertEqual(transactionDataV1Result.sender, transactionDataV1TxData.sender)
            }
        }

        let txBytes: [UInt8] = [0, 0, 4, 1, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 39, 0, 0, 0, 0, 0, 0, 20, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 26, 3, 4, 110, 97, 109, 101, 11, 100, 101, 115, 99, 114, 105, 112, 116, 105, 111, 110, 7, 105, 109, 103, 95, 117, 114, 108, 0, 66, 3, 11, 67, 97, 112, 121, 32, 123, 110, 97, 109, 101, 125, 22, 65, 32, 99, 117, 116, 101, 32, 108, 105, 116, 116, 108, 101, 32, 99, 114, 101, 97, 116, 117, 114, 101, 29, 104, 116, 116, 112, 115, 58, 47, 47, 97, 112, 105, 46, 99, 97, 112, 121, 46, 97, 114, 116, 47, 123, 105, 100, 125, 47, 115, 118, 103, 0, 32, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 100, 105, 115, 112, 108, 97, 121, 3, 110, 101, 119, 1, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 99, 97, 112, 121, 4, 67, 97, 112, 121, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 100, 105, 115, 112, 108, 97, 121, 12, 97, 100, 100, 95, 109, 117, 108, 116, 105, 112, 108, 101, 1, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 99, 97, 112, 121, 4, 67, 97, 112, 121, 0, 3, 2, 0, 0, 1, 1, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 100, 105, 115, 112, 108, 97, 121, 14, 117, 112, 100, 97, 116, 101, 95, 118, 101, 114, 115, 105, 111, 110, 1, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 99, 97, 112, 121, 4, 67, 97, 112, 121, 0, 1, 2, 0, 0, 1, 1, 2, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 173, 1, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 39, 0, 0, 0, 0, 0, 0, 20, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 64, 66, 15, 0, 0, 0, 0, 0, 0]

        XCTAssertEqual(txBytes, [UInt8](resultBytes))
    }
}
