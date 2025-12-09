#!/bin/bash

# Define variables
SCHEMA_URL="https://raw.githubusercontent.com/MystenLabs/sui/refs/heads/main/crates/sui-indexer-alt-graphql/schema.graphql"
OUTPUT_FILE="schema.graphqls"

echo "🚀 Starting GraphQL schema update..."

# Step 1: Fetch the latest schema
echo "⬇️  Fetching latest schema from ${SCHEMA_URL}..."
curl -s -L -o "${OUTPUT_FILE}" "${SCHEMA_URL}"

if [ $? -ne 0 ]; then
    echo "❌ Failed to download schema."
    exit 1
fi

echo "✅ Schema downloaded to ${OUTPUT_FILE}"

# Step 2: Ensure Apollo iOS CLI is present
if [ ! -f "./apollo-ios-cli" ]; then
    echo "⚠️  Apollo iOS CLI not found. Downloading latest release..."
    curl -LO https://github.com/apollographql/apollo-ios/releases/latest/download/apollo-ios-cli.tar.gz
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to download Apollo iOS CLI."
        exit 1
    fi
    
    tar -xzf apollo-ios-cli.tar.gz
    chmod +x apollo-ios-cli
    rm apollo-ios-cli.tar.gz
fi

# Step 3: Run Apollo iOS CLI to generate code
if [ -f "./apollo-ios-cli" ]; then
    echo "⚙️  Generating Swift code using Apollo iOS CLI..."
    ./apollo-ios-cli generate
    
    if [ $? -eq 0 ]; then
        echo "✅ Code generation completed successfully."

        # Move generated package to Sources
        echo "📦 Moving generated package to Sources/GraphqlSchemaSuiKit..."
        rm -rf "../../Sources/GraphqlSchemaSuiKit"
        rm -rf "./GraphqlSchemaSuiKit/Package.swift"
        mkdir -p "../../Sources/GraphqlSchemaSuiKit"
        mv ./GraphqlSchemaSuiKit/Sources/{Fragments,Operations,Schema} ../../Sources/GraphqlSchemaSuiKit
        rm -rf "./GraphqlSchemaSuiKit"

        echo "✅ Package moved successfully."
    else
        echo "❌ Code generation failed."
        exit 1
    fi
else
    echo "❌ Failed to find Apollo iOS CLI."
    exit 1
fi

echo "🎉 GraphQL update process finished."
