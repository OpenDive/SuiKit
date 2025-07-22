//
//  StreamingBCS.swift
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
import UniformTypeIdentifiers
import OSLog

/// Streaming BCS serialization and deserialization for large datasets
/// Supports memory-mapped files, chunked processing, and backpressure handling
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public actor StreamingBCS {

    // MARK: - Constants
    public static let DEFAULT_CHUNK_SIZE = 64 * 1024 // 64KB chunks
    private static let MAX_CHUNK_SIZE = 1024 * 1024 // 1MB max chunk
    private static let MIN_CHUNK_SIZE = 4096 // 4KB min chunk
    private static let MEMORY_MAP_THRESHOLD = 10 * 1024 * 1024 // 10MB threshold for memory mapping
    private static let BACKPRESSURE_THRESHOLD = 100 // Max pending chunks

    // MARK: - Types

    public enum StreamingError: Error, LocalizedError {
        case invalidChunkSize(Int)
        case memoryMappingFailed(String)
        case backpressureExceeded(Int)
        case streamClosed
        case invalidOffset(Int)
        case corruptedChunk
        case exceededMaxSize(Int)

        public var errorDescription: String? {
            switch self {
            case .invalidChunkSize(let size):
                return "Invalid chunk size: \(size). Must be between \(MIN_CHUNK_SIZE) and \(MAX_CHUNK_SIZE)"
            case .memoryMappingFailed(let reason):
                return "Memory mapping failed: \(reason)"
            case .backpressureExceeded(let count):
                return "Backpressure exceeded with \(count) pending chunks"
            case .streamClosed:
                return "Stream has been closed"
            case .invalidOffset(let offset):
                return "Invalid stream offset: \(offset)"
            case .corruptedChunk:
                return "Chunk data is corrupted"
            case .exceededMaxSize(let size):
                return "Data size \(size) exceeds maximum allowed"
            }
        }
    }

    public struct StreamingOptions {
        public let chunkSize: Int
        public let enableMemoryMapping: Bool
        public let maxMemoryUsage: Int
        public let enableCompression: Bool
        public let enableBackpressure: Bool
        public let maxConcurrentChunks: Int

        public init(
            chunkSize: Int = DEFAULT_CHUNK_SIZE,
            enableMemoryMapping: Bool = true,
            maxMemoryUsage: Int = 100 * 1024 * 1024, // 100MB
            enableCompression: Bool = false,
            enableBackpressure: Bool = true,
            maxConcurrentChunks: Int = 10
        ) {
            self.chunkSize = chunkSize
            self.enableMemoryMapping = enableMemoryMapping
            self.maxMemoryUsage = maxMemoryUsage
            self.enableCompression = enableCompression
            self.enableBackpressure = enableBackpressure
            self.maxConcurrentChunks = maxConcurrentChunks
        }

        public static let `default` = StreamingOptions()

        public static let highThroughput = StreamingOptions(
            chunkSize: MAX_CHUNK_SIZE,
            enableMemoryMapping: true,
            maxMemoryUsage: 500 * 1024 * 1024, // 500MB
            enableBackpressure: false,
            maxConcurrentChunks: 20
        )

        public static let lowMemory = StreamingOptions(
            chunkSize: MIN_CHUNK_SIZE,
            enableMemoryMapping: false,
            maxMemoryUsage: 50 * 1024 * 1024, // 50MB
            enableBackpressure: true,
            maxConcurrentChunks: 5
        )
    }

    public struct ChunkMetadata: Sendable {
        public let index: Int
        public let offset: Int
        public let size: Int
        public let checksum: UInt32
        public let isCompressed: Bool

        init(index: Int, offset: Int, size: Int, checksum: UInt32, isCompressed: Bool = false) {
            self.index = index
            self.offset = offset
            self.size = size
            self.checksum = checksum
            self.isCompressed = isCompressed
        }
    }

    // MARK: - Properties
    private let options: StreamingOptions
    private let allocator: BCSAllocator
    private let logger = Logger(subsystem: "com.opendive.suikit", category: "StreamingBCS")

    // Stream state
    private var isOpen = true
    private var totalBytesProcessed: Int = 0
    private var currentChunkIndex: Int = 0
    private var pendingChunks: [ChunkMetadata] = []

    // Performance tracking
    private var chunksProcessed: Int = 0
    private var memoryMapHits: Int = 0
    private var compressionSavings: Int = 0

    // MARK: - Initialization

    public init(options: StreamingOptions = .default, allocator: BCSAllocator = BCSAllocator.shared) throws {
        guard options.chunkSize >= Self.MIN_CHUNK_SIZE && options.chunkSize <= Self.MAX_CHUNK_SIZE else {
            throw StreamingError.invalidChunkSize(options.chunkSize)
        }

        self.options = options
        self.allocator = allocator
    }

    // MARK: - Streaming Serialization

    /// Stream serialize data to a file with chunked processing
    public func serializeToFile<T: Sequence>(
        _ sequence: T,
        to url: URL,
        valueEncoder: @escaping (Serializer, T.Element) throws -> Void
    ) async throws {
        guard isOpen else { throw StreamingError.streamClosed }

        let fileManager = FileManager.default

        // Create or truncate the output file
        if !fileManager.createFile(atPath: url.path, contents: nil, attributes: nil) {
            throw StreamingError.memoryMappingFailed("Failed to create output file")
        }

        let fileHandle = try FileHandle(forWritingTo: url)
        defer {
            try? fileHandle.close()
        }

        let chunkSerializer = Serializer(allocator: allocator)
        var elementsInChunk = 0
        var totalElements = 0

        // Write sequence length placeholder (we'll update this at the end)
        fileHandle.write(Data([0xFF, 0xFF, 0xFF, 0xFF])) // 4-byte placeholder

        for element in sequence {
            // Check if we need to start a new chunk
            if chunkSerializer.output().count >= options.chunkSize && elementsInChunk > 0 {
                try await writeChunk(chunkSerializer.output(), to: fileHandle, index: currentChunkIndex)
                chunkSerializer.reset()
                currentChunkIndex += 1
                elementsInChunk = 0

                // Apply backpressure if needed
                if options.enableBackpressure && pendingChunks.count > Self.BACKPRESSURE_THRESHOLD {
                    try await Task.sleep(nanoseconds: 1_000_000) // 1ms delay
                }
            }

            try valueEncoder(chunkSerializer, element)
            elementsInChunk += 1
            totalElements += 1

            // Cooperative cancellation
            try Task.checkCancellation()
        }

        // Write final chunk if it has data
        if elementsInChunk > 0 {
            try await writeChunk(chunkSerializer.output(), to: fileHandle, index: currentChunkIndex)
        }

        // Update the sequence length at the beginning of the file
        try fileHandle.seek(toOffset: 0)
        let lengthData = withUnsafeBytes(of: UInt32(totalElements).littleEndian) { Data($0) }
        fileHandle.write(lengthData)

        totalBytesProcessed += Int(fileHandle.offsetInFile)
        logger.info("Serialized \(totalElements) elements in \(self.currentChunkIndex + 1) chunks to \(url.path)")
    }

    /// Stream serialize using AsyncSequence
    public func serializeSequence<T: AsyncSequence>(
        _ asyncSequence: T,
        to url: URL,
        valueEncoder: @escaping (Serializer, T.Element) throws -> Void
    ) async throws {
        guard isOpen else { throw StreamingError.streamClosed }

        let fileHandle = try FileHandle(forWritingTo: url)
        defer {
            try? fileHandle.close()
        }

        let chunkSerializer = Serializer(allocator: allocator)
        var elementsInChunk = 0
        var totalElements = 0

        // Write sequence length placeholder
        fileHandle.write(Data([0xFF, 0xFF, 0xFF, 0xFF]))

        for try await element in asyncSequence {
            if chunkSerializer.output().count >= options.chunkSize && elementsInChunk > 0 {
                try await writeChunk(chunkSerializer.output(), to: fileHandle, index: currentChunkIndex)
                chunkSerializer.reset()
                currentChunkIndex += 1
                elementsInChunk = 0
            }

            try valueEncoder(chunkSerializer, element)
            elementsInChunk += 1
            totalElements += 1

            try Task.checkCancellation()
        }

        // Write final chunk
        if elementsInChunk > 0 {
            try await writeChunk(chunkSerializer.output(), to: fileHandle, index: currentChunkIndex)
        }

        // Update sequence length
        try fileHandle.seek(toOffset: 0)
        let lengthData = withUnsafeBytes(of: UInt32(totalElements).littleEndian) { Data($0) }
        fileHandle.write(lengthData)
    }

    private func writeChunk(_ data: Data, to fileHandle: FileHandle, index: Int) async throws {
        var finalData = data

        // Apply compression if enabled
        if options.enableCompression {
            finalData = try await compressData(data)
            compressionSavings += data.count - finalData.count
        }

        // Calculate checksum
        let checksum = crc32(finalData)

        // Write chunk header: [size: 4 bytes][checksum: 4 bytes][isCompressed: 1 byte]
        let header = withUnsafeBytes(of: UInt32(finalData.count).littleEndian) { Data($0) } +
                    withUnsafeBytes(of: checksum.littleEndian) { Data($0) } +
                    Data([options.enableCompression ? 1 : 0])

        fileHandle.write(header)
        fileHandle.write(finalData)

        let metadata = ChunkMetadata(
            index: index,
            offset: Int(fileHandle.offsetInFile) - finalData.count - header.count,
            size: finalData.count,
            checksum: checksum,
            isCompressed: options.enableCompression
        )

        pendingChunks.append(metadata)
        chunksProcessed += 1
    }

    // MARK: - Streaming Deserialization

    /// Stream deserialize from a file with memory mapping support
    public func deserializeFromFile<T>(
        _ url: URL,
        as type: T.Type,
        valueDecoder: @escaping (Deserializer) throws -> T
    ) async throws -> AsyncThrowingStream<T, Error> {
        guard isOpen else { throw StreamingError.streamClosed }

        let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? 0

        // Use memory mapping for large files
        if options.enableMemoryMapping && fileSize >= Self.MEMORY_MAP_THRESHOLD {
            return try await deserializeMemoryMapped(url, as: type, valueDecoder: valueDecoder)
        } else {
            return try await deserializeBuffered(url, as: type, valueDecoder: valueDecoder)
        }
    }

    private func deserializeMemoryMapped<T>(
        _ url: URL,
        as type: T.Type,
        valueDecoder: @escaping (Deserializer) throws -> T
    ) async throws -> AsyncThrowingStream<T, Error> {
        memoryMapHits += 1

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    let deserializer = Deserializer(data: data, allocator: allocator)

                    // Read sequence length
                    let sequenceLength = try deserializer.uleb128()

                    for _ in 0..<sequenceLength {
                        let element = try valueDecoder(deserializer)
                        continuation.yield(element)

                        // Cooperative cancellation
                        try Task.checkCancellation()
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func deserializeBuffered<T>(
        _ url: URL,
        as type: T.Type,
        valueDecoder: @escaping (Deserializer) throws -> T
    ) async throws -> AsyncThrowingStream<T, Error> {

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let fileHandle = try FileHandle(forReadingFrom: url)
                    defer { try? fileHandle.close() }

                    // Read sequence length
                    let lengthData = try fileHandle.read(upToCount: 4) ?? Data()
                    guard lengthData.count == 4 else {
                        throw StreamingError.corruptedChunk
                    }

                    let sequenceLength = lengthData.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
                    var processedElements = 0

                    while processedElements < sequenceLength {
                        // Read chunk header
                        guard let headerData = try fileHandle.read(upToCount: 9),
                              headerData.count == 9 else {
                            throw StreamingError.corruptedChunk
                        }

                        let chunkSize = headerData.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
                        let expectedChecksum = headerData.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self).littleEndian }
                        let isCompressed = headerData[8] == 1

                        // Read chunk data
                        guard let chunkData = try fileHandle.read(upToCount: Int(chunkSize)),
                              chunkData.count == Int(chunkSize) else {
                            throw StreamingError.corruptedChunk
                        }

                        // Verify checksum
                        let actualChecksum = crc32(chunkData)
                        guard actualChecksum == expectedChecksum else {
                            throw StreamingError.corruptedChunk
                        }

                        // Decompress if needed
                        var finalData = chunkData
                        if isCompressed {
                            finalData = try await decompressData(chunkData)
                        }

                        // Deserialize chunk
                        let chunkDeserializer = Deserializer(data: finalData, allocator: allocator)

                        while !chunkDeserializer.isComplete() && processedElements < sequenceLength {
                            let element = try valueDecoder(chunkDeserializer)
                            continuation.yield(element)
                            processedElements += 1

                            try Task.checkCancellation()
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Batch Processing

    /// Process data in batches for better memory efficiency
    public func processBatches<T, U>(
        from sequence: [T],
        batchSize: Int? = nil,
        transform: @escaping ([T]) async throws -> [U]
    ) async throws -> AsyncThrowingStream<[U], Error> {
        let effectiveBatchSize = batchSize ?? (options.chunkSize / MemoryLayout<T>.size)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var currentBatch: [T] = []
                    currentBatch.reserveCapacity(effectiveBatchSize)

                    for element in sequence {
                        currentBatch.append(element)

                        if currentBatch.count >= effectiveBatchSize {
                            let transformedBatch = try await transform(currentBatch)
                            continuation.yield(transformedBatch)
                            currentBatch.removeAll(keepingCapacity: true)

                            // Apply backpressure
                            if options.enableBackpressure {
                                try await Task.sleep(nanoseconds: 100_000) // 0.1ms
                            }
                        }

                        try Task.checkCancellation()
                    }

                    // Process final batch if needed
                    if !currentBatch.isEmpty {
                        let transformedBatch = try await transform(currentBatch)
                        continuation.yield(transformedBatch)
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Utility Functions

    private func compressData(_ data: Data) async throws -> Data {
        // Simple compression using Foundation's compression
        return try (data as NSData).compressed(using: .lzfse) as Data
    }

    private func decompressData(_ data: Data) async throws -> Data {
        return try (data as NSData).decompressed(using: .lzfse) as Data
    }

    private func crc32(_ data: Data) -> UInt32 {
        return data.withUnsafeBytes { bytes in
            var crc: UInt32 = 0xFFFFFFFF
            for byte in bytes {
                crc = crc32Table[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
            }
            return crc ^ 0xFFFFFFFF
        }
    }

    // MARK: - Performance Monitoring

    public struct StreamingMetrics {
        public let totalBytesProcessed: Int
        public let chunksProcessed: Int
        public let memoryMapHits: Int
        public let compressionSavings: Int
        public let currentChunkIndex: Int
        public let pendingChunks: Int

        public var averageChunkSize: Double {
            return chunksProcessed > 0 ? Double(totalBytesProcessed) / Double(chunksProcessed) : 0.0
        }

        public var compressionRatio: Double {
            return totalBytesProcessed > 0 ? Double(compressionSavings) / Double(totalBytesProcessed) : 0.0
        }
    }

    public func getMetrics() -> StreamingMetrics {
        return StreamingMetrics(
            totalBytesProcessed: totalBytesProcessed,
            chunksProcessed: chunksProcessed,
            memoryMapHits: memoryMapHits,
            compressionSavings: compressionSavings,
            currentChunkIndex: currentChunkIndex,
            pendingChunks: pendingChunks.count
        )
    }

    // MARK: - Stream Management

    public func close() {
        isOpen = false
        pendingChunks.removeAll()
        logger.info("Streaming BCS closed. Processed \(self.chunksProcessed) chunks, \(self.totalBytesProcessed) bytes")
    }

    public func reset() {
        totalBytesProcessed = 0
        currentChunkIndex = 0
        chunksProcessed = 0
        memoryMapHits = 0
        compressionSavings = 0
        pendingChunks.removeAll()
        isOpen = true
    }

    // MARK: - File Utilities

    /// Create a temporary file for streaming operations
    public static func createTemporaryFile(prefix: String = "streaming_bcs") -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(prefix)_\(UUID().uuidString).bcs"
        return tempDir.appendingPathComponent(fileName)
    }

    /// Clean up temporary files
    public static func cleanupTemporaryFiles(prefix: String = "streaming_bcs") throws {
        let tempDir = FileManager.default.temporaryDirectory
        let contents = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)

        for url in contents {
            if url.lastPathComponent.hasPrefix(prefix) && url.pathExtension == "bcs" {
                try FileManager.default.removeItem(at: url)
            }
        }
    }
}

// MARK: - CRC32 Table

private let crc32Table: [UInt32] = {
    var table: [UInt32] = Array(repeating: 0, count: 256)
    for i in 0..<256 {
        var c = UInt32(i)
        for _ in 0..<8 {
            c = (c & 1) == 1 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1)
        }
        table[i] = c
    }
    return table
}()

// MARK: - Sendable Conformance

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension StreamingBCS.ChunkMetadata: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(offset)
    }

    public static func == (lhs: StreamingBCS.ChunkMetadata, rhs: StreamingBCS.ChunkMetadata) -> Bool {
        return lhs.index == rhs.index && lhs.offset == rhs.offset
    }
}
