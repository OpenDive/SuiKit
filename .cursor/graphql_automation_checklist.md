# GraphQL Schema Automation Checklist

## Phase 1: Scripting
- [x] **Create Update Script**
  - [x] Create `scripts/update-graphql-schema.sh`.
  - [x] Implement logic to fetch the latest `schema.graphql` from `MystenLabs/sui` (main branch).
  - [x] Add command to run `apollo-ios-cli generate` using the project's configuration.
  - [x] Ensure the script is executable.

## Phase 2: Package Integration & Conflict Resolution
- [ ] **Move Generated Package**
  - [ ] Update `scripts/update-graphql-schema.sh` to move the generated `graphqlSchemaSuiKit` package to `Sources/graphqlSchemaSuiKit` (or similar persistent location).
  - [ ] Ensure `Package.swift` includes `graphqlSchemaSuiKit` as a separate target and dependency for `SuiKit`.
- [ ] **Resolve Type Conflicts (Adapter Pattern)**
  - [ ] **Strategy:** Keep existing public types (e.g., `SuiMoveVisibility`) as the "public API" and create adapters/extensions to initialize them from GraphQL generated types.
  - [ ] **Implementation:** Create extensions on existing types (e.g., `extension SuiMoveVisibility { init(graphql: graphqlSchemaSuiKit.MoveVisibility) { ... } }`).
  - [ ] **Automation:** Ensure the update script allows for this integration without overwriting the adapter logic (since adapters will live in `SuiKit` target, not the generated one).

## Phase 3: GitHub Action
- [ ] **Create Workflow File**
  - [ ] Create `.github/workflows/update-graphql.yml`.
  - [ ] Configure triggers: `schedule` (cron: '0 0 1 * *' for monthly) and `workflow_dispatch`.
  - [ ] Define job steps:
    - [ ] Checkout repository.
    - [ ] Run `scripts/update-graphql-schema.sh`.
    - [ ] Check for file changes.
    - [ ] Create Pull Request using `peter-evans/create-pull-request` if changes are detected.

## Phase 4: Testing & Documentation
- [ ] **Verify Script**
  - [ ] Run the script locally to ensure it downloads and generates code correctly without errors.
- [ ] **Document Process**
  - [ ] Add a note in `CONTRIBUTING.md` or `README.md` about the automated GraphQL update process.
