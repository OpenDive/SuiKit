//
//  BCSAllocator.swift
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
import os

/// A high-performance memory allocator optimized for BCS serialization patterns on Apple Silicon
/// Features aligned memory allocation, memory pools, and cache-friendly allocation strategies
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public final class BCSAllocator {

    // MARK: - Constants

    private static let PAGE_SIZE = 16384 // Apple Silicon page size
    private static let CACHE_LINE_SIZE = 64 // Apple Silicon cache line size
    private static let MAX_SMALL_ALLOCATION = 1024
    private static let POOL_SIZES: [Int] = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384]
    private static let MAX_POOL_SIZE = 32 // Maximum number of blocks per pool
    private static let ALIGNMENT_MASK = 31 // For 32-byte alignment
    public static let MIN_ALIGNMENT = 32

    // MARK: - Shared Instance

    public static let shared = BCSAllocator()

    // MARK: - Memory Pool Structure

    private struct MemoryPool {
        let blockSize: Int
        var freeBlocks: [UnsafeMutableRawBufferPointer]
        var allocatedBlocks: Set<UnsafeMutableRawPointer>
        var totalAllocated: Int
        var totalDeallocated: Int

        init(blockSize: Int) {
            self.blockSize = blockSize
            self.freeBlocks = []
            self.allocatedBlocks = []
            self.totalAllocated = 0
            self.totalDeallocated = 0
        }

        mutating func allocate() -> UnsafeMutableRawBufferPointer? {
            if !freeBlocks.isEmpty {
                let block = freeBlocks.removeLast()
                allocatedBlocks.insert(block.baseAddress!)
                return block
            }
            return nil
        }

        mutating func deallocate(_ buffer: UnsafeMutableRawBufferPointer) {
            guard let baseAddress = buffer.baseAddress else { return }
            if allocatedBlocks.remove(baseAddress) != nil {
                totalDeallocated += 1
                if freeBlocks.count < BCSAllocator.MAX_POOL_SIZE {
                    freeBlocks.append(buffer)
                } else {
                    buffer.deallocate()
                }
            }
        }
    }

    // MARK: - Allocation Metrics Structure

    public struct AllocationMetrics {
        public let totalAllocations: Int
        public let totalDeallocations: Int
        public let cacheHits: Int
        public let cacheMisses: Int
        public let totalMemoryAllocated: Int
        public let poolUtilization: [Int: Double]
        public let memoryEfficiency: Double
        public let cacheHitRate: Double
        public let averageAllocationSize: Double
        public let peakMemoryUsage: Int

        public init(
            totalAllocations: Int = 0,
            totalDeallocations: Int = 0,
            cacheHits: Int = 0,
            cacheMisses: Int = 0,
            totalMemoryAllocated: Int = 0,
            poolUtilization: [Int: Double] = [:],
            memoryEfficiency: Double = 0.0,
            cacheHitRate: Double = 0.0,
            averageAllocationSize: Double = 0.0,
            peakMemoryUsage: Int = 0
        ) {
            self.totalAllocations = totalAllocations
            self.totalDeallocations = totalDeallocations
            self.cacheHits = cacheHits
            self.cacheMisses = cacheMisses
            self.totalMemoryAllocated = totalMemoryAllocated
            self.poolUtilization = poolUtilization
            self.memoryEfficiency = memoryEfficiency
            self.cacheHitRate = cacheHitRate
            self.averageAllocationSize = averageAllocationSize
            self.peakMemoryUsage = peakMemoryUsage
        }
    }

    // MARK: - Properties

    private let lock = OSAllocatedUnfairLock()
    private var pools: [Int: MemoryPool]
    private var largeAllocations: Set<UnsafeMutableRawPointer>
    private var allocationCount: Int = 0
    private var deallocatedCount: Int = 0
    private var cacheHits: Int = 0
    private var cacheMisses: Int = 0
    private var totalMemoryAllocated: Int = 0
    private var peakMemoryUsage: Int = 0

    // MARK: - Initialization

    public init() {
        self.pools = [:]
        self.largeAllocations = []

        // Pre-initialize pools for common sizes
        for size in Self.POOL_SIZES {
            pools[size] = MemoryPool(blockSize: size)
        }
    }

    deinit {
        cleanup()
    }

    private func cleanup() {
        // Extract all allocations first to avoid holding lock during deallocation
        let poolsToCleanup: [(Int, MemoryPool)]

        // Extract data under lock (avoid recursive lock issues)
        poolsToCleanup = lock.withLock {
            let pools = Array(self.pools)

            // Clear the collections
            self.pools.removeAll()
            self.largeAllocations.removeAll()

            return pools
        }

        // Now deallocate everything without holding the lock
        for (blockSize, pool) in poolsToCleanup {
            // Deallocate free blocks
            for block in pool.freeBlocks {
                block.deallocate()
            }

            // Deallocate allocated blocks 
            for block in pool.allocatedBlocks {
                let bufferToFree = UnsafeMutableRawBufferPointer(start: block, count: blockSize)
                bufferToFree.deallocate()
            }
        }

        // Note: We can't properly deallocate large allocations without knowing their sizes
        // This is a known limitation
    }

    // MARK: - Public Allocation Methods

    /// Temporarily allocates an aligned buffer, runs `body` synchronously,
    /// then automatically deallocates when done (Sendable-safe approach)
    public nonisolated func withAlignedBuffer<T>(
        byteCount: Int,
        alignment: Int = MIN_ALIGNMENT,
        _ body: (UnsafeMutableRawBufferPointer) throws -> T
    ) rethrows -> T {
        let buffer = allocateAligned(byteCount: byteCount, alignment: alignment)
        defer {
            deallocate(buffer)
        }
        return try body(buffer)
    }

    /// Allocate memory with specified byte count and alignment
    public nonisolated func allocateAligned(byteCount: Int, alignment: Int) -> UnsafeMutableRawBufferPointer {
        let alignedSize = roundUpToAlignment(byteCount, alignment: alignment)

        // Extract allocation info using primitive types to avoid capturing non-Sendable types
        let allocInfo: (pointerValue: UInt?, size: Int, fromPool: Bool) = lock.withLock {
            allocationCount += 1

            // Try to use a memory pool for small allocations
            if alignedSize <= Self.MAX_SMALL_ALLOCATION,
               let poolSize = findBestPoolSize(alignedSize),
               var pool = pools[poolSize],
               let buffer = pool.allocate() {

                pools[poolSize] = pool
                cacheHits += 1
                let pointerValue = buffer.baseAddress.map { UInt(bitPattern: $0) }
                return (pointerValue, buffer.count, true)
            }

            return (nil, 0, false)
        }

        // Handle allocation outside of lock to avoid Sendable issues
        let buffer: UnsafeMutableRawBufferPointer
        if let pointerValue = allocInfo.pointerValue,
           let poolPointer = UnsafeMutableRawPointer(bitPattern: pointerValue) {
            // Reconstruct buffer from primitive types
            buffer = UnsafeMutableRawBufferPointer(start: poolPointer, count: allocInfo.size)
        } else {
            // Allocate new memory
            buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: alignedSize,
                alignment: alignment
            )

            // Track the allocation under lock (extract pointer value to avoid capturing buffer)
            if let bufferAddress = buffer.baseAddress {
                let bufferAddressValue = UInt(bitPattern: bufferAddress)
                lock.withLock {
                    cacheMisses += 1

                    // Track large allocations separately (reconstruct pointer to avoid capture)
                    if let safeBufferAddress = UnsafeMutableRawPointer(bitPattern: bufferAddressValue) {
                        if alignedSize > Self.MAX_SMALL_ALLOCATION {
                            largeAllocations.insert(safeBufferAddress)
                        } else {
                            // Add new block to appropriate pool if not full
                            if let poolSize = findBestPoolSize(alignedSize),
                               var pool = pools[poolSize],
                               pool.freeBlocks.count < Self.MAX_POOL_SIZE {

                                pool.allocatedBlocks.insert(safeBufferAddress)
                                pools[poolSize] = pool
                            }
                        }
                    }

                    totalMemoryAllocated += alignedSize
                    peakMemoryUsage = max(peakMemoryUsage, totalMemoryAllocated)
                }
            }
        }

        // Zero out the allocated memory
        memset(buffer.baseAddress!, 0, alignedSize)

        return buffer
    }

    /// Simple allocate with default alignment
    public func allocate(byteCount: Int) -> UnsafeMutableRawBufferPointer {
        return allocateAligned(byteCount: byteCount, alignment: Self.MIN_ALIGNMENT)
    }

    /// Deallocate a previously allocated buffer
    public nonisolated func deallocate(_ buffer: UnsafeMutableRawBufferPointer) {
        guard let baseAddress = buffer.baseAddress else { return }

        // Extract buffer info to avoid capturing non-Sendable types
        let bufferCount = buffer.count
        let bufferAddressValue = UInt(bitPattern: baseAddress)

        let shouldDeallocate = lock.withLock { () -> Bool in
            deallocatedCount += 1

            // Try to return to appropriate pool
            for (blockSize, var pool) in pools {
                if bufferCount == blockSize,
                   let reconstructedAddress = UnsafeMutableRawPointer(bitPattern: bufferAddressValue) {
                    // We can't pass the buffer directly, so recreate it
                    let poolBuffer = UnsafeMutableRawBufferPointer(start: reconstructedAddress, count: bufferCount)
                    pool.deallocate(poolBuffer)
                    pools[blockSize] = pool
                    return false // Don't deallocate - returned to pool
                }
            }

            // Handle large allocation  
            if let reconstructedAddress = UnsafeMutableRawPointer(bitPattern: bufferAddressValue),
               largeAllocations.remove(reconstructedAddress) != nil {
                return true // Should deallocate
            } else {
                return true // If not found in tracking, still deallocate to prevent leaks
            }
        }

        if shouldDeallocate {
            buffer.deallocate()
        }
    }

    /// Reallocate buffer with new size, preserving existing data
    public func reallocate(
        _ buffer: UnsafeMutableRawBufferPointer,
        toByteCount newByteCount: Int,
        alignment: Int = MIN_ALIGNMENT
    ) -> UnsafeMutableRawBufferPointer {

        let newBuffer = allocateAligned(byteCount: newByteCount, alignment: alignment)

        // Copy existing data
        let copySize = min(buffer.count, newByteCount)
        if copySize > 0 {
            newBuffer.copyMemory(from: UnsafeRawBufferPointer(start: buffer.baseAddress, count: copySize))
        }

        // Deallocate old buffer
        deallocate(buffer)

        return newBuffer
    }

    /// Allocate temporary buffer for short-lived use
    public func allocateTemporary(byteCount: Int, alignment: Int = MIN_ALIGNMENT) -> UnsafeMutableRawBufferPointer {
        return allocateAligned(byteCount: byteCount, alignment: alignment)
    }

    // MARK: - Pool Management

    /// Warm up the allocator by pre-allocating common sizes
    public func warmUp() {
        lock.withLock {
            for (size, var pool) in pools {
                let preAllocCount = min(8, Self.MAX_POOL_SIZE - pool.freeBlocks.count)
                for _ in 0..<preAllocCount {
                    let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: size, alignment: Self.MIN_ALIGNMENT)
                    pool.freeBlocks.append(buffer)
                }
                pools[size] = pool
            }
        }
    }

    /// Trim unused memory from pools
    public func trimMemory() {
        lock.withLock {
            for (size, var pool) in pools {
                // Keep only half of the free blocks
                let targetCount = pool.freeBlocks.count / 2
                while pool.freeBlocks.count > targetCount {
                    let buffer = pool.freeBlocks.removeLast()
                    buffer.deallocate()
                }
                pools[size] = pool
            }
        }
    }

    /// Reset all pools and deallocate memory (for testing)
    public func reset() {
        cleanup()
        lock.withLock {
            pools.removeAll()
            largeAllocations.removeAll()
            allocationCount = 0
            deallocatedCount = 0
            cacheHits = 0
            cacheMisses = 0
            totalMemoryAllocated = 0
            peakMemoryUsage = 0

            // Re-initialize pools
            for size in Self.POOL_SIZES {
                pools[size] = MemoryPool(blockSize: size)
            }
        }
    }

    // MARK: - Utility Methods

    private func findBestPoolSize(_ requestedSize: Int) -> Int? {
        for poolSize in Self.POOL_SIZES {
            if requestedSize <= poolSize {
                return poolSize
            }
        }
        return nil
    }

    private func roundUpToAlignment(_ size: Int, alignment: Int) -> Int {
        return (size + alignment - 1) & ~(alignment - 1)
    }

    public func getAllocationMetrics() -> AllocationMetrics {
        return lock.withLock {
            var poolUtilization: [Int: Double] = [:]

            for (size, pool) in pools {
                let total = pool.freeBlocks.count + pool.allocatedBlocks.count
                if total > 0 {
                    poolUtilization[size] = Double(pool.allocatedBlocks.count) / Double(total) * 100.0
                } else {
                    poolUtilization[size] = 0.0
                }
            }

            let efficiency = allocationCount > 0 ? Double(deallocatedCount) / Double(allocationCount) : 0.0
            let hitRate = (cacheHits + cacheMisses) > 0 ? Double(cacheHits) / Double(cacheHits + cacheMisses) : 0.0
            let avgSize = allocationCount > 0 ? Double(totalMemoryAllocated) / Double(allocationCount) : 0.0

            return AllocationMetrics(
                totalAllocations: allocationCount,
                totalDeallocations: deallocatedCount,
                cacheHits: cacheHits,
                cacheMisses: cacheMisses,
                totalMemoryAllocated: totalMemoryAllocated,
                poolUtilization: poolUtilization,
                memoryEfficiency: efficiency,
                cacheHitRate: hitRate,
                averageAllocationSize: avgSize,
                peakMemoryUsage: peakMemoryUsage
            )
        }
    }

    /// Validate that a pointer was allocated by this allocator
    public nonisolated func validatePointer(_ pointer: UnsafeMutableRawPointer) -> Bool {
        let pointerValue = UInt(bitPattern: pointer)
        return lock.withLock {
            guard let reconstructedPointer = UnsafeMutableRawPointer(bitPattern: pointerValue) else {
                return false
            }

            // Check in pools
            for (_, pool) in pools {
                if pool.allocatedBlocks.contains(reconstructedPointer) {
                    return true
                }
            }

            // Check in large allocations
            return largeAllocations.contains(reconstructedPointer)
        }
    }

    /// Get the allocated size for a pointer (if known)
    public nonisolated func getAllocatedSize(_ pointer: UnsafeMutableRawPointer) -> Int? {
        let pointerValue = UInt(bitPattern: pointer)
        return lock.withLock {
            guard let reconstructedPointer = UnsafeMutableRawPointer(bitPattern: pointerValue) else {
                return nil
            }

            // Check in pools
            for (size, pool) in pools {
                if pool.allocatedBlocks.contains(reconstructedPointer) {
                    return size
                }
            }

            // Large allocations - we don't track their sizes currently
            if largeAllocations.contains(reconstructedPointer) {
                return nil // Size unknown for large allocations
            }

            return nil
        }
    }

    /// Print allocation statistics for debugging
    public func printStatistics() {
        let metrics = getAllocationMetrics()
        print("=== BCS Allocator Statistics ===")
        print("Total Allocations: \(metrics.totalAllocations)")
        print("Total Deallocations: \(metrics.totalDeallocations)")
        print("Cache Hit Rate: \(String(format: "%.2f", metrics.cacheHitRate * 100))%")
        print("Memory Efficiency: \(String(format: "%.2f", metrics.memoryEfficiency * 100))%")
        print("Average Allocation Size: \(String(format: "%.2f", metrics.averageAllocationSize)) bytes")
        print("Peak Memory Usage: \(metrics.peakMemoryUsage) bytes")
        print("Pool Utilization:")
        for (size, utilization) in metrics.poolUtilization.sorted(by: { $0.key < $1.key }) {
            print("  \(size) bytes: \(String(format: "%.2f", utilization))%")
        }
    }
}

// MARK: - Swift 6 Sendable Conformance

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension BCSAllocator: @unchecked Sendable {
    // Safe because all mutable state is protected by the lock
}

// MARK: - Memory Pool Statistics
// Statistics are computed within the class methods to avoid access control issues 
