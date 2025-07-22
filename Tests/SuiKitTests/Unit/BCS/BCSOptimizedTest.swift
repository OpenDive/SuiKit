//
//  BCSOptimizedTest.swift
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
import UInt256
@testable import SuiKit

/// Tests for SIMD-optimized BCS implementations to ensure correctness
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class BCSOptimizedTest: XCTestCase {

    private let allocator = BCSAllocator.shared

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        allocator.reset()
    }

    override func tearDown() {
        allocator.reset()
        super.tearDown()
    }

    // MARK: - SIMD Serializer Tests

    func testSIMDSerializerBasicTypes() throws {
        let serializer = Serializer(allocator: allocator)

        // Test UInt16 array
        let u16Array: [UInt16] = [1, 2, 3, 256, 65535]
        try serializer.serializeU16Array(u16Array)

        // Test UInt32 array
        let u32Array: [UInt32] = [1, 2, 3, 65536, 4294967295]
        try serializer.serializeU32Array(u32Array)

        // Test UInt64 array
        let u64Array: [UInt64] = [1, 2, 3, 4294967296, UInt64.max]
        try serializer.serializeU64Array(u64Array)

        // Test boolean array
        let boolArray: [Bool] = [true, false, true, true, false]
        try serializer.boolArray(boolArray)

        let output = serializer.output()
        XCTAssertFalse(output.isEmpty, "SIMD serializer should produce output")
    }

    func testSIMDSerializerLargeArrays() throws {
        let serializer = Serializer(allocator: allocator)

        // Test with arrays larger than SIMD threshold (64)
        let largeU32Array = Array(0..<100).map { UInt32($0) }
        try serializer.serializeU32Array(largeU32Array)

        let output = serializer.output()
        XCTAssertFalse(output.isEmpty, "SIMD serializer should handle large arrays")
    }

    func testSIMDSerializerSmallArrays() throws {
        let serializer = Serializer(allocator: allocator)

        // Test with arrays smaller than SIMD threshold (should fall back to standard serialization)
        let smallU32Array: [UInt32] = [1, 2, 3]
        try serializer.serializeU32Array(smallU32Array)

        let output = serializer.output()
        XCTAssertFalse(output.isEmpty, "SIMD serializer should handle small arrays")
    }

    // MARK: - SIMD Deserializer Tests

    func testSIMDDeserializerBasicTypes() throws {
        // Create test data using SIMD serializer
        let serializer = Serializer(allocator: allocator)
        let testU32Array: [UInt32] = [42, 100, 256, 1000, 65536]
        try serializer.serializeU32Array(testU32Array)
        let serializedData = serializer.output()

        // Deserialize using SIMD deserializer
        let deserializer = Deserializer(data: serializedData, allocator: allocator)
        let result = try deserializer.deserializeU32Array()

        XCTAssertEqual(result, testU32Array, "SIMD deserializer should correctly deserialize data")
        
        allocator.reset()
        
        let serBool = Serializer(allocator: allocator)
        
        let boolArray: [Bool] = [true, false, true, false]
        try serBool.boolArray(boolArray)
        let serData = serializer.output()
        
        let derBool = Deserializer(data: serData, allocator: allocator)
        let resBool = try derBool.deserializeBoolArray()
        
        XCTAssertEqual(resBool, boolArray, "SIMD deserializer should correctly deserialize data")
    }

    func testSIMDDeserializerLargeArrays() throws {
        // Test with large array
        let testArray = Array(0..<100).map { UInt16($0) }

        let serializer = Serializer(allocator: allocator)
        try serializer.serializeU16Array(testArray)
        let serializedData = serializer.output()

        let deserializer = Deserializer(data: serializedData, allocator: allocator)
        let result = try deserializer.deserializeU16Array()

        XCTAssertEqual(result, testArray, "SIMD deserializer should handle large arrays correctly")
    }

    func testSIMDRoundTripConsistency() throws {
        // Test various data types for round-trip consistency
        let testCases: [(name: String, data: Any, serialize: (Serializer, Any) throws -> Void, deserialize: (Deserializer) throws -> Any)] = [
            ("UInt16Array", [UInt16(1), 2, 3, 256],
             { s, d in try s.serializeU16Array(d as! [UInt16]) },
             { d in try d.deserializeU16Array() }),
            ("UInt32Array", [UInt32(1), 2, 3, 65536],
             { s, d in try s.serializeU32Array(d as! [UInt32]) },
             { d in try d.deserializeU32Array() }),
            ("UInt64Array", [UInt64(1), 2, 3, 4294967296],
             { s, d in try s.serializeU64Array(d as! [UInt64]) },
             { d in try d.deserializeU64Array() })
        ]

        for testCase in testCases {
            let serializer = Serializer(allocator: allocator)
            try testCase.serialize(serializer, testCase.data)
            let serializedData = serializer.output()

            let deserializer = Deserializer(data: serializedData, allocator: allocator)
            let result = try testCase.deserialize(deserializer)

            // Compare results (using string representation for simplicity)
            XCTAssertEqual(String(describing: result), String(describing: testCase.data),
                          "Round-trip consistency failed for \(testCase.name)")
        }
    }

    // MARK: - Custom Allocator Tests

    func testCustomAllocatorUsage() throws {
        let customAllocator = BCSAllocator.shared
        let serializer = Serializer(allocator: allocator)

        let testData = Array(0..<50).map { UInt32($0) }
        try serializer.serializeU32Array(testData)
        _ = serializer.output()

        let metrics = customAllocator.getAllocationMetrics()
        XCTAssertGreaterThan(metrics.totalAllocations, 0, "Custom allocator should be used")
        XCTAssertGreaterThan(metrics.totalMemoryAllocated, 0, "Custom allocator should allocate memory")
    }

    func testAllocatorStatistics() throws {
        let initialMetrics = allocator.getAllocationMetrics()

        let serializer = Serializer(allocator: allocator)
        let testData = Array(0..<1000).map { UInt32($0) }
        try serializer.serializeU32Array(testData)
        _ = serializer.output()

        let finalMetrics = allocator.getAllocationMetrics()

        XCTAssertGreaterThan(finalMetrics.totalAllocations, initialMetrics.totalAllocations,
                           "Allocator should track allocations")
        XCTAssertGreaterThanOrEqual(finalMetrics.cacheHitRate, 0.0,
                                  "Cache hit rate should be non-negative")
        XCTAssertLessThanOrEqual(finalMetrics.cacheHitRate, 1.0,
                                "Cache hit rate should not exceed 100%")
    }

    // MARK: - Edge Cases

    func testEmptyArraySerialization() throws {
        let serializer = Serializer(allocator: allocator)

        // Test empty arrays
        try serializer.serializeU32Array([])
        try serializer.boolArray([])

        let output = serializer.output()
        XCTAssertFalse(output.isEmpty, "Should be able to serialize empty arrays")

        // Test deserialization
        let deserializer = Deserializer(data: output, allocator: allocator)
        let u32Result = try deserializer.deserializeU32Array()
        let boolResult = try deserializer.deserializeBoolArray()

        XCTAssertTrue(u32Result.isEmpty, "Should deserialize to empty UInt32 array")
        XCTAssertTrue(boolResult.isEmpty, "Should deserialize to empty Bool array")
    }

    func testSingleElementArrays() throws {
        let serializer = Serializer(allocator: allocator)

        // Test single element arrays
        try serializer.serializeU32Array([42])
        try serializer.boolArray([true])

        let output = serializer.output()

        let deserializer = Deserializer(data: output, allocator: allocator)
        let u32Result = try deserializer.deserializeU32Array()
        let boolResult = try deserializer.deserializeBoolArray()

        XCTAssertEqual(u32Result, [42], "Should handle single element UInt32 array")
        XCTAssertEqual(boolResult, [true], "Should handle single element Bool array")
    }

    func testMaxValuesSerialization() throws {
        let serializer = Serializer(allocator: allocator)

        // Test maximum values
        try serializer.serializeU16Array([UInt16.max])
        try serializer.serializeU32Array([UInt32.max])
        try serializer.serializeU64Array([UInt64.max])

        let output = serializer.output()
        XCTAssertFalse(output.isEmpty, "Should handle maximum values")

        // Test round-trip
        let deserializer = Deserializer(data: output, allocator: allocator)
        let u16Result = try deserializer.deserializeU16Array()
        let u32Result = try deserializer.deserializeU32Array()
        let u64Result = try deserializer.deserializeU64Array()

        XCTAssertEqual(u16Result, [UInt16.max], "Should handle UInt16.max")
        XCTAssertEqual(u32Result, [UInt32.max], "Should handle UInt32.max")
        XCTAssertEqual(u64Result, [UInt64.max], "Should handle UInt64.max")
    }
}
