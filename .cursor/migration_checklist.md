# Swift 6.x Concurrency Migration Checklist

## Phase 1: Core Concurrency Types (Proof of Concept)
- [ ] **Create `SuiJSON` Enum**
  - [ ] Define `SuiJSON` enum with cases for `string`, `number`, `bool`, `object`, `array`, `null`.
  - [ ] Ensure conformances: `Codable`, `Sendable`, `Hashable`.
  - [ ] Add convenience initializers (`ExpressibleByStringLiteral`, etc.).
- [ ] **Create `SuiRequestS6C` Struct**
  - [ ] Duplicate `SuiRequest` structure but use `[SuiJSON]` for `params`.
  - [ ] Ensure it is explicitly `Sendable`.
- [ ] **Proof of Concept Implementation**
  - [ ] Implement `getNormalizedMoveModulesByPackageS6C` in `SuiProvider`.
  - [ ] Update `JsonRpcClient` to handle `SuiRequestS6C` (overload existing methods or create `sendSuiJsonRpcS6C`).
  - [ ] Verify basic functionality and thread safety.

## Phase 2: Protocol Migration
- [ ] **Update Core Protocols**
  - [ ] `EncodingProtocol`: Inherit `Sendable`.
  - [ ] `KeyProtocol`: Inherit `Sendable`.
  - [ ] `PublicKeyProtocol`: Inherit `Sendable`.
  - [ ] `PrivateKeyProtocol`: Inherit `Sendable`.
  - [ ] `ConnectionProtocol`: Inherit `Sendable`.

## Phase 3: Mutable State Refactoring
- [ ] **Refactor `Wallet` Class**
  - [ ] Decide: Convert to `struct` OR `actor`.
  - [ ] Implement change ensuring thread-safe access to `mnemonic` and `accounts`.

## Phase 4: Full Codebase Migration
- [ ] **Replace `AnyCodable` Usage**
  - [ ] Scan all 15 files using `@preconcurrency import AnyCodable`.
  - [ ] Replace `AnyCodable` with `SuiJSON` in parameter mapping.
  - [ ] Remove `@preconcurrency import AnyCodable`.
- [ ] **Update `SuiProvider`**
  - [ ] Deprecate/Remove `S6C` suffix methods.
  - [ ] Update all RPC methods to use the new `SuiRequest` (renamed from `SuiRequestS6C`).
- [ ] **Update `JsonRpcClient`**
  - [ ] Switch completely to strict `Sendable` request types.

## Phase 5: Cleanup & Verification
- [ ] **Remove Dependencies**
  - [ ] Remove `AnyCodable` from `Package.swift`.
- [ ] **Testing**
  - [ ] Run full test suite with Strict Concurrency Checking enabled (`-warn-concurrency` / Swift 6 mode).
  - [ ] Validate no data races in `Wallet` usage.