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
