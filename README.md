# JamfAPI-PrivilegesChecker

**JamfAPI-PrivilegesChecker** is a lightweight Zsh script that allows Jamf administrators and developers to quickly check the API privileges associated with their Jamf Pro credentials.

## Features

- Automatically detect the enrolled Jamf Pro server and local binary version.
- Retrieve and locally cache the Jamf Pro OpenAPI schema (`/api/schema`).
- Inspect required privileges for specific endpoints using schema metadata.
- List all API endpoints, or filter by computers, mobile devices, or user-related APIs.
- Refresh the local schema cache when the Jamf Pro server is updated.
- CLI-based, fast, and minimal; built using standard macOS tools.

## Requirements

- macOS 13 or later
- Zsh (default on modern macOS versions)
- `curl` (pre-installed on macOS)
- [`jq`](https://stedolan.github.io/jq/) (install via [Homebrew](https://brew.sh) if not already installed)
- A Mac enrolled in Jamf Pro (or configure a Jamf Pro URL manually)

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/paullstanley/JamfAPI-PrivilegesChecker.git
   cd JamfAPI-PrivilegesChecker
   ```

2. (Optional) Make the script executable:
   ```bash
   chmod +x JAPI-Privilege-Checker.sh
   ```

## Usage

### Method 1: Direct Execution (Recommended)

Run the script directly from your terminal:
```bash
./JAPI-Privilege-Checker.sh
```

### Method 2: Using Zsh Explicitly

If the script doesn’t have a shebang (`#!/bin/zsh`), or you want to be explicit:
```bash
zsh JAPI-Privilege-Checker.sh
```

### Method 3: From a `.sh` Wrapper Script

If you’d prefer to invoke the script from a `.sh` shell wrapper, you can create a file like this:

```bash
#!/bin/bash
zsh ./JAPI-Privilege-Checker.sh
```

Save this as `run.sh`, then make it executable and run it:
```bash
chmod +x run.sh
./run.sh
```

## Commands

Once running, the script supports the following commands:
- /your/endpoint/path → Display required privileges for a specific endpoint.
- list or -l → Show all API endpoints.
- list computers or -lc → Show computer-related endpoints.
- list mobile or -lm → Show mobile device-related endpoints.
- list user or -lu → Show user-related endpoints.
- refresh or -r → Refresh the cached schema file.
- help or -h → Show the help menu.
- quit or -q → Exit the script.


### Behavior

- The script attempts to detect the enrolled Jamf Pro server and current Jamf binary version.
- If no enrollment URL is detected, it defaults to https://overview.jamfcloud.com.
- Schema files are saved to ~/Documents/api_schema/ and named by Jamf Pro version.
- The script avoids re-downloading the schema if the correct version is already cached.
- All privilege data is derived from the x-required-privileges field in the OpenAPI schema.

## Notes

- This script does not perform authentication using a Client ID or Secret.
- It does not query the /api/v1/auth/privileges endpoint.
- No credentials are collected, stored, or transmitted.
- Intended for reference and exploration of Jamf Pro API schema structure and privilege requirements.

## License

This project is licensed under the [MIT License](LICENSE).

## Author

Created by [Paull Stanley](https://github.com/paullstanley).
