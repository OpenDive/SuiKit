# GraphQL Object Mapping & Integration Plan

This document tracks the mapping of generated GraphQL objects (`graphqlSchemaSuiKit`) to the public API objects (`SuiKit`) and outlines the strategy for adapter implementation.

## Overview

To maintain a stable public API while leveraging the generated GraphQL code, we will implement the **Adapter Pattern**. The generated `graphqlSchemaSuiKit` package will be an internal dependency. Public types in `SuiKit` will remain unchanged but will be extended with initializers or static mapping functions that take the generated GraphQL types as input.

## Object Mapping

### Enums

| Public Type (SuiKit) | Generated Type (graphqlSchemaSuiKit) | Location (SuiKit) | Status |
| :--- | :--- | :--- | :--- |
| `SuiMoveVisibility` | `MoveVisibility` | `Sources/SuiKit/Types/Enums/Sui/Normalized/SuiMoveVisibility.swift` | Pending |
| `ObjectValueKind` | `MoveFunctionArgType` (partial match) | `Sources/SuiKit/Types/Enums/Provider/Responses/ObjectValueKind.swift` | Pending |
| `SuiMoveFunctionArgType` | `MoveFunctionArgType` | `Sources/SuiKit/Types/Enums/Provider/Responses/SuiMoveFunctionArgType.swift` | Pending |

### Structs

| Public Type (SuiKit) | Generated Type (graphqlSchemaSuiKit) | Location (SuiKit) | Status |
| :--- | :--- | :--- | :--- |
| `Checkpoint` | `Checkpoint` | `Sources/SuiKit/Types/Structs/Checkpoints/Checkpoint.swift` | Pending |
| `SuiMoveNormalizedModule` | `MoveModule` | `Sources/SuiKit/Types/Structs/Normalized/SuiMoveNormalizedModule.swift` | Pending |
| `SuiMoveNormalizedFunction` | `MoveFunction` | `Sources/SuiKit/Types/Structs/Normalized/SuiMoveNormalizedFunction.swift` | Pending |
| `SuiMoveNormalizedStruct` | `MoveStruct` | `Sources/SuiKit/Types/Structs/Normalized/SuiMoveNormalizedStruct.swift` | Pending |
| `CoinBalance` | `Balance` | `Sources/SuiKit/Types/Structs/Coin/CoinBalance.swift` | Pending |
| `CoinStruct` | `Coin` | `Sources/SuiKit/Types/Structs/Coin/CoinStruct.swift` | Pending |
| `SuiEvent` | `Event` | `Sources/SuiKit/Types/Structs/Faucet/Event/SuiEvent.swift` | Pending |
| `ValidatorApys` | `ValidatorApy` (list) | `Sources/SuiKit/Types/Structs/Provider/Responses/ValidatorApys.swift` | Pending |

## Integration Strategy

### 1. Imports
Files in `SuiKit` that need to convert GraphQL types will import the generated module:
```swift
import graphqlSchemaSuiKit
```

### 2. Extension Pattern
For each mapped type, we will add an extension in its respective file (or a dedicated `Adapters/` directory if prefered) to handle the conversion.

**Example: `SuiMoveVisibility`**

```swift
// In Sources/SuiKit/Types/Enums/Sui/Normalized/SuiMoveVisibility.swift

extension SuiMoveVisibility {
    init?(graphql: graphqlSchemaSuiKit.MoveVisibility) {
        switch graphql {
        case .private: self = .Private
        case .public: self = .Public
        case .friend: self = .Friend
        default: return nil // Handle unknown or internal cases
        }
    }
}
```

**Example: `Checkpoint`**

```swift
// In Sources/SuiKit/Types/Structs/Checkpoints/Checkpoint.swift

extension Checkpoint {
    init(graphql: graphqlSchemaSuiKit.Checkpoint) {
        self.epoch = String(graphql.epoch?.sequenceNumber ?? 0)
        self.sequenceNumber = String(graphql.sequenceNumber)
        self.digest = graphql.digest
        self.networkTotalTransactions = String(graphql.networkTotalTransactions ?? 0)
        self.previousDigest = graphql.previousCheckpointDigest
        self.epochRollingGasCostSummary = GasCostSummary(graphql: graphql.rollingGasSummary)
        self.timestampMs = String(Int(graphql.timestamp?.timeIntervalSince1970 ?? 0) * 1000)
        // ... map other fields
    }
}
```

## Next Steps

1.  **Verify Generated Output:** Ensure `graphqlSchemaSuiKit` is correctly generated and available.
2.  **Implement Adapters:**Systematically go through the "Pending" items in the mapping table and implement the `init(graphql:)` extensions.
3.  **Update `SuiProvider`:** Modify `GraphQLSuiProvider` (if reintroduced) or `SuiProvider` to use the GraphQL client to fetch data, convert it using the adapters, and return the public types.

