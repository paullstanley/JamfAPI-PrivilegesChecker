# JamfAPI-PrivilegesChecker

JamfAPI-PrivilegesChecker is a lightweight macOS SwiftUI app that allows Jamf administrators and developers to quickly check the API privileges associated with their Jamf Pro API credentials.

## Features

- Authenticate against your Jamf Pro instance using Client ID and Secret.
- Retrieve and display user privileges via the `/api/v1/auth/privileges` endpoint.
- Secure credential handling with SwiftUI SecureFields.
- Minimal, user-friendly interface.

## Requirements

- macOS 13 or later
- Xcode 15 or later
- Jamf Pro API Client ID and Secret
- Access to the Jamf Pro API

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/paullstanley/JamfAPI-PrivilegesChecker.git
   cd JamfAPI-PrivilegesChecker
   ```

2. Open the project in Xcode:
   - Open `JamfAPI-PrivilegesChecker.xcodeproj`.

3. Update the Jamf URL (if necessary) to point to your environment.

4. Build and run the app.

## Usage

1. Launch the app.
2. Enter your:
   - Jamf Pro URL (e.g., `https://yourcompany.jamfcloud.com`)
   - Client ID
   - Client Secret
3. Click **Authenticate** to retrieve your API privileges.

## Notes

- Authentication uses OAuth2 Client Credentials flow.
- No credentials are stored locally; they are only used during the session.

## License

This project is licensed under the [MIT License](LICENSE).

## Author

Created by [Paull Stanley](https://github.com/paullstanley).
