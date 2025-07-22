//
//  zkLoginSignatureSerializationTests.swift
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

final class zkLoginSignatureSerializationTests: XCTestCase {
    // Sample zkLogin signature from the TypeScript tests
    let sampleSignature = "BQNNMTE3MDE4NjY4MTI3MDQ1MTcyMTM5MTQ2MTI3OTg2NzQ3NDg2NTc3NTU1NjY1ODY1OTc0MzQ4MTA5NDEyNDA0ODMzNDY3NjkzNjkyNjdNMTQxMjA0Mzg5OTgwNjM2OTIyOTczODYyNDk3NTQyMzA5NzI3MTUxNTM4NzY1Mzc1MzAxNjg4ODM5ODE1MTM1ODQ1ODYxNzIxOTU4NDEBMQMCTDE4Njc0NTQ1MDE2MDI1ODM4NDg4NTI3ODc3ODI3NjE5OTY1NjAxNzAxMTgyNDkyOTk1MDcwMTQ5OTkyMzA4ODY4NTI1NTY5OTgyNzNNMTQ0NjY0MTk2OTg2NzkxMTYzMTM0NzUyMTA2NTQ1NjI5NDkxMjgzNDk1OTcxMDE3NjkyNTY5NTkwMTAwMDMxODg4ODYwOTEwODAzMTACTTExMDcyOTU0NTYyOTI0NTg4NDk2MTQ4NjMyNDc0MDc4NDMyNDA2NjMzMjg4OTQ4MjU2NzE4ODA5NzE0ODYxOTg2MTE5MzAzNTI5NzYwTTE5NzkwNTE2MDEwNzg0OTM1MTAwMTUwNjE0OTg5MDk3OTA4MjMzODk5NzE4NjQ1NTM2MTMwNzI3NzczNzEzNDA3NjExMTYxMzY4MDQ2AgExATADTTEwNDIzMjg5MDUxODUzMDMzOTE1MzgwODEwNTE2MTMwMjA1NzQ3MTgyODY3NTk2NDU3MTM5OTk5MTc2NzE0NDc2NDE1MTQ4Mzc2MzUwTTIxNzg1NzE5Njk1ODQ4MDEzOTA4MDYxNDkyOTg5NzY1Nzc3Nzg4MTQyMjU1ODk3OTg2MzAwMjQxNTYxMjgwMTk2NzQ1MTc0OTM0NDU3ATExeUpwYzNNaU9pSm9kSFJ3Y3pvdkwyRmpZMjkxYm5SekxtZHZiMmRzWlM1amIyMGlMQwFmZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkltSTVZV00yTURGa01UTXhabVEwWm1aa05UVTJabVl3TXpKaFlXSXhPRGc0T0RCalpHVXpZamtpTENKMGVYQWlPaUpLVjFRaWZRTTEzMzIyODk3OTMwMTYzMjE4NTMyMjY2NDMwNDA5NTEwMzk0MzE2OTg1Mjc0NzY5MTI1NjY3MjkwNjAwMzIxNTY0MjU5NDY2NTExNzExrgAAAAAAAABhAEp+O5GEAF/5tKNDdWBObNf/1uIrbOJmE+xpnlBD2Vikqhbd0zLrQ2NJyquYXp4KrvWUOl7Hso+OK0eiV97ffwucM8VdtG2hjf/RUGNO5JNUH+D/gHtE9sHe6ZEnxwZL7g=="
    let sampleEphemeralSignature = "AEp+O5GEAF/5tKNDdWBObNf/1uIrbOJmE+xpnlBD2Vikqhbd0zLrQ2NJyquYXp4KrvWUOl7Hso+OK0eiV97ffwucM8VdtG2hjf/RUGNO5JNUH+D/gHtE9sHe6ZEnxwZL7g=="

    // Test that zkLogin signature parsing works correctly
    func testParsezkLoginSignature() throws {
        // Convert the base64 signature to binary data and skip the first byte (flag)
        guard Data(base64Encoded: sampleSignature) != nil else {
            XCTFail("Failed to decode base64 signature")
            return
        }

        // Parse the signature (skipping the first byte which is the signature scheme flag)
        let parsedSignature = try zkLoginSignature.parse(serialized: sampleSignature)

        // Test signature components
        XCTAssertEqual(parsedSignature.maxEpoch, 174)

        // Test that the ephemeral signature matches
        XCTAssertEqual(Data(parsedSignature.userSignature).base64EncodedString(), sampleEphemeralSignature)

        // Check address seed
        XCTAssertEqual(parsedSignature.inputs.addressSeed, "13322897930163218532266430409510394316985274769125667290600321564259466511711")
    }

    // Test that zkLogin signature serialization works correctly
    func testSerializezkLoginSignature() throws {
        // Parse the original signature
        let parsedSignature = try zkLoginSignature.parse(serialized: sampleSignature)

        // Serialize it back
        let serialized = parsedSignature.serialize()

        // Verify the serialized signature matches the original
        XCTAssertEqual(serialized, sampleSignature)
    }

    // Test round-trip serialization and deserialization
    func testRoundTripzkLoginSignature() throws {
        // Create a signature from components
        let inputs = zkLoginSignatureInputs(
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
            issBase64Details: zkLoginSignatureInputsClaim(
                value: "yJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLC",
                indexMod4: 1
            ),
            headerBase64: "eyJhbGciOiJSUzI1NiIsImtpZCI6ImI5YWM2MDFkMTMxZmQ0ZmZkNTU2ZmYwMzJhYWIxODg4ODBjZGUzYjkiLCJ0eXAiOiJKV1QifQ",
            addressSeed: "13322897930163218532266430409510394316985274769125667290600321564259466511711"
        )

        guard let userSignature = Data(base64Encoded: sampleEphemeralSignature) else {
            XCTFail("Failed to decode ephemeral signature")
            return
        }

        let signature = zkLoginSignature(
            inputs: inputs,
            maxEpoch: 174,
            userSignature: [UInt8](userSignature)
        )

        // Serialize
        let serialized = signature.serialize()

        // Parse back
        let reparsed = try zkLoginSignature.parse(serialized: serialized)

        // Verify they're equal
        XCTAssertEqual(reparsed.maxEpoch, signature.maxEpoch)
        XCTAssertEqual(reparsed.inputs.addressSeed, signature.inputs.addressSeed)
        XCTAssertEqual(reparsed.inputs.headerBase64, signature.inputs.headerBase64)
        XCTAssertEqual(Data(reparsed.userSignature), Data(signature.userSignature))
    }
}
