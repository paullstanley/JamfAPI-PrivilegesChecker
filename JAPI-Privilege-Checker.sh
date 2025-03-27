#!/bin/bash

# Currently it uses Bearer Token Authentication using Basic Authentication. It is required that Basic Authentication be enabled in the Password Policy setting of the Jamf User being used.


# ========== USER CONFIGURABLE ==========
username="<YOUR USER NAME>"
password="<YOUR PASSWORD>"
url="https://<YOUR INSTANCE>.jamfcloud.com"
# =======================================

bearerToken=""
tokenExpirationEpoch="0"

getBearerToken() {
    echo "🔐 Requesting a new bearer token..."
    response=$(curl -s -u "$username:$password" "$url/api/v1/auth/token" -X POST)
    bearerToken=$(echo "$response" | plutil -extract token raw -)
    tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
    tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
}

checkTokenExpiration() {
    nowEpochUTC=$(date -j -f "%Y-%m-%dT%T" "$(date -u +"%Y-%m-%dT%T")" +"%s")
    if [[ $tokenExpirationEpoch -gt $nowEpochUTC ]]; then
        echo "✅ Bearer token is still valid."
    else
        echo "⚠️  No valid token found. Getting a new one..."
        getBearerToken
    fi
}

invalidateToken() {
    echo "🚪 Logging out and invalidating token..."
    responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${bearerToken}" "$url/api/v1/auth/invalidate-token" -X POST -s -o /dev/null)
    if [[ $responseCode == 204 ]]; then
        echo "🔒 Token successfully invalidated."
        bearerToken=""
        tokenExpirationEpoch="0"
    elif [[ $responseCode == 401 ]]; then
        echo "🔓 Token was already invalid."
    else
        echo "❌ An unknown error occurred during token invalidation."
    fi
}

# ------------------ Main Script ------------------

echo ""
echo "📘 This script checks the required privileges for a specific Jamf Pro API endpoint."
echo "👉 You only need to provide the full path of the endpoint (e.g., /v1/computers-inventory)."
echo ""

# Ensure we have a valid token
checkTokenExpiration

# Prompt for endpoint input
read -p "🔎 Enter the full API endpoint path you'd like to check: " ENDPOINT

# Fetch the OpenAPI schema
echo "📡 Fetching schema from: $url/api/schema"
SCHEMA=$(curl -s -H "Authorization: Bearer ${bearerToken}" "$url/api/schema")

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

# Clean up
invalidateToken
