#!/bin/zsh

#If ran from MacOS will check current enrollment URL as well as binary version on machine. This should match server it is enrolled to and serve as a reference point for future schema updates
#Comment out lines 5-15 and uncomment line 17 if you want to set manual server path
getUrl=$(jamf checkJSSConnection | awk '{print $4}')
url=$(echo $getUrl | sed 's/... available.//g')
if [[ $url = "" ]]; then
  echo "No URL found, reverting to sample server"
  #Demo server
  url="https://overview.jamfcloud.com"
fi
#variables to pull jamf binary version and label .json file appropriately. Will auto download new schema on server upgrade
getBinaryVersion=$(jamf about | awk 'NR==4' | awk '{print $2}')
schemaDir="$HOME/Documents/api_schema"
schemaFile="$schemaDir/schema_$getBinaryVersion.json"

#url="https://yourserver.jamfcloud.com"

# Create schema directory if it doesn't exist
mkdir -p "$schemaDir"

# Function to download latest schema
download_schema() {
    echo "🌐 Downloading latest API schema for Jamf Pro version $getBinaryVersion"
    sudo curl -s "$url/api/schema" -o "$schemaFile"
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
  echo "🆘 Commands:"
  echo "  [endpoint path]         → Check required privileges for a specific endpoint (e.g. /v1/computers-inventory)"
  echo "  list or -l              → Show all API endpoints"
  echo "  list computers or -lc   → Show computer-related endpoints"
  echo "  list mobile or -lm      → Show mobile device-related endpoints"
  echo "  list user or -lu        → Show mobile device-related endpoints"
  echo "  refresh or -r           → Refresh the cached schema file"
  echo "  help or -h              → Show this help menu"
  echo "  quit or -q              → Exit"
  echo ""
}

echo ""
echo "📘 Jamf Pro API Privilege Checker"
echo "💡 Type a command or endpoint. Use 'help' for options."
echo ""

while true; do
  echo -n "🧭 What would you like to do? "
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
          
        "list user"|-lu)
            echo ""
            echo "👤 User-related Endpoints:"
            echo "$SCHEMA" | jq -r '.paths | keys[]' | grep -i "/user" | sort
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
            echo ""
            echo "❌ Unknown command. Type 'help' or '-h' for available options"
            echo ""
            ;;
    esac
done
