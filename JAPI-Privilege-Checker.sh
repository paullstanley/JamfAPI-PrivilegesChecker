#!/bin/zsh

url="https://overview.jamfcloud.com"
schemaDir="$HOME/Documents/api_schema"
schemaFile="$schemaDir/schema.json"

# Create schema directory if it doesn't exist
mkdir -p "$schemaDir"

download_schema() {
    echo "🌐 Downloading latest API schema..."
    curl -s "$url/api/schema" -o "$schemaFile"
}

# Download or update schema
if [[ -f "$schemaFile" ]]; then
    echo "📁 Local schema found. Checking version..."

    # Get local version
    localVersion=$(jq -r '.info.version // empty' "$schemaFile")

    # Get remote version from curl directly (without saving)
    remoteSchema=$(curl -s "$url/api/schema")
    remoteVersion=$(echo "$remoteSchema" | jq -r '.info.version // empty')

    if [[ -z "$localVersion" || -z "$remoteVersion" ]]; then
        echo "⚠️  Could not determine schema versions. Skipping version check."
    elif [[ "$remoteVersion" != "$localVersion" ]]; then
        echo "🆕 Newer schema version detected! Updating from $localVersion → $remoteVersion"
        echo "$remoteSchema" > "$schemaFile"
    else
        echo "✅ Local schema is up to date (version $localVersion)."
    fi
else
    download_schema
fi

# Load schema into variable
SCHEMA=$(cat "$schemaFile")

show_help() {
    echo ""
    echo "🆘 Available Commands:"
    echo "  🔎 [endpoint path]     → Check required privileges for a specific endpoint (e.g. /v1/computers-inventory)"
    echo "  📄 list                → Show all API endpoints"
    echo "  💻 list computers      → Show only computer-related endpoints"
    echo "  📱 list mobile         → Show only mobile device-related endpoints"
    echo "  ❓ help or -h          → Show this help message"
    echo "  🚪 quit or -q          → Exit the script"
    echo ""
}

echo ""
echo "📘 Jamf Pro API Privilege Checker"
echo "💡 Type 'help' or '-h' for available options"
echo ""

while true; do
    echo -n "🔎 What would you like to do? (endpoint, list, help, or quit): "
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

        list)
            echo ""
            echo "📄 Available API Endpoints:"
            echo "$SCHEMA" | jq -r '.paths | keys[]' | sort
            echo ""
            ;;

        "list computers")
            echo ""
            echo "💻 Computer-related Endpoints:"
            echo "$SCHEMA" | jq -r '.paths | keys[]' | grep -i "/computers" | sort
            echo ""
            ;;

        "list mobile")
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
