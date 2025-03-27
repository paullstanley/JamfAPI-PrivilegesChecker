#!/bin/bash

# Currently it uses Bearer Token Authentication using Basic Authentication. It is required that Basic Authentication be enabled in the Password Policy setting of the Jamf User being used.

# ========== USER CONFIGURABLE ==========
url="https://<YOUR INSTANCE NAME HERE>.jamfcloud.com"
# =======================================

echo ""
echo "📘 This script checks the required privileges for a specific Jamf Pro API endpoint."
echo "👉 You only need to provide the full path of the endpoint (e.g., /v1/computers-inventory)."
echo ""

# Prompt for endpoint input
read -p "🔎 Enter the full API endpoint path you'd like to check: " ENDPOINT

# Fetch the OpenAPI schema
echo "📡 Fetching schema from: $url/api/schema"
SCHEMA=$(curl "$url/api/schema")

# Extract required privileges
REQUIRED_PRIVS=$(echo "$SCHEMA" | jq -r --arg endpoint "$ENDPOINT" '
  .paths[$endpoint]
  | to_entries[]
  | select(.value."x-required-privileges" != null)
  | {method: .key, privileges: .value."x-required-privileges"}
')

echo ""
# Display results
if [[ -z "$REQUIRED_PRIVS" ]]; then
    echo "⚠️  No required privileges found for endpoint: $ENDPOINT"
else
    echo "🔐 Required Privileges for $ENDPOINT:"
    echo "$REQUIRED_PRIVS" | jq -c '.' | while read -r entry; do
        method=$(echo "$entry" | jq -r '.method' | tr '[:lower:]' '[:upper:]')
        echo "  📘 Method: $method"
        echo "$entry" | jq -r '.privileges[]' | while read -r priv; do
            echo "    • $priv"
        done
    done
fi
echo ""
