# JamfAPI-PrivilegesChecker

**JamfAPI-PrivilegesChecker** is a lightweight Zsh script that allows Jamf administrators and developers to quickly check the API privileges associated with their Jamf Pro credentials.

## Features

- Authenticate against your Jamf Pro instance using a Client ID and Secret.
- Retrieve and display user privileges via the `/api/v1/auth/privileges` endpoint.
- Secure, session-based handling of credentials.
- Minimal and fast CLI utility.

## Requirements

- macOS 13 or later
- Zsh (default on modern macOS versions)
- `curl` (pre-installed on macOS)
- [`jq`](https://stedolan.github.io/jq/) (install via [Homebrew](https://brew.sh) if not already installed)
- Jamf Pro API Client ID and Secret

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/paullstanley/JamfAPI-PrivilegesChecker.git
   cd JamfAPI-PrivilegesChecker
   ```

2. (Optional) Make the script executable:
   ```bash
   chmod +x check-privileges.zsh
   ```

## Usage

### Method 1: Direct Execution (Recommended)

Run the script directly from your terminal:
```bash
./check-privileges.zsh
```

### Method 2: Using Zsh Explicitly

If the script doesn’t have a shebang (`#!/bin/zsh`), or you want to be explicit:
```bash
zsh check-privileges.zsh
```

### Method 3: From a `.sh` Wrapper Script

If you’d prefer to invoke the script from a `.sh` shell wrapper, you can create a file like this:

```bash
#!/bin/bash
zsh ./check-privileges.zsh
```

Save this as `run.sh`, then make it executable and run it:
```bash
chmod +x run.sh
./run.sh
```

## Prompts

The script will ask you to enter:
- **Jamf Pro URL** (e.g., `https://yourcompany.jamfcloud.com`)
- **Client ID**
- **Client Secret**

It will then authenticate and display your API privileges.

### Example Output

```json
{
  "privileges": [
    "Auditor.Read",
    "Enrollment.View",
    "Inventory.Read"
  ]
}
```

## Notes

- Authentication uses the OAuth2 Client Credentials flow.
- No credentials are stored locally; they are used only for the current session.
- Ensure your Client ID has permission to access the `/api/v1/auth/privileges` endpoint.

## License

This project is licensed under the [MIT License](LICENSE).

## Author

Created by [Paull Stanley](https://github.com/paullstanley).
