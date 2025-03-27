#!/bin/zsh

url="https://overview.jamfcloud.com"

echo ""
echo "📘 This script checks the required privileges for a specific Jamf Pro API endpoint."
echo "👉 Type the full path of the endpoint (e.g., /v1/computers-inventory)"
echo "💡 Or type 'list' to view all available endpoints"
echo "✅ Type 'done' when you're finished"
echo ""

# Fetch schema once and reuse
SCHEMA=$(curl -s "$url/api/schema")

while true; do
    echo -n "🔎 What would you like to do? (enter endpoint, 'list', or 'done'): "
    read INPUT

    # Handle exit
    if [[ "$INPUT" == "done" ]]; then
        echo "👋 Goodbye!"
        break
    fi

    # Handle list
    if [[ "$INPUT" == "list" ]]; then
        echo ""
        echo "📄 Available API Endpoints:"
        echo "$SCHEMA" | jq -r '.paths | keys[]' | sort
        echo ""
        continue
    fi

    # Otherwise treat as endpoint
    ENDPOINT="$INPUT"
    echo "📡 Checking required privileges for: $ENDPOINT"

    REQUIRED_PRIVS=$(echo "$SCHEMA" | jq -r --arg endpoint "$ENDPOINT" '
      .paths[$endpoint]
      | to_entries[]
      | select(.value."x-required-privileges" != null)
      | {method: .key, privileges: .value."x-required-privileges"}
    ')

    echo ""
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
done
