#!/bin/zsh

url="https://overview.jamfcloud.com"
schemaDir="$HOME/Documents/api_schema"
schemaFile="$schemaDir/schema.json"

# Create schema directory if it doesn't exist
mkdir -p "$schemaDir"

# Function to download latest schema
download_schema() {
    echo "🌐 Downloading latest API schema..."
    curl -s "$url/api/schema" -o "$schemaFile"
    echo "✅ Schema saved to $schemaFile"
}

# Download schema if it doesn't exist
if [[ ! -f "$schemaFile" ]]; then
    download_schema
else
    echo "📁 Local schema found at $schemaFile"
fi

# Load schema into variable
SCHEMA=$(cat "$schemaFile")

# Help Menu
show_help() {
    echo ""
    echo "🆘 Available Commands:"
    echo "  🔎 [endpoint path]            → Check required privileges for a specific endpoint (e.g. /v1/computers-inventory)"
    echo "  📄 list or -l                 → Show all API endpoints"
    echo "  💻 list computers or -lc      → Show only computer-related endpoints"
    echo "  📱 list mobile or -lm         → Show only mobile device-related endpoints"
    echo "  🔁 refresh or -r              → Manually refresh the local cached schema"
    echo "  ❓ help or -h                 → Show this help message"
    echo "  🚪 quit or -q                 → Exit the script"
    echo ""
}

echo ""
echo "📘 Jamf Pro API Privilege Checker"
echo "💡 Type 'help' or '-h' for available options"
echo ""

while true; do
    echo -n "🔎 Type the full path of an endpoint to see its required privliges: "
    read INPUT

    # Normalize input
    INPUT_LOWER=$(echo "$INPUT" | tr '[:upper:]' '[:lower:]')

    case "$INPUT_LOWER" in
        quit|-q|done)
            echo "👋 Goodbye!"
            break
            ;;

        help|-h)
            show_help
            ;;

        refresh|-r)
            download_schema
            SCHEMA=$(cat "$schemaFile")
            ;;

        list|-l)
            echo ""
            echo "📄 Available API Endpoints:"
            echo "$SCHEMA" | jq -r '.paths | keys[]' | sort
            echo ""
            ;;

        "list computers"|-lc)
            echo ""
            echo "💻 Computer-related Endpoints:"
            echo "$SCHEMA" | jq -r '.paths | keys[]' | grep -i "/computers" | sort
            echo ""
            ;;

        "list mobile"|-lm)
            echo ""
            echo "📱 Mobile Device-related Endpoints:"
            echo "$SCHEMA" | jq -r '.paths | keys[]' | grep -i "/mobile" | sort
            echo ""
            ;;

        /*)
            ENDPOINT="$INPUT"
            echo "📡 Checking required privileges for: $ENDPOINT"
            echo ""

            REQUIRED_PRIVS=$(echo "$SCHEMA" | jq -r --arg endpoint "$ENDPOINT" '
              .paths[$endpoint]
              | to_entries[]
              | select(.value."x-required-privileges" != null)
              | {method: .key, privileges: .value."x-required-privileges"}
            ')

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
            ;;

        *)
            echo "❌ Unknown command: $INPUT"
            echo "Type 'help' or '-h' to see available options."
            ;;
    esac
done
